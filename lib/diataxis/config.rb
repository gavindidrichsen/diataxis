# frozen_string_literal: true

require 'json'
require_relative 'errors'

module Diataxis
  # Configuration manager for Diataxis
  # Handles reading and writing configuration settings from .diataxis file
  class Config
    CONFIG_FILE = '.diataxis'
    DEFAULT_DOCS_ROOT = 'docs'
    DEFAULT_CONFIG = {
      'default' => DEFAULT_DOCS_ROOT,
      'adr' => "#{DEFAULT_DOCS_ROOT}/adr",
      'projects' => "#{DEFAULT_DOCS_ROOT}/_gtd"
    }.freeze

    # What `dia init` writes: an empty object, so every default applies until an
    # override is added (see the README for the keys).
    TEMPLATE = "{}\n"

    def self.load(directory = '.')
      config_path = find_config(directory)
      return DEFAULT_CONFIG unless config_path

      DEFAULT_CONFIG.merge(parse(config_path))
    end

    def self.create(directory = '.')
      config_path = File.join(directory, CONFIG_FILE)
      File.write(config_path, TEMPLATE)
      Diataxis.logger.info "Created #{config_path} (an empty object: every default applies)"
    end

    # Reads a .diataxis file (a JSON object). A file with nothing in it means `{}`.
    def self.parse(config_path)
      text = File.read(config_path).strip
      return {} if text.empty?

      parsed = JSON.parse(text)
      return parsed if parsed.is_a?(Hash)

      raise ConfigurationError.new("#{config_path} must contain a JSON object, not #{parsed.class}.", config_path: config_path)
    rescue JSON::ParserError => e
      raise ConfigurationError.new("#{config_path} is not valid JSON: #{e.message.lines.first.to_s.strip}", config_path: config_path)
    end
    private_class_method :parse

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
    def self.path_for(type_key, directory = '.')
      config = load(directory)
      config[type_key] || config['default']
    end
  end
end
