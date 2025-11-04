# frozen_string_literal: true

require_relative '../document'
require_relative '../config'

module Diataxis
  # Architecture Decision Record (ADR) document type
  # Captures important architectural decisions and their context
  class ADR < Document
    # Returns a glob pattern for finding ADR documents recursively
    # ADRs can be organized in subdirectories by topic, year, or other criteria
    # Example: docs/adr/0001-decision.md AND docs/adr/2025/0002-new-decision.md
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['adr'] || 'exp/adr'
      File.join(path, '**', '[0-9][0-9][0-9][0-9]-*.md')
    end

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
      date = Time.now.strftime('%Y-%m-%d')
      <<~CONTENT
        # #{next_number}. #{title}

        Date: #{date}

        ## Status

        Proposed

        ## Context

        What is the issue that we're seeing that is motivating this decision or change?

        ## Decision

        What is the change that we're proposing and/or doing?

        ## Consequences

        What becomes easier or more difficult to do because of this change?
      CONTENT
    end

    private

    def next_number
      File.basename(@filename)[0..3].to_i
    end
  end
end