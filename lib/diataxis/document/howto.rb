# frozen_string_literal: true

require_relative '../document'
require_relative '../config'
require_relative '../errors'
require_relative '../template_loader'

module Diataxis
  # HowTo document type for step-by-step procedural guides
  # Follows the Diataxis framework's how-to format for goal-oriented documentation
  class HowTo < Document
    # === DocumentInterface Implementation ===

    implements :pattern
    def self.pattern(config_root = '.')
      default_dir = Config.path_for('default')
      File.join(config_root, default_dir, '**', 'how_to_*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      # Extract title from file content, skipping YAML front matter
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

      clean_title = title.sub(/^how to /i, '')
      slug = clean_title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "how_to_#{slug}.md"
    end

    implements :matches_filename_pattern?
    def self.matches_filename_pattern?(filename)
      filename.match?(/^how_to_.*\.md$/)
    end

    implements :readme_section_title
    def self.readme_section_title
      'How-To Guides'
    end

    implements :config_key
    def self.config_key
      'howtos'
    end

    implements :format_readme_entry
    def self.format_readme_entry(title, relative_path, _filepath)
      "* [#{title}](#{relative_path})"
    end

    implements :find_files
    def self.find_files(config_root = '.')
      search_pattern = File.expand_path(pattern(config_root), config_root)
      files = Dir.glob(search_pattern).sort
      Diataxis.logger.info "Found #{files.length} #{name.split('::').last} files matching #{search_pattern}"
      files
    end

    # === End DocumentInterface Implementation ===

    def initialize(title, directory = '.')
      normalized_title = normalize_title(title)
      super(normalized_title, directory)
    end

    protected

    def normalize_title(title)
      if title.nil? || title.strip.empty?
        raise DocumentError.new('Title cannot be empty', document_type: 'howto', title: title)
      end

      return title if title.downcase.start_with?('how to')

      # Convert imperative statements to 'How to' format
      # Strip any trailing punctuation and normalize whitespace
      action = title.strip.sub(/[.!?]\s*$/, '')
      "How to #{action[0].downcase}#{action[1..]}"
    end

    def content
      TemplateLoader.load_template(self.class, title)
    end
  end
end
