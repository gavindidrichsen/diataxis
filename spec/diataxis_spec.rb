# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'
require 'stringio'

RSpec.describe Diataxis do
  let(:test_dir) { File.join(File.expand_path('..', File.dirname(__FILE__)), 'tmp', 'test') }
  let(:docs_paths) do
    {
      docs: File.join(test_dir, 'docs'),
      howto: File.join(test_dir, 'docs'),
      tutorial: File.join(test_dir, 'docs'),
      adr: File.join(test_dir, 'docs/adr'),
      explanation: File.join(test_dir, 'docs'),
      handover: File.join(test_dir, 'docs'),
      note: File.join(test_dir, 'docs'),
      five_why: File.join(test_dir, 'docs'),
      project: File.join(test_dir, 'docs'),
      readme: File.join(test_dir, 'README.md')
    }
  end
  let(:config_path) { File.join(test_dir, '.diataxis') }

  before do
    # Reset logger state for clean test environment
    Diataxis::Log.reset!

    # Create clean test directory
    FileUtils.rm_rf(test_dir)
    FileUtils.mkdir_p(test_dir)

    # Set up default configuration
    FileUtils.mkdir_p(File.dirname(config_path))
    File.write(config_path, JSON.generate(Diataxis::Config::DEFAULT_CONFIG))
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
    context 'creating how-tos' do
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
        expect(content).to include('# 0001. Use PostgreSQL Database')

        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[ADR-0001]')
      end
    end

    context 'creating handover' do
      let(:handover_path) { File.join(docs_paths[:handover], 'handover_windows_long_path_issue.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['handover', 'new', 'Windows Long Path Issue'])
        end
      end

      it 'creates handover file with correct filename' do
        expect(File).to exist(handover_path)
      end

      it 'creates handover with correct template structure' do
        content = File.read(handover_path)
        expect(content).to include('# Windows Long Path Issue')
        expect(content).to include('## Problem Summary')
        expect(content).to include('## What Do We Know')
        expect(content).to include('## What We Think')
      end

      it 'updates README with handover link and section' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[Windows Long Path Issue]')
        expect(readme_content).to include('### Handovers')
      end
    end

    context 'creating note' do
      let(:note_path) { File.join(docs_paths[:note], 'note_git_branch_commands.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['note', 'new', 'Git Branch Commands'])
        end
      end

      it 'creates note file with correct filename' do
        expect(File).to exist(note_path)
      end

      it 'creates note with correct template structure' do
        content = File.read(note_path)
        aggregate_failures do
          expect(content).to include('# Git Branch Commands')
          expect(content).to include('## KEYPOINTS')
          expect(content).to include('## SUMMARY')
          expect(content).to include('## TASKS')
          expect(content).to include('## BACKGROUND')
        end
      end

      it 'updates README with note link and section' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[Git Branch Commands]')
        expect(readme_content).to include('### Notes')
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
          adr: File.join(other_repo_dir, 'docs/references/adr')
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
          'adr' => 'docs/references/adr'
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
        expect(readme_content).to include('[ADR-0001](docs/adr/0001-main-repo-decision.md)')

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
        expect(readme_content).to include('### How-To Guides')
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

  describe 'dynamic README section management' do
    context 'with mixed document types' do
      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Deploy Application'])
          Diataxis::CLI.run(['adr', 'new', 'Use Docker'])
          # NOTE: No tutorials or explanations created
        end
      end

      it 'shows sections with content' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('### How-To Guides')
        expect(readme_content).to include('### Design Decisions')
      end

      it 'hides sections without content' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).not_to include('### Tutorials')
        expect(readme_content).not_to include('### Explanations')
        expect(readme_content).not_to include('### Handovers')
      end

      it 'maintains proper document links in visible sections' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[How to deploy Application]')
        expect(readme_content).to include('[ADR-0001]')
      end
    end

    context 'when sections gain content' do
      before do
        # Start with no tutorials
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['howto', 'new', 'Basic Guide'])
        end
      end

      it 'adds sections when documents are created' do
        # Verify no tutorials section initially
        initial_readme = File.read(docs_paths[:readme])
        expect(initial_readme).not_to include('### Tutorials')

        # Add a tutorial
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['tutorial', 'new', 'Getting Started'])
        end

        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('### Tutorials')
        expect(readme_content).to include('[Getting Started]')
      end
    end
  end

  describe 'CLI help and version' do
    it 'shows usage information when called with no arguments' do
      expect { Diataxis::CLI.run([]) }.to raise_error(Diataxis::UsageError) do |error|
        expect(error.usage_message).to include('Usage: diataxis [options] <command>')
        expect(error.exit_code).to eq(1)
      end
    end

    it 'includes all document types in help text' do
      Diataxis::CLI.run([])
    rescue Diataxis::UsageError => e
      expect(e.usage_message).to include('howto new "Title"')
      expect(e.usage_message).to include('tutorial new "Title"')
    end

    it 'includes remaining document types in help text' do
      Diataxis::CLI.run([])
    rescue Diataxis::UsageError => e
      expect(e.usage_message).to include('adr new "Title"')
      expect(e.usage_message).to include('explanation new "Title"')
      expect(e.usage_message).to include('handover new "Title"')
      expect(e.usage_message).to include('note new "Title"')
    end

    it 'shows version information' do
      expect { Diataxis::CLI.run(['--version']) }.to raise_error(SystemExit)

      output = capture_stdout do
        Diataxis::CLI.run(['--version'])
      rescue StandardError
        nil
      end
      expect(output).to include('diataxis version')
      expect(output).to include(Diataxis::VERSION)
    end
  end

  describe 'error handling' do
    context 'with missing arguments' do
      it 'shows usage for howto without title' do
        Dir.chdir(test_dir) do
          expect { Diataxis::CLI.run(%w[howto new]) }.to raise_error(Diataxis::UsageError) do |error|
            expect(error.usage_message).to include('Usage: diataxis howto new')
            expect(error.exit_code).to eq(1)
          end
        end
      end
    end

    context 'with unknown commands' do
      it 'shows error for unknown document type' do
        Dir.chdir(test_dir) do
          expect { Diataxis::CLI.run(%w[unknown new Title]) }.to raise_error(Diataxis::UsageError) do |error|
            expect(error.usage_message).to include('Unknown command: unknown')
            expect(error.exit_code).to eq(1)
          end
        end
      end
    end
  end

  private

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
