# frozen_string_literal: true

require_relative 'config'
require_relative 'document/howto'
require_relative 'document/tutorial'
require_relative 'document/explanation'
require_relative 'document/adr'
require_relative 'document/handover'
require_relative 'document/five_why_analysis'
require_relative 'document/note'

module Diataxis
  # File management with subdirectory support
  # Handles finding, renaming, and organizing documents across directory structures
  class FileManager
    # Registry of all document types for filename generation
    DOCUMENT_TYPES = [HowTo, Tutorial, Explanation, ADR, Handover, FiveWhyAnalysis, Note].freeze
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
    # Uses the document type's config_key method to eliminate hardcoded configuration mapping
    def self.get_document_directory(doc_type, config, config_dir)
      doc_dir = config[doc_type.config_key]
      File.expand_path(doc_dir || '.', config_dir)
    end

    # Delegates file discovery to document type's own find_files method
    # Each document type knows how to find its own files
    def self.find_files_for_document_type(doc_type, directory, _config_dir)
      doc_type.find_files(directory)
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

    def self.update_filename(filepath, directory, document_type = nil)
      # Use provided document_type or find it based on filename pattern
      document_type ||= find_document_type_for_file(filepath)
      return filepath unless document_type

      # generate the new filename for this $document type
      new_filename = document_type.generate_filename_from_existing(filepath)
      return filepath unless new_filename

      new_filepath = File.join(directory, new_filename)
      return filepath if File.basename(filepath) == new_filename

      FileUtils.mv(filepath, new_filepath)
      Diataxis.logger.info "Renamed: #{filepath} -> #{new_filepath}"
      new_filepath
    end

    # find which document type should handle this file based on filename patterns
    def self.find_document_type_for_file(filepath)
      filename = File.basename(filepath)

      DOCUMENT_TYPES.find { |doc_type| doc_type.matches_filename_pattern?(filename) }
    end
  end
end
