# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative 'config'
require_relative 'document_registry'

module Diataxis
  class Document
    attr_reader :title, :filename

    class << self
      attr_reader :type_config

      def register_type(command:, prefix:, category:, config_key:, readme_section:, slug_separator: '_', template: nil,
                        section_tag: nil, **_ignored)
        @type_config = {
          command: command,
          prefix: prefix,
          category: category,
          config_key: config_key,
          readme_section: readme_section,
          slug_separator: slug_separator,
          template: template,
          section_tag: section_tag
        }
        DocumentRegistry.register(command, self)
      end

      def pattern(config_root = '.')
        config = Config.load(config_root)
        type_dir = config[type_config[:config_key]] || config['default']
        File.join(config_root, type_dir, '**', "#{type_config[:prefix]}_*.md")
      end

      def generate_filename_from_file(filepath)
        title = MarkdownUtils.extract_title(filepath)
        return nil if title.nil?

        sep = type_config[:slug_separator]
        slug = title.downcase.gsub(/[^a-z0-9]+/, sep).gsub(/^#{Regexp.escape(sep)}|#{Regexp.escape(sep)}$/, '')
        "#{type_config[:prefix]}#{sep}#{slug}.md"
      end

      def generate_filename_from_existing(filepath)
        current_name = File.basename(filepath)
        new_filename = generate_filename_from_file(filepath)
        return nil if new_filename.nil? || current_name == new_filename

        new_filename
      end

      def matches_filename_pattern?(filename)
        filename.match?(/^#{Regexp.escape(type_config[:prefix])}_.*\.md$/)
      end

      def readme_section_title
        type_config[:readme_section]
      end

      def config_key
        type_config[:config_key]
      end

      def format_readme_entry(title, relative_path, _filepath)
        "* [#{title}](#{relative_path})"
      end

      def find_files(config_root = '.')
        search_pattern = File.expand_path(pattern(config_root), config_root)
        files = Dir.glob(search_pattern).sort
        Diataxis.logger.info "Found #{files.length} #{type_config[:section_tag] || name&.split('::')&.last || 'unknown'} files matching #{search_pattern}"
        files
      end
    end

    def initialize(title, directory = '.')
      @title = customize_title(title)
      @directory = get_configured_directory(directory)
      @filename = File.join(@directory, generate_filename)
      custom = customize_filename(@title, @directory)
      @filename = custom if custom
    end

    def create
      File.write(@filename, content)
      Diataxis.logger.info "Created new #{type}: #{@filename}"
    end

    protected

    def type
      self.class.type_config[:command]
    end

    def customize_title(title)
      title
    end

    def customize_filename(_title, _dir)
      nil
    end

    def customize_content(content)
      content
    end

    def generate_filename
      cfg = self.class.type_config
      sep = cfg[:slug_separator]
      slug = @title.downcase.gsub(/[^a-z0-9]+/, sep).gsub(/^#{Regexp.escape(sep)}|#{Regexp.escape(sep)}$/, '')
      "#{cfg[:prefix]}#{sep}#{slug}.md"
    end

    def content
      customize_content(TemplateLoader.load_template(self.class, @title))
    end

    private

    def get_configured_directory(default_dir)
      config = Config.load(default_dir)
      configured_dir = config[self.class.type_config[:config_key]] || default_dir

      unless Pathname.new(configured_dir).absolute?
        config_dir = File.dirname(Config.find_config(default_dir) || '')
        configured_dir = File.expand_path(configured_dir, config_dir)
      end

      FileUtils.mkdir_p(configured_dir) unless File.directory?(configured_dir)
      configured_dir
    end
  end
end
