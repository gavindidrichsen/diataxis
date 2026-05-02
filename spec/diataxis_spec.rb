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

        expect(File).to exist(File.join(docs_paths[:howto], 'howto_how_to_test_document.md'))
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

        expect(File).to exist(File.join(custom_dir, 'howtos/howto_how_to_test_custom_path.md'))
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

    context 'without configuration file' do
      before do
        # Remove the config file that was created in the before block
        FileUtils.rm_f(config_path)
      end

      it 'fails with helpful error message when creating a document' do
        Dir.chdir(test_dir) do
          expect { Diataxis::CLI.run(['project', 'new', 'Test Project']) }
            .to raise_error(Diataxis::ConfigurationError, /No \.diataxis configuration file found/)
        end
      end

      it 'suggests running dia init in error message' do
        Dir.chdir(test_dir) do
          expect { Diataxis::CLI.run(%w[howto new Test]) }
            .to raise_error(Diataxis::ConfigurationError, /Please run 'dia init'/)
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

        howto_path = File.join(docs_paths[:howto], 'howto_how_to_configure_system.md')
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

    context 'creating project' do
      let(:project_dir) { File.join(test_dir, 'docs/_gtd') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['project', 'new', 'Sprint Planning'])
        end
      end

      it 'creates project file with correct filename prefix' do
        project_files = Dir.glob(File.join(project_dir, 'project_*.md'))
        expect(project_files).not_to be_empty
      end

      it 'creates project with correct template structure' do
        project_file = Dir.glob(File.join(project_dir, 'project_*.md')).first
        content = File.read(project_file)
        aggregate_failures do
          expect(content).to include('Sprint Planning')
          expect(content).to include('## Context')
          expect(content).to include('## Project Purpose')
          expect(content).to include('## Desired Outcome')
        end
      end

      it 'updates README with project link and section' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[Project: Sprint Planning]')
        expect(readme_content).to include('### Projects')
      end
    end

    context 'creating 5why' do
      let(:fivewhy_path) { File.join(docs_paths[:five_why], '5why_server_crash.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['5why', 'new', 'Server Crash'])
        end
      end

      it 'creates 5why file with correct filename prefix' do
        expect(File).to exist(fivewhy_path)
      end

      it 'creates 5why with correct template structure' do
        content = File.read(fivewhy_path)
        aggregate_failures do
          expect(content).to include('# Server Crash')
          expect(content).to include('## Problem Statement')
          expect(content).to include('## Analysis')
          expect(content).to include('## References')
        end
      end

      it 'updates README with 5why link and section' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[Server Crash]')
        expect(readme_content).to include('### 5-Whys')
      end
    end

    context 'creating pr' do
      let(:pr_path) { File.join(docs_paths[:explanation], 'pr_fix_login_bug.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['pr', 'new', 'Fix Login Bug'])
        end
      end

      it 'creates pr file with correct filename prefix' do
        expect(File).to exist(pr_path)
      end

      it 'creates pr with correct template structure' do
        content = File.read(pr_path)
        aggregate_failures do
          expect(content).to include('# Fix Login Bug')
          expect(content).to include('## Purpose')
          expect(content).to include('## Background')
          expect(content).to include('## Changes')
        end
      end

      it 'updates README with pr link and section' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).to include('[Fix Login Bug]')
        expect(readme_content).to include('### Pull Requests')
      end
    end
  end

  describe 'document title changes' do
    it 'renames file and updates README when title changes' do
      Dir.chdir(test_dir) do
        # Create initial document
        Diataxis::CLI.run(['howto', 'new', 'Original Title'])
        original_path = File.join(docs_paths[:howto], 'howto_how_to_original_title.md')

        # Update title
        content = File.read(original_path)
        new_content = content.sub(/# How to .*$/, '# How to Updated Title')
        File.write(original_path, new_content)

        # Run update
        Diataxis::CLI.run(['update', '.'])

        # Check results
        new_path = File.join(docs_paths[:howto], 'howto_how_to_updated_title.md')
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
      let(:explanation_path) { File.join(docs_paths[:explanation], 'explanation_system_architecture.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['explanation', 'new', 'System Architecture'])
        end
      end

      it 'creates explanation file with explanation prefix' do
        expect(File).to exist(explanation_path)
      end

      it 'creates explanation with correct template sections' do
        content = File.read(explanation_path)
        expected_sections = [
          '# System Architecture',
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
        expect(readme_content).to include('[System Architecture]')
        expect(readme_content).to include('### Explanations')
      end
    end

    context 'with Understanding in the title' do
      let(:explanation_path) do
        File.join(docs_paths[:explanation], 'explanation_understanding_configuration_management.md')
      end

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['explanation', 'new', 'Understanding Configuration Management'])
        end
      end

      it 'keeps Understanding as part of the title' do
        content = File.read(explanation_path)
        expect(content).to include('# Understanding Configuration Management')
      end

      it 'includes understanding in the filename slug' do
        expect(File).to exist(explanation_path)
      end
    end

    context 'when changing title' do
      let(:original_path) { File.join(docs_paths[:explanation], 'explanation_system_architecture.md') }
      let(:new_path) { File.join(docs_paths[:explanation], 'explanation_advanced_system_design.md') }

      before do
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(['explanation', 'new', 'System Architecture'])
          content = File.read(original_path)
          new_content = content.sub('# System Architecture', '# Advanced System Design')
          File.write(original_path, new_content)
          Diataxis::CLI.run(['update', '.'])
        end
      end

      it 'renames file based on new title' do
        expect(File).not_to exist(original_path)
        expect(File).to exist(new_path)
      end

      it 'updates README links' do
        readme_content = File.read(docs_paths[:readme])
        expect(readme_content).not_to include('[System Architecture]')
        expect(readme_content).to include('[Advanced System Design]')
      end

      it 'maintains correct document structure' do
        content = File.read(new_path)
        expect(content).to include('# Advanced System Design')
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

  describe 'DIATAXIS_ROOT environment variable' do
    let(:remote_dir) { File.join(File.expand_path('..', File.dirname(__FILE__)), 'tmp', 'remote_root') }
    let(:remote_config_path) { File.join(remote_dir, '.diataxis') }

    before do
      FileUtils.mkdir_p(remote_dir)
      File.write(remote_config_path, JSON.generate(Diataxis::Config::DEFAULT_CONFIG))
    end

    after do
      ENV.delete('DIATAXIS_ROOT')
      FileUtils.rm_rf(remote_dir)
    end

    it 'creates documents in DIATAXIS_ROOT directory instead of CWD' do
      ENV['DIATAXIS_ROOT'] = remote_dir
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Remote Doc'])
      end

      expect(File).to exist(File.join(remote_dir, 'docs', 'explanation_remote_doc.md'))
      expect(File).not_to exist(File.join(test_dir, 'docs', 'explanation_remote_doc.md'))
    end

    it 'raises ConfigurationError when DIATAXIS_ROOT has no .diataxis file' do
      no_config_dir = File.join(remote_dir, 'empty')
      FileUtils.mkdir_p(no_config_dir)
      ENV['DIATAXIS_ROOT'] = no_config_dir

      Dir.chdir(test_dir) do
        expect { Diataxis::CLI.run(%w[howto new Test]) }
          .to raise_error(Diataxis::ConfigurationError, /No \.diataxis configuration file found/)
      end
    end

    it 'uses CWD when DIATAXIS_ROOT is not set' do
      ENV.delete('DIATAXIS_ROOT')
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['note', 'new', 'Local Doc'])
      end

      expect(File).to exist(File.join(test_dir, 'docs', 'note_local_doc.md'))
    end

    it 'updates README at DIATAXIS_ROOT' do
      ENV['DIATAXIS_ROOT'] = remote_dir
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['tutorial', 'new', 'Remote Tutorial'])
      end

      readme = File.join(remote_dir, 'README.md')
      expect(File).to exist(readme)
      expect(File.read(readme)).to include('[Remote Tutorial]')
    end

    it 'runs update command with DIATAXIS_ROOT when no directory argument given' do
      ENV['DIATAXIS_ROOT'] = remote_dir

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(%w[explanation new Test])
      end

      readme = File.join(remote_dir, 'README.md')
      File.read(readme)

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['update'])
      end

      expect(File.read(readme)).to include('[Test]')
    end

    it 'loads config from DIATAXIS_ROOT, not CWD' do
      custom_config = { 'default' => 'docs', 'adr' => 'custom/decisions' }
      File.write(remote_config_path, JSON.generate(custom_config))
      ENV['DIATAXIS_ROOT'] = remote_dir

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['adr', 'new', 'Remote Decision'])
      end

      expect(File).to exist(File.join(remote_dir, 'custom', 'decisions', '0001-remote-decision.md'))
    end

    it 'uses DIATAXIS_ROOT for init when no directory argument given' do
      init_dir = File.join(remote_dir, 'init_target')
      FileUtils.mkdir_p(init_dir)
      FileUtils.rm_f(config_path)
      ENV['DIATAXIS_ROOT'] = init_dir

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['init'])
      end

      expect(File).to exist(File.join(init_dir, '.diataxis'))
      expect(File).not_to exist(config_path)
    end
  end

  describe '--tag / -t flag and DIATAXIS_TAG' do
    after do
      ENV.delete('DIATAXIS_TAG')
    end

    it 'creates document with YAML front matter tags from CLI flags' do
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['-t', '-jira/bolt/135', '-t', '-jira/bolt/141', 'explanation', 'new', 'Tagged Doc'])
      end

      doc_path = File.join(test_dir, 'docs', 'explanation_tagged_doc.md')
      content = File.read(doc_path)

      expect(content).to start_with("---\ntags:\n")
      expect(content).to include('  - -jira/bolt/135')
      expect(content).to include('  - -jira/bolt/141')
    end

    it 'creates document with tags from DIATAXIS_TAG env var' do
      ENV['DIATAXIS_TAG'] = '-env/tag1,-env/tag2'

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['note', 'new', 'Env Tagged'])
      end

      doc_path = File.join(test_dir, 'docs', 'note_env_tagged.md')
      content = File.read(doc_path)

      expect(content).to include('  - -env/tag1')
      expect(content).to include('  - -env/tag2')
    end

    it 'merges CLI tags with DIATAXIS_TAG and deduplicates' do
      ENV['DIATAXIS_TAG'] = '-shared,-env-only'

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['-t', '-shared', '-t', '-cli-only', 'howto', 'new', 'Merged Tags'])
      end

      doc_path = File.join(test_dir, 'docs', 'howto_how_to_merged_tags.md')
      content = File.read(doc_path)

      expect(content.scan('- -shared').length).to eq(1)
      expect(content).to include('  - -env-only')
      expect(content).to include('  - -cli-only')
    end

    it 'creates document without front matter when no tags provided' do
      ENV.delete('DIATAXIS_TAG')

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'No Tags'])
      end

      doc_path = File.join(test_dir, 'docs', 'explanation_no_tags.md')
      content = File.read(doc_path)

      expect(content).not_to start_with('---')
    end

    it 'preserves leading hyphens in tag values' do
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['-t', '-alpha-sort-tag', 'tutorial', 'new', 'Hyphen Tags'])
      end

      doc_path = File.join(test_dir, 'docs', 'tutorial_hyphen_tags.md')
      content = File.read(doc_path)

      expect(content).to include('  - -alpha-sort-tag')
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
