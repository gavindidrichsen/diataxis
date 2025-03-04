# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'

RSpec.describe Diataxis do
  let(:test_dir) { File.join(File.expand_path('..', File.dirname(__FILE__)), 'tmp', 'test') }
  let(:docs_paths) do
    {
      docs: File.join(test_dir, 'docs'),
      howto: File.join(test_dir, 'docs/how-to'),
      tutorial: File.join(test_dir, 'docs/tutorials'),
      adr: File.join(test_dir, 'docs/exp/adr'),
      explanation: File.join(test_dir, 'docs/explanations'),
      readme: File.join(test_dir, 'docs/README.md')
    }
  end
  let(:config_path) { File.join(test_dir, '.diataxis') }

  before do
    # Create clean test directory
    FileUtils.rm_rf(test_dir)
    FileUtils.mkdir_p(test_dir)

    # Set up default configuration
    config = {
      'readme' => 'docs/README.md',
      'howtos' => 'docs/how-to',
      'tutorials' => 'docs/tutorials',
      'explanations' => 'docs/explanations',
      'adr' => 'docs/exp/adr'
    }
    FileUtils.mkdir_p(File.dirname(config_path))
    File.write(config_path, JSON.generate(config))
  end

  after do
    # Clean up test directory
    FileUtils.rm_rf(test_dir)
  end

  it 'has a version number' do
    expect(Diataxis::VERSION).not_to be_nil
  end

  describe 'configuration management' do
    context 'with default configuration' do
      it 'creates documents in default locations' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Test Document'])
        end

        expect(File).to exist(File.join(docs_paths[:howto], 'how_to_test_document.md'))
        expect(File).to exist(docs_paths[:readme])
      end
    end

    context 'with custom configuration' do
      let(:custom_dir) { File.join(test_dir, 'custom') }

      before do
        config = {
          'readme' => 'custom/README.md',
          'howtos' => 'custom/howtos',
          'tutorials' => 'custom/learn',
          'adr' => 'custom/decisions'
        }
        FileUtils.mkdir_p(File.dirname(config_path))
        File.write(config_path, JSON.generate(config))
      end

      it 'creates documents in configured locations' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Test Custom Path'])
        end

        expect(File).to exist(File.join(custom_dir, 'howtos/how_to_test_custom_path.md'))
        expect(File).to exist(File.join(custom_dir, 'README.md'))
      end
    end

    context 'with invalid configuration' do
      before do
        FileUtils.mkdir_p(File.dirname(config_path))
        File.write(config_path, '{invalid json}')
      end

      it 'shows clear error message' do
        Dir.chdir(test_dir) do
          expect { Diataxis::CLI.run(['howto', 'new', 'Test Error']) }.to raise_error(JSON::ParserError)
        end
      end
    end
  end

  describe 'document creation' do
    context 'creating how-to' do
      it 'creates how-to with correct template and updates README' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Configure System'])
        end

        howto_path = File.join(docs_paths[:howto], 'how_to_configure_system.md')
        expect(File).to exist(howto_path)

        content = File.read(howto_path)
        expect(content.downcase).to include('# how to configure system')

        readme_content = File.read(docs_paths[:readme])
        expect(readme_content.downcase).to include('[how to configure system]')
      end
    end

    context 'creating tutorial' do
      it 'creates tutorial with correct template and updates README' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['tutorial', 'new', 'Getting Started'])
        end

        tutorial_path = File.join(docs_paths[:tutorial], 'tutorial_getting_started.md')
        expect(File).to exist(tutorial_path)

        content = File.read(tutorial_path)
        expect(content).to include('# Getting Started')

        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[Getting Started]')
      end
    end

    context 'creating ADR' do
      it 'creates ADR with correct numbering and updates README' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['adr', 'new', 'Use PostgreSQL Database'])
        end

        adr_path = File.join(docs_paths[:adr], '0001-use-postgresql-database.md')
        expect(File).to exist(adr_path)

        content = File.read(adr_path)
        expect(content).to include('# 1. Use PostgreSQL Database')

        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[ADR-0001]')
      end
    end

    context 'creating explanation' do
      let(:explanation_path) { File.join(docs_paths[:explanation], 'explanation_system_architecture.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['explanation', 'new', 'System Architecture'])
        end
      end

      it 'creates explanation file in correct location' do
        expect(File).to exist(explanation_path)
      end

      it 'creates explanation with correct template sections' do
        content = File.read(explanation_path)
        expected_sections = [
          '# System Architecture',
          '## Overview',
          '## Background',
          '## Key Concepts',
          '## Technical Context',
          '## Rationale',
          '## Related Concepts'
        ]

        expected_sections.each do |section|
          expect(content).to include(section)
        end
      end

      it 'updates README with explanation section and link' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[System Architecture]')
        expect(readme_content).to include('### Explanations')
      end
    end
  end

  describe 'document title changes' do
    it 'renames file and updates README when title changes' do
      Dir.chdir(test_dir) do
        # Create initial document
        Diataxis::CLI.run(['howto', 'new', 'Original Title'])
        original_path = File.join(docs_paths[:howto], 'how_to_original_title.md')

        # Update title
        content = File.read(original_path)
        new_content = content.sub(/# How to .*$/, '# How to Updated Title')
        File.write(original_path, new_content)

        # Run update
        Diataxis::CLI.run(['update', '.'])

        # Check results
        new_path = File.join(docs_paths[:howto], 'how_to_updated_title.md')
        expect(File).not_to exist(original_path)
        expect(File).to exist(new_path)

        # Check README update
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content.downcase).not_to include('original title')
        expect(readme_content.downcase).to include('updated title')
      end
    end
  end

  describe 'README management' do
    context 'with existing README' do
      before do
        FileUtils.mkdir_p(File.dirname(docs_paths[:readme]))
        File.write(docs_paths[:readme], "Custom project description\n")
      end

      it 'preserves custom content while updating document links' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Test Document'])
        end

        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('Custom project description')
        expect(readme_content.downcase).to include('[how to test document]')
      end
    end

    context 'without existing README' do
      it 'creates new README with correct sections' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Test Document'])
        end

        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('# ')
        expect(readme_content).to include('### HowTos')
        expect(readme_content).to include('<!-- howtolog -->')
      end
    end
  end

  describe 'directory handling' do
    it 'creates necessary directories when missing' do
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['howto', 'new', 'Test Document'])
      end

      expect(Dir).to exist(docs_paths[:docs])
      expect(Dir).to exist(docs_paths[:howto])
    end
  end
end
