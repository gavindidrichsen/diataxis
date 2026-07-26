# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'
require 'stringio'
require 'tmpdir'

RSpec.describe Diataxis::CLI::DestinationResolver do
  # Outside the gem's own checkout on purpose: this repo self-hosts its docs
  # via a root .diataxis, and Config.find_config walks upward to '/'. A
  # sandbox nested under the repo would let that walk find the gem's real
  # config, masking the "no local .diataxis anywhere" cases exercised here.
  let(:base_dir) { File.join(Dir.tmpdir, 'diataxis-spec', 'destination_resolver') }
  let(:cwd) { File.join(base_dir, 'cwd') }
  let(:root_dir) { File.join(base_dir, 'root') }
  let(:cwd_config_path) { File.join(cwd, '.diataxis') }

  before do
    FileUtils.rm_rf(base_dir)
    FileUtils.mkdir_p(cwd)
    FileUtils.mkdir_p(root_dir)
  end

  after do
    FileUtils.rm_rf(base_dir)
  end

  def refuting_prompt
    ->(*_args) { raise 'prompt should not be called for this case' }
  end

  context 'when DIATAXIS_ROOT is unset and no local .diataxis exists' do
    it 'writes standalone directly into the current directory' do
      destination = described_class.resolve(root: nil, cwd: cwd, prompt: refuting_prompt)

      expect(destination.directory).to eq(cwd)
      expect(destination).to be_standalone
    end
  end

  context 'when DIATAXIS_ROOT is unset and a local .diataxis exists' do
    before { File.write(cwd_config_path, JSON.generate(Diataxis::Config::DEFAULT_CONFIG)) }

    it 'writes normally into the current directory (config-driven, README managed)' do
      destination = described_class.resolve(root: nil, cwd: cwd, prompt: refuting_prompt)

      expect(destination.directory).to eq(cwd)
      expect(destination).not_to be_standalone
    end
  end

  context 'when DIATAXIS_ROOT points at a distinct directory with no local .diataxis' do
    it 'publishes to DIATAXIS_ROOT without prompting' do
      destination = described_class.resolve(root: root_dir, cwd: cwd, prompt: refuting_prompt)

      expect(destination.directory).to eq(File.expand_path(root_dir))
      expect(destination).not_to be_standalone
    end
  end

  context 'when DIATAXIS_ROOT resolves to the same directory as CWD' do
    it 'is not treated as a distinct root, even without a local .diataxis' do
      destination = described_class.resolve(root: cwd, cwd: cwd, prompt: refuting_prompt)

      expect(destination.directory).to eq(cwd)
      expect(destination).to be_standalone
    end
  end

  context 'when DIATAXIS_ROOT is distinct AND a local .diataxis exists (genuine conflict)' do
    before { File.write(cwd_config_path, JSON.generate(Diataxis::Config::DEFAULT_CONFIG)) }

    it 'asks the injected prompt for a decision' do
      prompt = instance_double(Proc)
      allow(prompt).to receive(:call).with(cwd, File.expand_path(root_dir)).and_return(:root)

      described_class.resolve(root: root_dir, cwd: cwd, prompt: prompt)

      expect(prompt).to have_received(:call).with(cwd, File.expand_path(root_dir))
    end

    it 'writes to CWD when the prompt answers :local' do
      destination = described_class.resolve(root: root_dir, cwd: cwd, prompt: ->(*_) { :local })

      expect(destination.directory).to eq(cwd)
      expect(destination).not_to be_standalone
    end

    it 'writes to DIATAXIS_ROOT when the prompt answers :root' do
      destination = described_class.resolve(root: root_dir, cwd: cwd, prompt: ->(*_) { :root })

      expect(destination.directory).to eq(File.expand_path(root_dir))
      expect(destination).not_to be_standalone
    end

    it 'defaults to :root via the real interactive prompt when the input is blank' do
      allow($stdin).to receive_messages(tty?: true, gets: "\n")

      destination = nil
      output = capture_stderr_and_stdout { destination = described_class.resolve(root: root_dir, cwd: cwd) }

      expect(destination.directory).to eq(File.expand_path(root_dir))
      expect(output).to include('DIATAXIS_ROOT is set to')
    end

    it 'honours the real interactive prompt when the user types "local"' do
      allow($stdin).to receive_messages(tty?: true, gets: "local\n")

      destination = nil
      capture_stderr_and_stdout { destination = described_class.resolve(root: root_dir, cwd: cwd) }

      expect(destination.directory).to eq(cwd)
    end

    it 'raises a ConfigurationError instead of blocking when stdin is not a TTY (non-interactive)' do
      allow($stdin).to receive(:tty?).and_return(false)

      expect { described_class.resolve(root: root_dir, cwd: cwd) }
        .to raise_error(Diataxis::ConfigurationError, /input isn't interactive.*--here or --root/)
    end
  end

  context 'with an explicit override' do
    it 'forces CWD when override is :local, regardless of DIATAXIS_ROOT or local config' do
      destination = described_class.resolve(root: root_dir, cwd: cwd, override: :local, prompt: refuting_prompt)

      expect(destination.directory).to eq(cwd)
      expect(destination).to be_standalone
    end

    it 'forces DIATAXIS_ROOT when override is :root, even without a local .diataxis conflict' do
      destination = described_class.resolve(root: root_dir, cwd: cwd, override: :root, prompt: refuting_prompt)

      expect(destination.directory).to eq(File.expand_path(root_dir))
      expect(destination).not_to be_standalone
    end

    it 'raises a ConfigurationError when override is :root but DIATAXIS_ROOT is unset' do
      expect { described_class.resolve(root: nil, cwd: cwd, override: :root, prompt: refuting_prompt) }
        .to raise_error(Diataxis::ConfigurationError, /DIATAXIS_ROOT is not set/)
    end
  end

  def capture_stderr_and_stdout
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    yield
    $stdout.string + $stderr.string
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end
end
