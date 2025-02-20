require 'json'

module Diataxis
  class Config
    CONFIG_FILE = '.diataxis'
    DEFAULT_CONFIG = {
      'readme' => 'README.md',
      'howtos' => '.',
      'tutorials' => '.',
      'adr' => 'exp/adr'
    }.freeze

    def self.load(directory = '.')
      config_path = find_config(directory)
      if config_path
        JSON.parse(File.read(config_path))
      else
        DEFAULT_CONFIG
      end
    end

    def self.create(directory = '.', config = DEFAULT_CONFIG)
      config_path = File.join(directory, CONFIG_FILE)
      File.write(config_path, JSON.pretty_generate(config))
      puts "Created #{config_path} with default configuration"
    end

    private

    def self.find_config(start_dir)
      current_dir = File.expand_path(start_dir)
      while current_dir != '/'
        config_path = File.join(current_dir, CONFIG_FILE)
        return config_path if File.exist?(config_path)
        current_dir = File.dirname(current_dir)
      end
      nil
    end
  end
end
