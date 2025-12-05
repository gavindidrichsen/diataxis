# frozen_string_literal: true

# lib/diataxis/document/five_why_analysis.rb
require_relative '../document'
require_relative '../config'
require_relative '../template_loader'

module Diataxis
  # FiveWhyAnalysis documents are reference documents for documenting root cause analysis
  # using the 5-why technique. They provide structured investigation of problems by
  # repeatedly asking "why" to uncover underlying causes and systemic issues.
  class FiveWhyAnalysis < Document
    # === DocumentInterface Implementation ===

    implements :pattern
    def self.pattern(config_root = '.')
      default_dir = Config.path_for('default')
      File.join(config_root, default_dir, '**', '5_why_analysis_*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      # Extract title from file content, skipping YAML front matter
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

      slug = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "5why_#{slug}.md"
    end

    implements :matches_filename_pattern?
    def self.matches_filename_pattern?(filename)
      filename.match?(/^5why_.*\.md$/)
    end

    implements :readme_section_title
    def self.readme_section_title
      'Five Why Analyses'
    end

    implements :config_key
    def self.config_key
      'five_why_analyses'
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
