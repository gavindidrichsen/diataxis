# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'
require 'stringio'
require 'tmpdir'

RSpec.describe Diataxis do
  # Deliberately OUTSIDE the gem's own checkout: this repo has its own root
  # .diataxis (it self-hosts its docs), and Config.find_config walks upward
  # to '/'. A sandbox nested under the repo (e.g. tmp/test) would let that
  # walk silently find the gem's real .diataxis whenever a test removes its
  # own local config, masking the "no config anywhere" scenarios this suite
  # exercises (see the 'without configuration file' and DestinationResolver
  # standalone-routing tests below).
  let(:test_dir) { File.join(Dir.tmpdir, 'diataxis-spec', 'test') }
  let(:docs_paths) do
    {
      docs: File.join(test_dir, 'docs'),
      howto: File.join(test_dir, 'docs'),
      tutorial: File.join(test_dir, 'docs'),
      adr: File.join(test_dir, 'docs/adr'),
      wow: File.join(test_dir, 'docs'),
      explanation: File.join(test_dir, 'docs'),
      project: File.join(test_dir, 'docs')
    }
  end
  let(:config_path) { File.join(test_dir, '.diataxis') }

  # Drive the CLI with the test's root injected, so document-creating examples
  # are hermetic regardless of any ambient DIATAXIS_ROOT / DIATAXIS_TAGS. The
  # dedicated env-var describe blocks below instead call Diataxis::CLI.run
  # directly, to exercise the real environment resolution.
  def run_cli(args)
    Diataxis::CLI.run(args, root: test_dir, default_tags: nil)
  end

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
          run_cli(['howto', 'new', 'Test Document'])
        end

        expect(File).to exist(File.join(docs_paths[:howto], 'howto_how_to_test_document.md'))
      end
    end

    context 'default configuration contents' do
      it 'only carries the default root, ADR and project locations' do
        expect(Diataxis::Config::DEFAULT_CONFIG.keys).to contain_exactly('default', 'adr', 'projects')
      end

      it 'puts WoW documents in the default docs directory' do
        Dir.chdir(test_dir) { run_cli(['wow', 'new', 'Branch Discipline']) }

        expect(File).to exist(File.join(docs_paths[:docs], 'wow_branch_discipline.md'))
      end

      it 'still honours an explicit wow location' do
        File.write(config_path, JSON.generate('default' => 'docs', 'wow' => 'docs/ways'))
        Dir.chdir(test_dir) { run_cli(['wow', 'new', 'Branch Discipline']) }

        expect(File).to exist(File.join(test_dir, 'docs', 'ways', 'wow_branch_discipline.md'))
      end
    end

    context 'with custom configuration' do
      let(:custom_dir) { File.join(test_dir, 'custom') }

      before do
        config = {
          'howtos' => 'custom/howtos',
          'tutorials' => 'custom/learn',
          'adr' => 'custom/decisions'
        }
        FileUtils.mkdir_p(File.dirname(config_path))
        File.write(config_path, JSON.generate(config))
      end

      it 'creates documents in configured locations' do
        Dir.chdir(test_dir) do
          run_cli(['howto', 'new', 'Test Custom Path'])
        end

        expect(File).to exist(File.join(custom_dir, 'howtos/howto_how_to_test_custom_path.md'))
      end
    end

    context 'with invalid configuration' do
      before do
        FileUtils.mkdir_p(File.dirname(config_path))
        File.write(config_path, '{invalid json}')
      end

      it 'shows clear error message' do
        Dir.chdir(test_dir) do
          expect { run_cli(['howto', 'new', 'Test Error']) }
            .to raise_error(Diataxis::ConfigurationError, /is not valid JSON/)
        end
      end
    end

    context 'without configuration file and no DIATAXIS_ROOT (standalone routing)' do
      before do
        # Remove the config file that was created in the before block
        FileUtils.rm_f(config_path)
      end

      it 'writes the document directly into the current directory, bypassing .diataxis subdirectories' do
        Dir.chdir(test_dir) do
          run_cli(['project', 'new', 'Test Project'])
        end

        expect(File).to exist(File.join(test_dir, 'project_test_project.md'))
        expect(File).not_to exist(File.join(test_dir, 'docs', '_gtd', 'project_test_project.md'))
      end
    end
  end

  describe 'document creation' do
    context 'creating how-tos' do
      it 'creates how-to with correct template' do
        Dir.chdir(test_dir) do
          run_cli(['howto', 'new', 'Configure System'])
        end

        howto_path = File.join(docs_paths[:howto], 'howto_how_to_configure_system.md')
        expect(File).to exist(howto_path)

        content = File.read(howto_path)
        expect(content.downcase).to include('# how to configure system')
      end
    end

    context 'creating tutorial' do
      it 'creates tutorial with correct template' do
        Dir.chdir(test_dir) do
          run_cli(['tutorial', 'new', 'Getting Started'])
        end

        tutorial_path = File.join(docs_paths[:tutorial], 'tutorial_getting_started.md')
        expect(File).to exist(tutorial_path)

        content = File.read(tutorial_path)
        expect(content).to include('# Getting Started')
      end
    end

    context 'creating ADR' do
      it 'creates ADR with correct numbering' do
        Dir.chdir(test_dir) do
          run_cli(['adr', 'new', 'Use PostgreSQL Database'])
        end

        adr_path = File.join(docs_paths[:adr], '0001-use-postgresql-database.md')
        expect(File).to exist(adr_path)

        content = File.read(adr_path)
        expect(content).to include('# 0001. Use PostgreSQL Database')
      end
    end

    context 'creating WoW' do
      let(:wow_path) { File.join(docs_paths[:wow], 'wow_branch_discipline.md') }

      before do
        Dir.chdir(test_dir) do
          run_cli(['wow', 'new', 'Branch Discipline'])
        end
      end

      it 'creates WoW file with correct filename prefix' do
        expect(File).to exist(wow_path)
      end

      it 'creates WoW with correct template structure' do
        content = File.read(wow_path)
        aggregate_failures do
          expect(content).to include('# Branch Discipline')
          expect(content).to include('## Context')
          expect(content).to include('## Decision')
          expect(content).to include('## Consequences')
        end
      end
    end

    context 'creating project' do
      let(:project_dir) { File.join(test_dir, 'docs/_gtd') }

      before do
        Dir.chdir(test_dir) do
          run_cli(['project', 'new', 'Sprint Planning'])
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
          expect(content).to include('## Problem')
          expect(content).to include('## Next Actions')
          expect(content).to include('## Key Concepts')
        end
      end
    end

    context 'creating pr' do
      let(:pr_path) { File.join(docs_paths[:explanation], 'pr_fix_login_bug.md') }

      before do
        Dir.chdir(test_dir) do
          run_cli(['pr', 'new', 'Fix Login Bug'])
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
    end

    context 'creating fivewhy' do
      let(:fivewhy_path) { File.join(docs_paths[:explanation], 'fivewhy_deploy_script_silently_failed.md') }
      let(:fivewhy_expected_sections) do
        [
          '# Deploy Script Silently Failed',
          '## Purpose',
          '## Background',
          '## Root Cause Analysis',
          '### Why did [symptom] happen?',
          '**Why This Tool**:',
          '**Investigation**:',
          '**Evidence**:',
          '**Next Problem**:',
          '## Root Cause',
          '**Proof**:',
          '**Known Issue?**:',
          '## Solution',
          '**Source**:',
          '## Related Topics'
        ]
      end

      before do
        Dir.chdir(test_dir) do
          run_cli(['fivewhy', 'new', 'Deploy Script Silently Failed'])
        end
      end

      it 'creates fivewhy file with fivewhy prefix' do
        expect(File).to exist(fivewhy_path)
      end

      it 'creates fivewhy with correct template structure' do
        content = File.read(fivewhy_path)

        aggregate_failures do
          fivewhy_expected_sections.each do |section|
            expect(content).to include(section)
          end
        end
      end
    end
  end

  describe 'document title changes' do
    it 'renames file when title changes' do
      Dir.chdir(test_dir) do
        # Create initial document
        run_cli(['howto', 'new', 'Original Title'])
        original_path = File.join(docs_paths[:howto], 'howto_how_to_original_title.md')

        # Update title
        content = File.read(original_path)
        new_content = content.sub(/# How to .*$/, '# How to Updated Title')
        File.write(original_path, new_content)

        # Run update
        run_cli(['update', '.'])

        # Check results
        new_path = File.join(docs_paths[:howto], 'howto_how_to_updated_title.md')
        expect(File).not_to exist(original_path)
        expect(File).to exist(new_path)
      end
    end
  end

  describe 'explanation document creation' do
    context 'with basic title' do
      let(:explanation_path) { File.join(docs_paths[:explanation], 'explanation_system_architecture.md') }

      before do
        Dir.chdir(test_dir) do
          run_cli(['explanation', 'new', 'System Architecture'])
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
          '- What does this reveal about how the domain actually works?',
          '- What are the core concepts, and how do the pieces fit together?',
          '- Why does the system behave this way',
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
    end

    context 'with Understanding in the title' do
      let(:explanation_path) do
        File.join(docs_paths[:explanation], 'explanation_understanding_configuration_management.md')
      end

      before do
        Dir.chdir(test_dir) do
          run_cli(['explanation', 'new', 'Understanding Configuration Management'])
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
          run_cli(['explanation', 'new', 'System Architecture'])
          content = File.read(original_path)
          new_content = content.sub('# System Architecture', '# Advanced System Design')
          File.write(original_path, new_content)
          run_cli(['update', '.'])
        end
      end

      it 'renames file based on new title' do
        expect(File).not_to exist(original_path)
        expect(File).to exist(new_path)
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
          'howtos' => 'docs/how-to',
          'adr' => 'docs/references/adr'
        }
        File.write(File.join(other_repo_dir, '.diataxis'), JSON.generate(other_config))

        # Create documents in both repositories
        Dir.chdir(test_dir) do
          run_cli(['adr', 'new', 'Main Repo Decision'])
        end

        # This document belongs to the *other* repo, so inject that root
        # explicitly rather than the default test_dir used by run_cli.
        Dir.chdir(other_repo_dir) do
          Diataxis::CLI.run(['adr', 'new', 'Other Repo Decision'], root: other_repo_dir)
        end
      end

      it 'only renames documents that belong to the current repository' do
        main_adr = File.join(docs_paths[:adr], '0001-main-repo-decision.md')
        other_adr = File.join(other_docs_paths[:adr], '0001-other-repo-decision.md')
        { main_adr => 'Main Repo Decision', other_adr => 'Other Repo Decision' }.each do |file, old_title|
          File.write(file, File.read(file).sub("# 0001. #{old_title}", '# 0001. Retitled Decision'))
        end

        Dir.chdir(test_dir) { run_cli(['update', '.']) }

        expect(File).to exist(File.join(docs_paths[:adr], '0001-retitled-decision.md'))
        expect(File).to exist(other_adr)
      end

      it 'respects configured paths when searching for documents' do
        misplaced = File.join(test_dir, 'wrong/path/0002-misplaced-decision.md')
        FileUtils.mkdir_p(File.dirname(misplaced))
        File.write(misplaced, "# 2. Retitled Misplaced\n")

        Dir.chdir(test_dir) { run_cli(['update', '.']) }

        expect(File).to exist(misplaced)
      end
    end
  end

  describe 'update target' do
    let(:stale) { File.join(docs_paths[:docs], 'explanation_old_name.md') }

    before do
      FileUtils.mkdir_p(docs_paths[:docs])
      File.write(stale, "# A Better Name\n")
    end

    it 'updates the directory it is given, wherever it is run from' do
      Dir.mktmpdir('diataxis-elsewhere') do |elsewhere|
        Dir.chdir(elsewhere) { Diataxis::CLI.run(['update', test_dir], root: nil, default_tags: nil) }
      end

      expect(File).to exist(File.join(docs_paths[:docs], 'explanation_a_better_name.md'))
    end

    it 'updates DIATAXIS_ROOT when no directory is given' do
      Dir.mktmpdir('diataxis-elsewhere') do |elsewhere|
        Dir.chdir(elsewhere) { run_cli(['update']) }
      end

      expect(File).to exist(File.join(docs_paths[:docs], 'explanation_a_better_name.md'))
    end

    it 'fails when no directory is given and DIATAXIS_ROOT is not set' do
      Dir.chdir(test_dir) do
        expect { Diataxis::CLI.run(['update'], root: nil, default_tags: nil) }
          .to raise_error(Diataxis::UsageError, /DIATAXIS_ROOT is not set/)
      end
      expect(File).to exist(stale)
    end

    it 'fails from a subdirectory and names the .diataxis root that governs it' do
      Dir.chdir(docs_paths[:docs]) do
        expect { Diataxis::CLI.run(['update', '.'], root: nil, default_tags: nil) }
          .to raise_error(Diataxis::ConfigurationError, /Found .*\.diataxis; run `dia update .*`/)
      end
      expect(File).to exist(stale)
    end

    it 'fails for a directory with no .diataxis anywhere above it' do
      Dir.mktmpdir('diataxis-bare') do |bare|
        expect { Diataxis::CLI.run(['update', bare], root: nil, default_tags: nil) }
          .to raise_error(Diataxis::ConfigurationError, /not a \.diataxis root.*Run `dia init` there first/)
      end
    end

    it 'fails when DIATAXIS_ROOT points at a directory without a .diataxis' do
      Dir.mktmpdir('diataxis-bare') do |bare|
        expect { Diataxis::CLI.run(['update'], root: bare, default_tags: nil) }
          .to raise_error(Diataxis::ConfigurationError, /not a \.diataxis root/)
      end
    end
  end

  describe 'directory handling' do
    it 'creates necessary directories when missing' do
      Dir.chdir(test_dir) do
        run_cli(['howto', 'new', 'Test Document'])
      end

      expect(Dir).to exist(docs_paths[:docs])
      expect(Dir).to exist(docs_paths[:howto])
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
      expect(e.usage_message).to include('wow new "Title"')
      expect(e.usage_message).to include('explanation new "Title"')
      expect(e.usage_message).to include('project new "Title"')
      expect(e.usage_message).to include('pr new "Title"')
    end

    it 'shows version information' do
      output = capture_stdout do
        Diataxis::CLI.run(['--version'])
      end
      expect(output).to include('diataxis version')
      expect(output).to include(Diataxis::VERSION)
    end

    it 'prints usage for --help and returns without raising' do
      output = capture_stdout do
        expect { Diataxis::CLI.run(['--help']) }.not_to raise_error
      end
      expect(output).to include('Usage: diataxis [options] <command>')
    end

    it 'lists the --stdout flag in the help text' do
      Diataxis::CLI.run([])
    rescue Diataxis::UsageError => e
      expect(e.usage_message).to include('--stdout')
    end
  end

  describe '--stdout flag' do
    it 'prints the rendered template to stdout without writing a file' do
      output = capture_stdout do
        Dir.chdir(test_dir) { run_cli(['howto', 'new', 'Stdout Demo', '--stdout']) }
      end

      expect(output.downcase).to include('# how to stdout demo')
      expect(File).not_to exist(File.join(docs_paths[:howto], 'howto_how_to_stdout_demo.md'))
    end

    it 'prepends tags to the printed template' do
      output = capture_stdout do
        Dir.chdir(test_dir) { run_cli(['explanation', 'new', 'Tagged', '--stdout', '--tag', '-foo']) }
      end

      expect(output).to include("---\ntags:\n  - -foo\n---")
    end

    it 'works without a .diataxis config file present' do
      FileUtils.rm_f(config_path)

      output = capture_stdout do
        Dir.chdir(test_dir) { run_cli(['explanation', 'new', 'No Config Needed', '--stdout']) }
      end

      expect(output).to include('# No Config Needed')
    end
  end

  describe 'DIATAXIS_ROOT environment variable' do
    let(:remote_dir) { File.join(Dir.tmpdir, 'diataxis-spec', 'remote_root') }
    let(:remote_config_path) { File.join(remote_dir, '.diataxis') }

    # test_dir already has its own local .diataxis (set up in the outer
    # `before`), so pointing DIATAXIS_ROOT at a distinct remote_dir is the
    # genuine-conflict case (see DestinationResolver / ADR-0018). These specs
    # inject a deterministic `choose_destination` answering :root, rather than
    # relying on the real prompt reading $stdin (which would hang in an
    # interactive terminal), to keep asserting the historical "ROOT wins" behaviour.
    def choose_root
      ->(_local_dir, _root_dir) { :root }
    end

    before do
      FileUtils.mkdir_p(remote_dir)
      File.write(remote_config_path, JSON.generate(Diataxis::Config::DEFAULT_CONFIG))
    end

    after do
      ENV.delete('DIATAXIS_ROOT')
      FileUtils.rm_rf(remote_dir)
    end

    it 'creates documents in DIATAXIS_ROOT directory instead of CWD when the conflict is resolved in favour of root' do
      ENV['DIATAXIS_ROOT'] = remote_dir
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Remote Doc'], choose_destination: choose_root)
      end

      expect(File).to exist(File.join(remote_dir, 'docs', 'explanation_remote_doc.md'))
      expect(File).not_to exist(File.join(test_dir, 'docs', 'explanation_remote_doc.md'))
    end

    it 'asks for a decision via the injected prompt when both DIATAXIS_ROOT and a local .diataxis are present' do
      ENV['DIATAXIS_ROOT'] = remote_dir
      # Dir.pwd (the resolver's default `cwd`) resolves symlinks after chdir
      # (e.g. /var -> /private/var on macOS), so compare against the realpath.
      real_test_dir = File.realpath(test_dir)
      prompt = instance_double(Proc)
      allow(prompt).to receive(:call).with(real_test_dir, File.expand_path(remote_dir)).and_return(:root)

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Ambiguous Doc'], choose_destination: prompt)
      end

      expect(prompt).to have_received(:call).with(real_test_dir, File.expand_path(remote_dir))
    end

    it 'publishes to DIATAXIS_ROOT using its default config, without prompting, when CWD has no local .diataxis' do
      FileUtils.rm_f(config_path)
      # A sibling of remote_dir, not nested under it -- nesting under remote_dir
      # (which has its own .diataxis) would let the upward walk find *that*
      # config instead of exercising the "no .diataxis anywhere" fallback.
      no_config_dir = File.join(Dir.tmpdir, 'diataxis-spec', 'root_without_config')
      FileUtils.rm_rf(no_config_dir)
      FileUtils.mkdir_p(no_config_dir)
      ENV['DIATAXIS_ROOT'] = no_config_dir

      begin
        Dir.chdir(test_dir) do
          Diataxis::CLI.run(%w[howto new Test], choose_destination: ->(*) { raise 'must not prompt' })
        end

        expect(File).to exist(File.join(no_config_dir, 'docs', 'howto_how_to_test.md'))
      ensure
        FileUtils.rm_rf(no_config_dir)
      end
    end

    it 'uses CWD when DIATAXIS_ROOT is not set' do
      ENV.delete('DIATAXIS_ROOT')
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Local Doc'])
      end

      expect(File).to exist(File.join(test_dir, 'docs', 'explanation_local_doc.md'))
    end

    it 'loads config from DIATAXIS_ROOT, not CWD' do
      custom_config = { 'default' => 'docs', 'adr' => 'custom/decisions' }
      File.write(remote_config_path, JSON.generate(custom_config))
      ENV['DIATAXIS_ROOT'] = remote_dir

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['adr', 'new', 'Remote Decision'], choose_destination: choose_root)
      end

      expect(File).to exist(File.join(remote_dir, 'custom', 'decisions', '0001-remote-decision.md'))
    end

    it 'forces DIATAXIS_ROOT via the --root flag without prompting' do
      ENV['DIATAXIS_ROOT'] = remote_dir
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Forced Root Doc', '--root'])
      end

      expect(File).to exist(File.join(remote_dir, 'docs', 'explanation_forced_root_doc.md'))
    end

    it 'forces the current directory via the --here flag without prompting' do
      ENV['DIATAXIS_ROOT'] = remote_dir
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Forced Local Doc', '--here'])
      end

      expect(File).to exist(File.join(test_dir, 'docs', 'explanation_forced_local_doc.md'))
      expect(File).not_to exist(File.join(remote_dir, 'docs', 'explanation_forced_local_doc.md'))
    end

    it 'writes standalone with --here when DIATAXIS_ROOT is set but CWD has no local .diataxis' do
      FileUtils.rm_f(config_path)
      ENV['DIATAXIS_ROOT'] = remote_dir
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Forced Local Standalone', '--here'])
      end

      expect(File).to exist(File.join(test_dir, 'explanation_forced_local_standalone.md'))
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

  describe '--tag / -t flag and DIATAXIS_TAGS' do
    after do
      ENV.delete('DIATAXIS_TAGS')
    end

    it 'creates document with YAML front matter tags from CLI flags' do
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['-t', '-jira/bolt/135', '-t', '-jira/bolt/141', 'explanation', 'new', 'Tagged Doc'],
                          root: test_dir)
      end

      doc_path = File.join(test_dir, 'docs', 'explanation_tagged_doc.md')
      content = File.read(doc_path)

      expect(content).to start_with("---\ntags:\n")
      expect(content).to include('  - -jira/bolt/135')
      expect(content).to include('  - -jira/bolt/141')
    end

    it 'creates document with tags from DIATAXIS_TAGS env var' do
      ENV['DIATAXIS_TAGS'] = '-env/tag1,-env/tag2'

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Env Tagged'], root: test_dir)
      end

      doc_path = File.join(test_dir, 'docs', 'explanation_env_tagged.md')
      content = File.read(doc_path)

      expect(content).to include('  - -env/tag1')
      expect(content).to include('  - -env/tag2')
    end

    it 'merges CLI tags with DIATAXIS_TAGS and deduplicates' do
      ENV['DIATAXIS_TAGS'] = '-shared,-env-only'

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['-t', '-shared', '-t', '-cli-only', 'howto', 'new', 'Merged Tags'], root: test_dir)
      end

      doc_path = File.join(test_dir, 'docs', 'howto_how_to_merged_tags.md')
      content = File.read(doc_path)

      expect(content.scan('- -shared').length).to eq(1)
      expect(content).to include('  - -env-only')
      expect(content).to include('  - -cli-only')
    end

    it 'creates document without front matter when no tags provided' do
      ENV.delete('DIATAXIS_TAGS')

      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'No Tags'], root: test_dir)
      end

      doc_path = File.join(test_dir, 'docs', 'explanation_no_tags.md')
      content = File.read(doc_path)

      expect(content).not_to start_with('---')
    end

    it 'preserves leading hyphens in tag values' do
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['-t', '-alpha-sort-tag', 'tutorial', 'new', 'Hyphen Tags'], root: test_dir)
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
