# frozen_string_literal: true

module Diataxis
  # Utility module for working with Markdown files
  module MarkdownUtils
    # Extracts the first heading (title) from a markdown file, skipping any
    # number of leading YAML front matter and HTML comment blocks (in any
    # order — e.g. front matter, then a comment, then a second front matter
    # block for hand-added tags, as our own templates instruct authors to do).
    # @param filepath [String] Path to the markdown file
    # @return [String, nil] The title without the leading "# ", or nil if no title found
    def self.extract_title(filepath)
      in_yaml_front_matter = false
      in_html_comment = false

      File.open(filepath, 'r') do |file|
        file.each_line do |line|
          stripped_line = line.strip

          if in_yaml_front_matter
            # Only the closing delimiter ends the block; an unterminated
            # block means we wait forever and return nil (conservative).
            in_yaml_front_matter = false if stripped_line == '---'
            next
          end

          if in_html_comment
            in_html_comment = false if stripped_line.include?('-->')
            next
          end

          # Skip blank lines between structural blocks
          next if stripped_line.empty?

          # Start of a YAML front matter block
          if stripped_line == '---'
            in_yaml_front_matter = true
            next
          end

          # Start of an HTML comment block
          if stripped_line.start_with?('<!--')
            in_html_comment = true
            # Check if comment closes on same line
            in_html_comment = false if stripped_line.end_with?('-->')
            next
          end

          # Found the title heading
          return stripped_line[2..].strip if stripped_line.start_with?('# ')

          # Any other content before a heading means there's no title to find
          break
        end
      end

      nil
    end
  end
end
