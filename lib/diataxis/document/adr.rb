# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class ADR < Document
    register_type(
      command: 'adr',
      prefix: '[0-9][0-9][0-9][0-9]',
      category: 'references',
      config_key: 'adr',
      readme_section: 'Design Decisions',
      slug_separator: '-',
      template: 'adr',
      section_tag: 'adr'
    )

    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      adr_dir = config[type_config[:config_key]] || config['default']
      File.join(config_root, adr_dir, '**', '[0-9][0-9][0-9][0-9]-*.md')
    end

    def self.generate_filename_from_file(filepath)
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

      adr_num = File.basename(filepath)[0..3]
      clean_title = title.sub(/^\d+\. /, '')
      slug = clean_title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
      "#{adr_num}-#{slug}.md"
    end

    def self.matches_filename_pattern?(filename)
      filename.match?(/^\d{4}-.*\.md$/)
    end

    def self.format_readme_entry(title, relative_path, filepath)
      adr_num = File.basename(filepath)[0..3]
      clean_title = title.sub(/^\d+\. /, '')
      "* [ADR-#{adr_num}](#{relative_path}) - #{clean_title}"
    end

    protected

    def generate_filename
      existing_numbers = Dir.glob(File.join(@directory, '[0-9][0-9][0-9][0-9]-*.md')).map do |f|
        File.basename(f)[0..3].to_i
      end
      next_number = (existing_numbers.max || 0) + 1
      title_slug = @title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
      format('%<number>04d-%<title>s.md', number: next_number, title: title_slug)
    end

    def content
      formatted_number = format('%04d', next_number)
      TemplateLoader.load_template(self.class, @title, adr_number: formatted_number, status: 'Proposed')
    end

    private

    def next_number
      File.basename(@filename)[0..3].to_i
    end
  end
end
