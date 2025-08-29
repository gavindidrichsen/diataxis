# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative 'config'

# Diataxis Documentation Management Gem
#
# This module implements the Diátaxis documentation framework, providing automated
# discovery and README management for documentation files organized by type:
# tutorials, how-to guides, explanations, and architectural decision records (ADRs).
#
# SUBDIRECTORY SUPPORT:
# The gem supports recursive document discovery using glob patterns with '**',
# allowing documents to be organized in nested subdirectory structures while
# maintaining proper path references in the generated README. When documents
# are moved to subdirectories, their paths are automatically updated rather
# than being removed from the README.
#
# Path resolution is handled through relative path calculation from the README
# location to each document, preserving the subdirectory structure in the
# generated links.
module Diataxis
  # Base document class following Template Method pattern
  class Document
    attr_reader :title, :filename

    def initialize(title, directory = '.')
      @title = title
      @directory = get_configured_directory(directory)
      @filename = File.join(@directory, generate_filename)
    end

    def get_configured_directory(default_dir)
      config = Config.load(default_dir)
      doc_type = type.downcase
      config_key = doc_type == 'howto' ? 'howtos' : "#{doc_type}s"
      configured_dir = config[config_key] || default_dir

      # If configured_dir is relative, make it relative to the config file location
      unless Pathname.new(configured_dir).absolute?
        config_dir = File.dirname(Config.find_config(default_dir) || '')
        configured_dir = File.expand_path(configured_dir, config_dir)
      end

      FileUtils.mkdir_p(configured_dir) unless File.directory?(configured_dir)
      configured_dir
    end

    def create
      File.write(@filename, content)
      puts "Created new #{type}: #{@filename}"
    end

    def self.pattern
      raise NotImplementedError, "#{name} must implement pattern"
    end

    protected

    def type
      self.class.name.split('::').last.downcase
    end

    def generate_filename
      sanitize_filename(title)
    end

    def content
      raise NotImplementedError, "#{self.class.name} must implement content"
    end

    private

    def sanitize_filename(title)
      # Always strip any existing prefixes for consistency
      title_without_prefix = title.sub(/^(How to|Understanding)\s+/i, '')

      # Determine the correct prefix based on document type
      prefix = case self
               when HowTo then 'how_to'
               when Explanation then 'understanding'
               else type
               end

      # Create filename with prefix and sanitized title
      "#{prefix}_#{title_without_prefix.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')}.md"
    end
  end

  # Concrete document types
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

    def initialize(title, directory = '.')
      normalized_title = normalize_title(title)
      super(normalized_title, directory)
    end

    protected

    def normalize_title(title)
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

  # Tutorial document type for step-by-step learning content
  # Follows the Diataxis framework's tutorial format
  class Tutorial < Document
    # Returns a glob pattern for finding tutorial documents recursively
    # Supports subdirectory organization for complex tutorial series
    # Example: docs/tutorials/tutorial_basics.md AND docs/tutorials/series_one/tutorial_advanced.md
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['tutorials'] || '.'
      File.join(path, '**', 'tutorial_*.md')
    end

    protected

    def content
      <<~CONTENT
        # #{title}

        ## Learning Objectives

        What the reader will learn from this tutorial.

        ## Prerequisites

        What the reader needs to know or have installed before starting.

        ## Tutorial

        Step-by-step instructions...
      CONTENT
    end
  end

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

  # File management with subdirectory support
  # Handles finding, renaming, and organizing documents across directory structures
  class FileManager
    # Main entry point for updating filenames across all document types
    # Processes each document type separately to handle their specific patterns and requirements
    def self.update_filenames(directory, document_types)
      config = Config.load(directory)
      config_dir = File.dirname(Config.find_config(directory) || directory)

      document_types.each do |doc_type|
        process_document_type(doc_type, config, config_dir, directory)
      end
    end

    # Processes a single document type, finding all files and updating them in place
    # Maintains subdirectory structure - files stay in their original subdirectories
    def self.process_document_type(doc_type, config, config_dir, directory)
      doc_dir = get_document_directory(doc_type, config, config_dir)
      files = find_files_for_document_type(doc_type, directory, config_dir)

      files.each do |filepath|
        update_file_in_place(filepath, doc_dir)
      end

      cache_files(doc_type, directory, files)
    end

    # Gets the configured base directory for a document type
    # Handles the special case where HowTo uses 'howtos' config key instead of 'howtos'
    def self.get_document_directory(doc_type, config, config_dir)
      doc_dir = if doc_type == HowTo
                  config['howtos']
                else
                  config["#{doc_type.name.split('::').last.downcase}s"]
                end
      File.expand_path(doc_dir || '.', config_dir)
    end

    # Uses recursive glob patterns to find all documents of a given type
    # The pattern includes '**' which enables discovery in subdirectories at any depth
    def self.find_files_for_document_type(doc_type, directory, config_dir)
      pattern = doc_type.pattern(directory)
      search_pattern = File.expand_path(pattern, config_dir)
      files = Dir.glob(search_pattern)
      puts "Found #{files.length} files matching #{search_pattern}"
      files
    end

    # Updates a file's name in place within its current subdirectory
    # Critical: preserves the subdirectory structure by calculating the correct target directory
    def self.update_file_in_place(filepath, doc_dir)
      # Calculate the relative path from the base document directory to preserve subdirectory structure
      # Example: /docs/explanations/complex/file.md -> relative_dir = "complex"
      relative_dir = File.dirname(filepath).sub(doc_dir, '').sub(%r{^/}, '')
      target_dir = relative_dir.empty? ? doc_dir : File.join(doc_dir, relative_dir)
      update_filename(filepath, target_dir)
    end

    def self.cache_files(doc_type, directory, files)
      @cached_files ||= {}
      @cached_files[doc_type] ||= {}
      @cached_files[doc_type][directory] = files
    end

    def self.cached_files
      @cached_files || {}
    end

    def self.update_filename(filepath, directory)
      first_line = File.open(filepath, &:readline).strip
      return unless first_line.start_with?('# ')

      title = first_line[2..] # Remove the "# " prefix
      current_name = File.basename(filepath)

      # Handle ADR files differently
      if current_name.match?(/^\d{4}-.*\.md$/)
        # Keep the existing ADR number
        adr_num = current_name[0..3]
        # Remove the number prefix from title
        title = title.sub(/^\d+\. /, '')
        new_filename = "#{adr_num}-#{title.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')}.md"
      elsif current_name.start_with?('how_to_')
        # Remove how_to_ prefix from title if it exists
        title = title.sub(/^how to /i, '')
        title_part = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
        new_filename = "how_to_#{title_part}.md"
      elsif current_name.start_with?('understanding_')
        # Remove Understanding prefix from title if it exists
        title = title.sub(/^understanding /i, '')
        title_part = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
        new_filename = "understanding_#{title_part}.md"
      else
        type = current_name.split('_').first
        title_part = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
        new_filename = "#{type}_#{title_part}.md"
      end

      new_filepath = File.join(directory, new_filename)

      return unless File.basename(filepath) != new_filename

      FileUtils.mv(filepath, new_filepath)
      puts "Renamed: #{filepath} -> #{new_filepath}"
    end
  end

  # Explanation document type for understanding concepts and background
  # Follows the Diataxis framework's explanation format
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

        ### Concept 2
        Explanation of the second key concept...

        ## Related Topics
        - Link to related concepts
        - Link to relevant how-tos
        - Link to reference docs
      CONTENT
    end
  end

  # README management
  class ReadmeManager
    def initialize(directory, document_types)
      @directory = directory
      @document_types = document_types
      @config = Config.load(directory)
    end

    def update
      # Collect all entries first
      @entries = document_entries

      # Then update the README
      if File.exist?(readme_path)
        update_existing_readme
      else
        create_new_readme
      end
    end

    def document_type_section(doc_type)
      case doc_type.name.split('::').last
      when 'ADR'
        'Design Decisions'
      else
        "#{doc_type.name.split('::').last}s"
      end
    end

    private

    def readme_path
      File.join(@directory, @config['readme'])
    end

    def document_entries
      entries = {}
      @document_types.each do |doc_type|
        entries[doc_type] = collect_entries(doc_type)
      end
      entries
    end

    # Main method for collecting document entries with subdirectory support
    # Finds documents recursively, updates filenames in place, and creates README entries
    def collect_entries(doc_type)
      search_pattern, base_dir = setup_search_paths(doc_type)
      files = find_and_update_files(search_pattern, base_dir)
      create_readme_entries(files, doc_type)
    end

    # Sets up the search pattern and base directory for recursive document discovery
    # Handles path resolution relative to the configuration file location
    def setup_search_paths(doc_type)
      pattern = doc_type.pattern(@directory)
      config_dir = File.dirname(Config.find_config(@directory) || @directory)
      search_pattern = File.expand_path(pattern, config_dir)

      doc_dir_config = get_doc_dir_config(doc_type)
      base_dir = File.expand_path(doc_dir_config || '.', config_dir)

      [search_pattern, base_dir]
    end

    def get_doc_dir_config(doc_type)
      case doc_type.name.split('::').last.downcase
      when 'howto' then @config['howtos']
      when 'tutorial' then @config['tutorials']
      when 'explanation' then @config['explanations']
      when 'adr' then @config['adr']
      end
    end

    # Finds files using recursive glob patterns and updates their filenames in place
    # Preserves subdirectory structure during filename updates
    def find_and_update_files(search_pattern, base_dir)
      files = Dir.glob(search_pattern).sort
      puts "Found #{files.length} files matching #{search_pattern}"

      # Update filenames before returning - critical to preserve subdirectory structure
      files.each do |filepath|
        # Calculate relative path to maintain files in their current subdirectories
        relative_dir = File.dirname(filepath).sub(base_dir, '').sub(%r{^/}, '')
        target_dir = relative_dir.empty? ? base_dir : File.join(base_dir, relative_dir)
        FileManager.update_filename(filepath, target_dir)
      end

      # Re-glob to get updated filenames after any renames
      Dir.glob(search_pattern).sort
    end

    # Creates README entries with correct relative paths for documents in subdirectories
    # Calculates proper link paths regardless of document depth
    def create_readme_entries(files, doc_type)
      readme_dir = File.dirname(File.expand_path(@config['readme'], @directory))

      files.map do |file|
        title = File.open(file, &:readline).strip[2..] # Extract title from first line
        # Calculate relative path from README location to document - works for any depth
        relative_path = Pathname.new(file).relative_path_from(Pathname.new(readme_dir)).to_s
        format_entry(title, relative_path, file, doc_type)
      end
    end

    # Formats README entries with proper link syntax for each document type
    # Handles special ADR formatting requirements
    def format_entry(title, relative_path, file, doc_type)
      if doc_type == ADR
        # Extract ADR number from filename
        adr_num = File.basename(file)[0..3]
        # Remove any existing number prefix from title
        clean_title = title.sub(/^\d+\. /, '')
        "* [ADR-#{adr_num}](#{relative_path}) - #{clean_title}"
      else
        "* [#{title}](#{relative_path})"
      end
    end

    def update_existing_readme
      content = File.read(readme_path)
      @document_types.each do |doc_type|
        section_name = doc_type.name.split('::').last
        section_title = document_type_section(doc_type)
        section_type = section_name.downcase
        content = if content.include?("<!-- #{section_type}log -->")
                    update_section(content, section_type, @entries[doc_type])
                  else
                    add_section(content, section_type, @entries[doc_type], section_title)
                  end
      end
      File.write(readme_path, content)
    end

    def update_section(content, section_type, entries)
      tag_start = "<!-- #{section_type}log -->"
      tag_end = "<!-- #{section_type}logstop -->"
      # Update all occurrences of the section
      content.gsub(/#{tag_start}.*?#{tag_end}/m, "#{tag_start}\n#{entries.join("\n")}\n#{tag_end}")
    end

    def add_section(content, section_type, entries, section_title)
      new_section = <<~SECTION
        \n### #{section_title}

        <!-- #{section_type}log -->
        #{entries.join("\n")}
        <!-- #{section_type}logstop -->
      SECTION
      content + new_section
    end

    def create_new_readme
      current_directory_name = File.basename(@directory)
      sections = @document_types.map do |doc_type|
        section_name = doc_type.name.split('::').last
        section_title = document_type_section(doc_type)
        section_type = section_name.downcase
        entries = @entries[doc_type]
        if entries.empty?
          <<~SECTION
            ### #{section_title}

            <!-- #{section_type}log -->
            <!-- #{section_type}logstop -->
          SECTION
        else
          <<~SECTION
            ### #{section_title}

            <!-- #{section_type}log -->
            #{entries.join("\n")}
            <!-- #{section_type}logstop -->
          SECTION
        end
      end.join("\n")

      content = <<~HEREDOC
        # #{current_directory_name}

        ## Description

        ## Usage

        ## Appendix

        #{sections}
      HEREDOC

      # Ensure content only has a single newline at the end
      content = "#{content.rstrip}\n"

      File.write(readme_path, content)
      puts "Created new README.md in #{@directory}"
    end
  end
end
