# frozen_string_literal: true

require_relative '../document'
require_relative '../config'
require_relative '../template_loader'

module Diataxis
  # Tutorial document type for step-by-step learning content
  # Follows the Diataxis framework's tutorial format
  class Tutorial < Document
    # Returns a glob pattern for finding tutorial documents recursively
    # Supports subdirectory organization for complex tutorial series
    # Example: docs/tutorials/tutorial_basics.md AND docs/tutorials/series_one/tutorial_advanced.md
    # === DocumentInterface Implementation ===

    implements :pattern
    def self.pattern(_config_root = '.')
      path = Config.path_for('tutorials')
      File.join(path, '**', 'tutorial_*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      # Extract title from file content, skipping YAML front matter
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

      slug = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "tutorial_#{slug}.md"
    end

    implements :matches_filename_pattern?
    def self.matches_filename_pattern?(filename)
      filename.match?(/^tutorial_.*\.md$/)
    end

    implements :readme_section_title
    def self.readme_section_title
      'Tutorials'
    end

    implements :config_key
    def self.config_key
      'tutorials'
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

    protected

    def content
      TemplateLoader.load_template(self.class, title)
    end
  end
end
