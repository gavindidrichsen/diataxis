# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'

RSpec.describe Diataxis do
  let(:project_root) { File.expand_path('..', File.dirname(__FILE__)) }
  let(:test_dir) { File.join(project_root, 'tmp', 'test') }
  let(:docs_dir) { File.join(test_dir, 'docs') }
  let(:howto_dir) { File.join(docs_dir, 'how-to') }
  let(:tutorial_dir) { File.join(docs_dir, 'tutorials') }
  let(:adr_dir) { File.join(docs_dir, 'exp/adr') }
  let(:explanation_dir) { File.join(docs_dir, 'explanations') }
  let(:readme_path) { File.join(docs_dir, 'README.md') }
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

        expect(File).to exist(File.join(howto_dir, 'how_to_test_document.md'))
        expect(File).to exist(readme_path)
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

        howto_path = File.join(howto_dir, 'how_to_configure_system.md')
        expect(File).to exist(howto_path)

        content = File.read(howto_path)
        expect(content.downcase).to include('# how to configure system')

        readme_content = File.read(readme_path)
        expect(readme_content.downcase).to include('[how to configure system]')
      end
    end

    context 'creating tutorial' do
      it 'creates tutorial with correct template and updates README' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['tutorial', 'new', 'Getting Started'])
        end

        tutorial_path = File.join(tutorial_dir, 'tutorial_getting_started.md')
        expect(File).to exist(tutorial_path)

        content = File.read(tutorial_path)
        expect(content).to include('# Getting Started')

        readme_content = File.read(readme_path)
        expect(readme_content).to include('[Getting Started]')
      end
    end

    context 'creating ADR' do
      it 'creates ADR with correct numbering and updates README' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['adr', 'new', 'Use PostgreSQL Database'])
        end

        adr_path = File.join(adr_dir, '0001-use-postgresql-database.md')
        expect(File).to exist(adr_path)

        content = File.read(adr_path)
        expect(content).to include('# 1. Use PostgreSQL Database')

        readme_content = File.read(readme_path)
        expect(readme_content).to include('[ADR-0001]')
      end
    end

    context 'creating explanation' do
      it 'creates explanation with correct template and updates README' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['explanation', 'new', 'System Architecture'])
        end

        explanation_path = File.join(explanation_dir, 'explanation_system_architecture.md')
        expect(File).to exist(explanation_path)

        content = File.read(explanation_path)
        expect(content).to include('# System Architecture')
        expect(content).to include('## Overview')
        expect(content).to include('## Background')
        expect(content).to include('## Key Concepts')
        expect(content).to include('## Technical Context')
        expect(content).to include('## Rationale')
        expect(content).to include('## Related Concepts')

        readme_content = File.read(readme_path)
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
        original_path = File.join(howto_dir, 'how_to_original_title.md')

        # Update title
        content = File.read(original_path)
        new_content = content.sub(/# How to .*$/, '# How to Updated Title')
        File.write(original_path, new_content)

        # Run update
        Diataxis::CLI.run(['update', '.'])

        # Check results
        new_path = File.join(howto_dir, 'how_to_updated_title.md')
        expect(File).not_to exist(original_path)
        expect(File).to exist(new_path)

        # Check README update
        readme_content = File.read(readme_path)
        expect(readme_content.downcase).not_to include('original title')
        expect(readme_content.downcase).to include('updated title')
      end
    end
  end

  describe 'README management' do
    context 'with existing README' do
      before do
        FileUtils.mkdir_p(File.dirname(readme_path))
        File.write(readme_path, "Custom project description\n")
      end

      it 'preserves custom content while updating document links' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Test Document'])
        end

        readme_content = File.read(readme_path)
        expect(readme_content).to include('Custom project description')
        expect(readme_content.downcase).to include('[how to test document]')
      end
    end

    context 'without existing README' do
      it 'creates new README with correct sections' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Test Document'])
        end

        readme_content = File.read(readme_path)
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

      expect(Dir).to exist(docs_dir)
      expect(Dir).to exist(howto_dir)
    end
  end
end
