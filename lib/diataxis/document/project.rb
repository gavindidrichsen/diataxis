# frozen_string_literal: true

require_relative '../document'
require_relative '../config'
require_relative '../template_loader'

module Diataxis
  # Project document type for GTD-style project management
  # Captures projects with next actions, waiting tasks, and context lists
  class Project < Document
    # === DocumentInterface Implementation ===

    implements :pattern
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['projects'] || 'docs/references/projects'
      File.join(path, '**', 'project_*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      # Extract title from file content, skipping YAML front matter and HTML comments
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

      # Remove "Project:" prefix if present
      clean_title = title.sub(/^Project:\s*/i, '')
      slug = clean_title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "project_#{slug}.md"
    end

    implements :matches_filename_pattern?
    def self.matches_filename_pattern?(filename)
      filename.match?(/^project_.*\.md$/)
    end

    implements :readme_section_title
    def self.readme_section_title
      'Projects'
    end

    implements :config_key
    def self.config_key
      'projects'
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
