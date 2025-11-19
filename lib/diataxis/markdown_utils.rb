# frozen_string_literal: true

module Diataxis
  # Utility module for working with Markdown files
  module MarkdownUtils
    # Extracts the first heading (title) from a markdown file, skipping YAML front matter if present
    # @param filepath [String] Path to the markdown file
    # @return [String, nil] The title without the leading "# ", or nil if no title found
    def self.extract_title(filepath)
      in_front_matter = false
      front_matter_count = 0

      File.open(filepath, 'r') do |file|
        file.each_line do |line|
          stripped_line = line.strip

          # Track YAML front matter delimiters (---)
          if stripped_line == '---'
            front_matter_count += 1
            in_front_matter = front_matter_count == 1
            next
          end

          # Skip lines while inside front matter
          next if in_front_matter

          # Skip if we've only seen one delimiter (still waiting for closing delimiter)
          next if front_matter_count == 1

          # Found the title heading
          if stripped_line.start_with?('# ')
            return stripped_line[2..].strip # Remove "# " prefix and strip whitespace
          end

          # Skip empty lines
          next if stripped_line.empty?

          # If we hit non-empty content that's not a heading, stop searching
          break unless stripped_line.start_with?('#')
        end
      end

      nil
    end
  end
end
