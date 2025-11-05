# frozen_string_literal: true

require_relative 'config'
require_relative 'document/howto'

module Diataxis
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
      Diataxis.logger.info "Found #{files.length} files matching #{search_pattern}"
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
      Diataxis.logger.info "Renamed: #{filepath} -> #{new_filepath}"
    end
  end
end
