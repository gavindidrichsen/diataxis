# frozen_string_literal: true

require 'json'

module Diataxis
  # Configuration manager for Diataxis
  # Handles reading and writing configuration settings from .diataxis file
  class Config
    CONFIG_FILE = '.diataxis'
    DEFAULT_DOCS_ROOT = 'docs'
    DEFAULT_CONFIG = {
      'default' => DEFAULT_DOCS_ROOT,
      'readme' => 'README.md',
      'adr' => "#{DEFAULT_DOCS_ROOT}/adr",
      'projects' => "#{DEFAULT_DOCS_ROOT}/_gtd"
    }.freeze

    def self.load(directory = '.')
      config_path = find_config(directory)
      if config_path
        user_config = JSON.parse(File.read(config_path))
        DEFAULT_CONFIG.merge(user_config)
      else
        DEFAULT_CONFIG
      end
    end

    def self.create(directory = '.', config = DEFAULT_CONFIG)
      config_path = File.join(directory, CONFIG_FILE)
      File.write(config_path, "#{JSON.pretty_generate(config)}\n")
      Diataxis.logger.info "Created #{config_path} with default configuration"
    end

    def self.find_config(start_dir)
      current_dir = File.expand_path(start_dir)
      while current_dir != '/'
        config_path = File.join(current_dir, CONFIG_FILE)
        return config_path if File.exist?(config_path)

        current_dir = File.dirname(current_dir)
      end
      nil
    end

    # Get path for a document type
    # Precedence: config[type_key] (includes .diataxis overrides) > config['default']
    def self.path_for(type_key)
      config = load
      config[type_key] || config['default']
    end
  end
end
