# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'

RSpec.describe Diataxis::Config do
  # Outside the gem checkout so find_config cannot walk up into its own .diataxis.
  let(:dir) { File.join(Dir.tmpdir, 'diataxis-config-spec') }
  let(:config_file) { File.join(dir, '.diataxis') }

  before do
    FileUtils.rm_rf(dir)
    FileUtils.mkdir_p(dir)
  end

  after { FileUtils.rm_rf(dir) }

  def load_with(contents)
    File.write(config_file, contents)
    described_class.load(dir)
  end

  describe '.load' do
    it 'treats an empty file as an empty object, so every default applies' do
      expect(load_with('')).to eq(described_class::DEFAULT_CONFIG)
    end

    it 'treats a file of only comments as an empty object' do
      expect(load_with("// nothing to override\n// here\n")).to eq(described_class::DEFAULT_CONFIG)
    end

    it 'applies every default for an empty object' do
      expect(load_with('{}')).to eq(described_class::DEFAULT_CONFIG)
    end

    it 'ignores full-line // comments above and inside the object' do
      config = load_with(%(// a sample\n{\n  // move the docs\n  "default": "notes"\n}\n))

      expect(config['default']).to eq('notes')
    end

    it 'merges overrides over the defaults' do
      config = load_with('{"adr": "decisions"}')

      expect(config).to include('adr' => 'decisions', 'default' => 'docs', 'projects' => 'docs/_gtd')
    end

    it 'does not treat // inside a value as a comment' do
      expect(load_with(%({"default": "https://example.test/docs"}))['default']).to eq('https://example.test/docs')
    end

    it 'raises a ConfigurationError naming the file for invalid JSON' do
      expect { load_with('{ not json') }
        .to raise_error(Diataxis::ConfigurationError, /#{Regexp.escape(config_file)} is not valid JSON/)
    end

    it 'raises a ConfigurationError when the JSON is not an object' do
      expect { load_with('[1, 2]') }.to raise_error(Diataxis::ConfigurationError, /must contain a JSON object/)
    end

    it 'returns the defaults when there is no .diataxis anywhere' do
      FileUtils.rm_f(config_file)

      expect(described_class.load(dir)).to eq(described_class::DEFAULT_CONFIG)
    end
  end

  describe '.create' do
    it 'writes a commented sample above an empty object that loads as the defaults' do
      described_class.create(dir)

      contents = File.read(config_file)
      expect(contents).to include('// dia reads this file as JSON').and include('"adr": "docs/adr"')
      expect(contents.lines.last.strip).to eq('{}')
      expect(described_class.load(dir)).to eq(described_class::DEFAULT_CONFIG)
    end
  end
end
