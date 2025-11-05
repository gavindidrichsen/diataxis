# frozen_string_literal: true

require 'pathname'
require_relative 'config'
require_relative 'file_manager'

module Diataxis
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
      Diataxis.logger.info "Found #{files.length} files matching #{search_pattern}"

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
        entries = @entries[doc_type]

        if content.include?("<!-- #{section_type}log -->")
          # Section exists - update or remove it
          content = if entries.empty?
                      remove_section(content, section_type, section_title)
                    else
                      update_section(content, section_type, entries)
                    end
        elsif !entries.empty?
          # Section doesn't exist but we have content - add it
          content = add_section(content, section_type, entries, section_title)
        end
        # If section doesn't exist and no content, do nothing
      end
      File.write(readme_path, content)
    end

    def update_section(content, section_type, entries)
      tag_start = "<!-- #{section_type}log -->"
      tag_end = "<!-- #{section_type}logstop -->"
      # Update all occurrences of the section
      content.gsub(/#{tag_start}.*?#{tag_end}/m, "#{tag_start}\n#{entries.join("\n")}\n#{tag_end}")
    end

    def remove_section(content, section_type, section_title)
      # Remove the entire section including the header
      escaped_title = Regexp.escape(section_title)
      section_pattern = /### #{escaped_title}\s*\n\n<!-- #{section_type}log -->.*?<!-- #{section_type}logstop -->\n*/m
      content.gsub(section_pattern, '')
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
      sections = @document_types.filter_map do |doc_type|
        entries = @entries[doc_type]
        next if entries.empty? # Skip sections without content

        section_name = doc_type.name.split('::').last
        section_title = document_type_section(doc_type)
        section_type = section_name.downcase

        <<~SECTION
          ### #{section_title}

          <!-- #{section_type}log -->
          #{entries.join("\n")}
          <!-- #{section_type}logstop -->
        SECTION
      end.join("\n")

      content = <<~HEREDOC
        # #{current_directory_name}

        ## Description

        ## Usage

        ## Appendix
      HEREDOC

      # Only add sections if there are any
      content += "\n#{sections}" unless sections.empty?

      # Ensure content only has a single newline at the end
      content = "#{content.rstrip}\n"

      File.write(readme_path, content)
      Diataxis.logger.info "Created new README.md in #{@directory}"
    end
  end
end
