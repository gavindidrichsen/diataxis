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

  describe 'explanation document creation' do
    context 'with basic title' do
      let(:explanation_path) { File.join(docs_paths[:explanation], 'understanding_system_architecture.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['explanation', 'new', 'System Architecture'])
        end
      end

      it 'creates explanation file with understanding prefix' do
        expect(File).to exist(explanation_path)
      end

      it 'creates explanation with correct template sections' do
        content = File.read(explanation_path)
        expected_sections = [
          '# Understanding System Architecture',
          '## Purpose',
          'This document answers:',
          '- Why do we do things this way?',
          '- What are the core concepts?',
          '- How do the pieces fit together?',
          '## Background',
          '## Key Concepts',
          '### Concept 1',
          '### Concept 2',
          '## Related Topics'
        ]

        expected_sections.each do |section|
          expect(content).to include(section)
        end
      end

      it 'updates README with explanation section and link' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[Understanding System Architecture]')
        expect(readme_content).to include('### Explanations')
      end
    end

    context 'with existing Understanding prefix' do
      let(:explanation_path) { File.join(docs_paths[:explanation], 'understanding_configuration_management.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['explanation', 'new', 'Understanding Configuration Management'])
        end
      end

      it 'preserves single Understanding prefix' do
        content = File.read(explanation_path)
        expect(content).to include('# Understanding Configuration Management')
        expect(content).not_to include('# Understanding Understanding')
      end

      it 'creates correct filename without double prefix' do
        expect(File).to exist(explanation_path)
        expect(Dir.glob(File.join(docs_paths[:explanation], 'understanding_understanding_*.md'))).to be_empty
      end
    end

    context 'when changing title' do
      let(:original_path) { File.join(docs_paths[:explanation], 'understanding_system_architecture.md') }
      let(:new_path) { File.join(docs_paths[:explanation], 'understanding_advanced_system_design.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['explanation', 'new', 'System Architecture'])
          content = File.read(original_path)
          new_content = content.sub(/# Understanding.*$/, '# Understanding Advanced System Design')
          File.write(original_path, new_content)
          Diataxis::CLI.run(['update', '.'])
        end
      end

      it 'renames file preserving Understanding prefix' do
        expect(File).not_to exist(original_path)
        expect(File).to exist(new_path)
      end

      it 'updates README links' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).not_to include('[Understanding System Architecture]')
        expect(readme_content).to include('[Understanding Advanced System Design]')
      end

      it 'maintains correct document structure' do
        content = File.read(new_path)
        expect(content).to include('# Understanding Advanced System Design')
        expect(content).to include('## Purpose')
        expect(content).to include('## Background')
        expect(content).to include('## Key Concepts')
      end
    end
  end

  describe 'document path handling' do
    context 'with documents in multiple repositories' do
      let(:other_repo_dir) { File.join(test_dir, 'other_repo') }
      let(:other_docs_paths) do
        {
          docs: File.join(other_repo_dir, 'docs'),
          howto: File.join(other_repo_dir, 'docs/how-to'),
          adr: File.join(other_repo_dir, 'docs/exp/adr')
        }
      end

      before do
        # Set up other repository with same config structure
        FileUtils.mkdir_p(other_docs_paths[:docs])
        FileUtils.mkdir_p(other_docs_paths[:howto])
        FileUtils.mkdir_p(other_docs_paths[:adr])

        # Create config in other repo
        other_config = {
          'readme' => 'docs/README.md',
          'howtos' => 'docs/how-to',
          'adr' => 'docs/exp/adr'
        }
        File.write(File.join(other_repo_dir, '.diataxis'), JSON.generate(other_config))

        # Create documents in both repositories
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['adr', 'new', 'Main Repo Decision'])
        end

        Dir.chdir(other_repo_dir) do
          Diataxis::CLI.run(['adr', 'new', 'Other Repo Decision'])
        end
      end

      it 'only includes documents from the current repository in README' do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['update', '.'])
        end

        readme_content = File.read(docs_paths[:readme])

        # Should include ADR from current repo
        expect(readme_content).to include('[ADR-0001](exp/adr/0001-main-repo-decision.md)')

        # Should not include ADR from other repo
        expect(readme_content).not_to include('other-repo-decision.md')
      end

      it 'respects configured paths when searching for documents' do
        # Create ADR in non-standard location in current repo
        FileUtils.mkdir_p(File.join(test_dir, 'wrong/path'))
        wrong_path_adr = File.join(test_dir, 'wrong/path/0002-misplaced-decision.md')
        File.write(wrong_path_adr, "# 2. Misplaced Decision\n\nDate: 2025-03-05\n")

        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['update', '.'])
        end

        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).not_to include('misplaced-decision.md')
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
