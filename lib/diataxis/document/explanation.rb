# frozen_string_literal: true

require_relative '../document'
require_relative '../config'

module Diataxis
  # Explanation document type for understanding concepts and background
  # Follows the Diataxis framework's explanation format for conceptual documentation
  class Explanation < Document
    # Returns a glob pattern for finding explanation documents recursively
    # Complex explanations can be organized in dedicated subdirectories with supporting materials
    # Example: docs/explanations/understanding_simple.md AND
    #          docs/explanations/understanding_complex_system/understanding_complex_system.md
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['explanations'] || '.'
      File.join(path, '**', 'understanding_*.md')
    end

    # Generate filename from title for existing files
    def self.generate_filename_from_title(title, current_name = nil)
      clean_title = title.sub(/^understanding /i, '')
      slug = clean_title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "understanding_#{slug}.md"
    end

    # Check if filename matches Explanation pattern
    def self.matches_filename_pattern?(filename)
      filename.match?(/^understanding_.*\.md$/)
    end

    def initialize(title, directory = '.')
      normalized_title = normalize_title(title)
      super(normalized_title, directory)
    end

    protected

    def normalize_title(title)
      # If title already starts with 'Understanding', use it as is
      return title if title.downcase.start_with?('understanding')

      "Understanding #{title}"
    end

    private

    def sanitize_filename(title)
      # For explanation docs, we want to strip Understanding prefix and add it back
      # This ensures consistent filenames regardless of input format
      base_name = title.sub(/^Understanding\s+/i, '')
      "understanding_#{base_name.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')}.md"
    end

    protected

    def content
      <<~CONTENT
        # #{title}

        ## Purpose

        This document answers:

        - Why do we do things this way?
        - What are the core concepts?
        - How do the pieces fit together?

        ## Background

        Explain the context and fundamental concepts...

        ## Key Concepts

        ### Concept 1

        Explanation of the first key concept...

        **Code Location** (if relevant): Link to source code with GitHub HTTPS URLs

        ### Concept 2

        Explanation of the second key concept...

        **Code Location** (if relevant): Link to source code with GitHub HTTPS URLs

        ## Related Topics

        - Link to related concepts
        - Link to relevant how-tos
        - Link to reference docs
      CONTENT
    end
  end
end
