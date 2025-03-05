# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative 'config'

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
      # Remove any existing 'How to' prefix for the filename
      title_without_prefix = title.sub(/^How to\s+/i, '')
      prefix = instance_of?(HowTo) ? 'how_to' : type
      "#{prefix}_#{title_without_prefix.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')}.md"
    end
  end

  # Concrete document types
  class HowTo < Document
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['howtos'] || '.'
      File.join(path, 'how_to_*.md')
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
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['tutorials'] || '.'
      File.join(path, 'tutorial_*.md')
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
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['adr'] || 'exp/adr'
      File.join(path, '[0-9][0-9][0-9][0-9]-*.md')
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

  # File management
  class FileManager
    def self.update_filenames(directory, document_types)
      config = Config.load(directory)
      config_dir = File.dirname(Config.find_config(directory) || directory)

      document_types.each do |doc_type|
        doc_dir = doc_type == HowTo ? config['howtos'] : config["#{doc_type.name.split('::').last.downcase}s"]
        doc_dir = File.expand_path(doc_dir || '.', config_dir)

        # Cache the file list for this document type
        pattern = File.join(doc_dir, '**', doc_type.pattern)
        files = Dir.glob(pattern)
        puts "Found #{files.length} files matching #{pattern}"

        files.each do |filepath|
          update_filename(filepath, doc_dir)
        end

        # Store the file list for ReadmeManager to use
        @cached_files ||= {}
        @cached_files[doc_type] ||= {}
        @cached_files[doc_type][directory] = files
      end
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
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['explanations'] || '.'
      File.join(path, 'explanation_*.md')
    end

    def content
      <<~CONTENT
        # #{title}

        ## Overview

        A brief introduction to what this explanation covers.

        ## Background

        Historical context and evolution of the concept/system.

        ## Key Concepts

        Core ideas and principles that help understand the topic.

        ## Technical Context

        How this fits into the broader technical landscape.

        ## Rationale

        Why things are done this way and what trade-offs were considered.

        ## Related Concepts

        Links to related topics and further reading.
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

    def collect_entries(doc_type)
      # Get the pattern from the document type using the current directory as config root
      pattern = doc_type.pattern(@directory)

      # If pattern is relative, make it relative to the config file location
      config_dir = File.dirname(Config.find_config(@directory) || @directory)
      search_pattern = File.expand_path(pattern, config_dir)
      search_dir = File.dirname(search_pattern)

      # Search recursively in the configured directory
      files = Dir.glob(search_pattern).sort # Sort to maintain ADR order
      puts "Found #{files.length} files matching #{search_pattern}"

      # Update filenames before returning
      files.each do |filepath|
        # Keep files in their original subdirectory
        relative_dir = File.dirname(filepath).sub(search_dir, '').sub(%r{^/}, '')
        target_dir = relative_dir.empty? ? search_dir : File.join(search_dir, relative_dir)
        FileManager.update_filename(filepath, target_dir)
      end

      # Re-glob to get updated filenames
      files = Dir.glob(search_pattern).sort

      readme_dir = File.dirname(File.expand_path(@config['readme'], @directory))

      files.map do |file|
        title = File.open(file, &:readline).strip[2..] # Extract title from first line
        relative_path = Pathname.new(file).relative_path_from(Pathname.new(readme_dir)).to_s
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
