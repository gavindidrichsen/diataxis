# frozen_string_literal: true

require_relative '../document'
require_relative '../config'
require_relative '../errors'

module Diataxis
  # HowTo document type for step-by-step procedural guides
  # Follows the Diataxis framework's how-to format for goal-oriented documentation
  class HowTo < Document
    # Returns a glob pattern for finding how-to documents recursively
    # The '**' enables subdirectory discovery - documents can be organized
    # in any subdirectory depth within the configured how-to directory
    # Example: docs/how-to/how_to_basic.md AND docs/how-to/advanced/how_to_complex.md
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['howtos'] || '.'
      File.join(path, '**', 'how_to_*.md')
    end

    # Generate filename from title for existing files
    def self.generate_filename_from_title(title)
      clean_title = title.sub(/^how to /i, '')
      slug = clean_title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "how_to_#{slug}.md"
    end

    # Check if filename matches HowTo pattern
    def self.matches_filename_pattern?(filename)
      filename.match?(/^how_to_.*\.md$/)
    end

    def initialize(title, directory = '.')
      normalized_title = normalize_title(title)
      super(normalized_title, directory)
    end

    protected

    def normalize_title(title)
      if title.nil? || title.strip.empty?
        raise DocumentError.new('Title cannot be empty', document_type: 'howto', title: title)
      end

      return title if title.downcase.start_with?('how to')

      # Convert imperative statements to 'How to' format
      # Strip any trailing punctuation and normalize whitespace
      action = title.strip.sub(/[.!?]\s*$/, '')
      "How to #{action[0].downcase}#{action[1..]}"
    end

    def content
      <<~CONTENT
        # #{title}

        ## Description

        A brief overview of what this guide helps the reader achieve.

        ## Prerequisites

        List any setup steps, dependencies, or prior knowledge needed before following this guide.

        ## Usage

        ```bash
        # step 1
        some-command --option value

        # step 2

        # step 3
        ```

        ## Appendix

        ### Sample usage output

        ```bash
        ```
      CONTENT
    end
  end
end
