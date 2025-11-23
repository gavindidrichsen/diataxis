# frozen_string_literal: true

require_relative '../document'
require_relative '../config'
require_relative '../template_loader'

module Diataxis
  # Architecture Decision Record (ADR) document type
  # Captures important architectural decisions and their context
  class ADR < Document
    # Returns a glob pattern for finding ADR documents recursively
    # ADRs can be organized in subdirectories by topic, year, or other criteria
    # Example: docs/adr/0001-decision.md AND docs/adr/2025/0002-new-decision.md
    # === DocumentInterface Implementation ===

    implements :pattern
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['adr'] || 'exp/adr'
      File.join(path, '**', '[0-9][0-9][0-9][0-9]-*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      # Extract title from file content, skipping YAML front matter
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

      current_name = File.basename(filepath)

      # Extract and preserve the ADR number from existing filename
      adr_num = current_name[0..3]
      clean_title = title.sub(/^\d+\. /, '')
      slug = clean_title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
      "#{adr_num}-#{slug}.md"
    end

    implements :matches_filename_pattern?
    def self.matches_filename_pattern?(filename)
      filename.match?(/^\d{4}-.*\.md$/)
    end

    implements :readme_section_title
    def self.readme_section_title
      'Design Decisions'
    end

    implements :config_key
    def self.config_key
      'adr'
    end

    implements :format_readme_entry
    def self.format_readme_entry(title, relative_path, filepath)
      # Extract ADR number from filename
      adr_num = File.basename(filepath)[0..3]
      # Remove any existing number prefix from title
      clean_title = title.sub(/^\d+\. /, '')
      "* [ADR-#{adr_num}](#{relative_path}) - #{clean_title}"
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

    def generate_filename
      # Get the next available ADR number
      existing_numbers = Dir.glob(File.join(@directory, '[0-9][0-9][0-9][0-9]-*.md')).map do |f|
        File.basename(f)[0..3].to_i
      end
      next_number = (existing_numbers.max || 0) + 1

      # Format the filename
      title_slug = title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
      format('%<number>04d-%<title>s.md', number: next_number, title: title_slug)
    end

    def content
      formatted_number = format('%04d', next_number)
      TemplateLoader.load_template(self.class, title, adr_number: formatted_number, status: 'Proposed')
    end

    private

    def next_number
      File.basename(@filename)[0..3].to_i
    end
  end
end
