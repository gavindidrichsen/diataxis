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
        default_dir = config['default']
        search_dir = type_dir.start_with?("#{default_dir}/") ? default_dir : type_dir
        File.join(config_root, search_dir, '**', "#{type_config[:prefix]}_*.md")
      end

      # Turns a title into the filename slug, e.g. "How to Fly" -> "how_to_fly".
      def slugify(text)
        sep = type_config[:slug_separator]
        text.downcase.gsub(/[^a-z0-9]+/, sep).gsub(/^#{Regexp.escape(sep)}|#{Regexp.escape(sep)}$/, '')
      end

      def generate_filename_from_file(filepath)
        title = MarkdownUtils.extract_title(filepath)
        return nil if title.nil?

        "#{type_config[:prefix]}#{type_config[:slug_separator]}#{slugify(title)}.md"
      end

      # True when `title` slugifies to the name the file already has. Used on
      # rename to decide whether a wiki-link's alias was the document's title
      # (and so should track the new title) or a deliberate custom label (left
      # untouched). ADR overrides this because its filename carries a number.
      def title_of_filename?(title, filename_stem)
        filename_stem == "#{type_config[:prefix]}#{type_config[:slug_separator]}#{slugify(title)}"
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

    # `preview: true` builds a document for rendering only (see #render): it
    # skips get_configured_directory so nothing is read from or written to disk
    # (no config lookup, no mkdir). Used by the `--stdout` flag.
    def initialize(title, directory = '.', tags: [], preview: false)
      @title = customize_title(title)
      @tags = tags
      @directory = preview ? directory : get_configured_directory(directory)
      @filename = File.join(@directory, generate_filename)
      custom = customize_filename(@title, @directory)
      @filename = custom if custom
    end

    def create
      File.write(@filename, content)
      Diataxis.logger.info "Created new #{type}: #{@filename}"
    end

    # Returns the rendered template as a string without touching the
    # filesystem. Pair with `preview: true` so construction stays side-effect
    # free. Used by the `--stdout` flag to dump a template to standard output.
    def render
      content
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
      "#{cfg[:prefix]}#{cfg[:slug_separator]}#{self.class.slugify(@title)}.md"
    end

    def content
      customize_content(TemplateLoader.load_template(self.class, @title, tags: @tags))
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
