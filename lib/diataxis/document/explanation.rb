# frozen_string_literal: true

require_relative '../document'
require_relative '../config'
require_relative '../template_loader'

module Diataxis
  # Explanation document type for understanding concepts and background
  # Follows the Diataxis framework's explanation format for conceptual documentation
  class Explanation < Document
    # Returns a glob pattern for finding explanation documents recursively
    # Complex explanations can be organized in dedicated subdirectories with supporting materials
    # Example: docs/explanations/understanding_simple.md AND
    #          docs/explanations/understanding_complex_system/understanding_complex_system.md
    # === DocumentInterface Implementation ===

    implements :pattern
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['explanations'] || '.'
      File.join(path, '**', 'understanding_*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      # Extract title from file content
      first_line = File.open(filepath, &:readline).strip
      return nil unless first_line.start_with?('# ')

      title = first_line[2..] # Remove the "# " prefix
      clean_title = title.sub(/^understanding /i, '')
      slug = clean_title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "understanding_#{slug}.md"
    end

    implements :matches_filename_pattern?
    def self.matches_filename_pattern?(filename)
      filename.match?(/^understanding_.*\.md$/)
    end

    implements :readme_section_title
    def self.readme_section_title
      'Explanations'
    end

    implements :config_key
    def self.config_key
      'explanations'
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
      # If title already starts with 'Understanding', use it as is
      return title if title.downcase.start_with?('understanding')

      "Understanding #{title}"
    end

    private

    def sanitize_filename(title)
      # For explanation docs, we want to strip Understanding prefix and add it back
      # This ensures consistent filenames regardless of input format
      base_name = title.sub(/^Understanding\s+/i, '')
      "understanding_#{base_name.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')}.md"
    end

    protected

    def content
      TemplateLoader.load_template(self.class, title)
    end
  end
end
