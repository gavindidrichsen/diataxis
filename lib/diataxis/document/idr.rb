# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class IDR < Document
    register_type(
      command: 'idr',
      prefix: '[0-9][0-9][0-9][0-9]',
      category: 'references',
      config_key: 'idr',
      readme_section: 'Implementation Design Records',
      slug_separator: '-',
      template: 'idr',
      section_tag: 'idr'
    )

    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      idr_dir = config[type_config[:config_key]] || config['default']
      File.join(config_root, idr_dir, '**', '[0-9][0-9][0-9][0-9]-*.md')
    end

    def self.generate_filename_from_file(filepath)
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

      idr_num = File.basename(filepath)[0..3]
      clean_title = title.sub(/^\d+\. /, '')
      slug = clean_title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
      "#{idr_num}-#{slug}.md"
    end

    def self.matches_filename_pattern?(filename)
      filename.match?(/^\d{4}-.*\.md$/)
    end

    # IDR filenames are NNNN-slug; the number is independent of the title, so
    # compare only the slug portion (and strip any leading "N. " from the title).
    def self.title_of_filename?(title, filename_stem)
      clean_title = title.sub(/^\d+\. /, '')
      filename_stem.sub(/^\d+-/, '') == slugify(clean_title)
    end

    def self.format_readme_entry(title, relative_path, filepath)
      idr_num = File.basename(filepath)[0..3]
      clean_title = title.sub(/^\d+\. /, '')
      "* [IDR-#{idr_num}](#{relative_path}) - #{clean_title}"
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
      TemplateLoader.load_template(self.class, @title, idr_number: formatted_number, status: 'Proposed', tags: @tags)
    end

    private

    def next_number
      File.basename(@filename)[0..3].to_i
    end
  end
end
