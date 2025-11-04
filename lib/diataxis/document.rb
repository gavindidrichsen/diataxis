# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative 'config'

module Diataxis
  # Base document class following Template Method pattern
  class Document
    attr_reader :title, :filename

    def initialize(title, directory = '.')
      @title = title
      @directory = get_configured_directory(directory)
      @filename = File.join(@directory, generate_filename)
    end

    def get_configured_directory(default_dir)
      config = Config.load(default_dir)
      doc_type = type.downcase
      config_key = doc_type == 'howto' ? 'howtos' : "#{doc_type}s"
      configured_dir = config[config_key] || default_dir

      # If configured_dir is relative, make it relative to the config file location
      unless Pathname.new(configured_dir).absolute?
        config_dir = File.dirname(Config.find_config(default_dir) || '')
        configured_dir = File.expand_path(configured_dir, config_dir)
      end

      FileUtils.mkdir_p(configured_dir) unless File.directory?(configured_dir)
      configured_dir
    end

    def create
      File.write(@filename, content)
      puts "Created new #{type}: #{@filename}"
    end

    def self.pattern
      raise NotImplementedError, "#{name} must implement pattern"
    end

    protected

    def type
      self.class.name.split('::').last.downcase
    end

    def generate_filename
      sanitize_filename(title)
    end

    def content
      raise NotImplementedError, "#{self.class.name} must implement content"
    end

    private

    def sanitize_filename(title)
      # Always strip any existing prefixes for consistency
      title_without_prefix = title.sub(/^(How to|Understanding)\s+/i, '')

      # Determine the correct prefix based on document type
      prefix = case self.class.name.split('::').last
               when 'HowTo' then 'how_to'
               when 'Explanation' then 'understanding'
               else type
               end

      # Create filename with prefix and sanitized title
      "#{prefix}_#{title_without_prefix.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')}.md"
    end
  end
end
