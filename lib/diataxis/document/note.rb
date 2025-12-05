# frozen_string_literal: true

require_relative '../document'
require_relative '../config'
require_relative '../template_loader'

module Diataxis
  # Note document type for targeted, quick-reference information
  # Captures concise knowledge with keypoints, summary, tasks, and background
  class Note < Document
    # === DocumentInterface Implementation ===

    implements :pattern
    def self.pattern(_config_root = '.')
      path = Config.path_for('notes')
      File.join(path, '**', 'note_*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      # Extract title from file content, skipping YAML front matter
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

      slug = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "note_#{slug}.md"
    end

    implements :matches_filename_pattern?
    def self.matches_filename_pattern?(filename)
      filename.match?(/^note_.*\.md$/)
    end

    implements :readme_section_title
    def self.readme_section_title
      'Notes'
    end

    implements :config_key
    def self.config_key
      'notes'
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
