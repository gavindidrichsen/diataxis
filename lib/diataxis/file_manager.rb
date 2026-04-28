# frozen_string_literal: true

require_relative 'config'
require_relative 'document_registry'

module Diataxis
  class FileManager
    def self.update_filenames(directory, document_types)
      config = Config.load(directory)
      config_dir = File.dirname(Config.find_config(directory) || directory)

      document_types.each do |doc_type|
        process_document_type(doc_type, config, config_dir, directory)
      end
    end

    def self.process_document_type(doc_type, config, config_dir, directory)
      doc_dir = get_document_directory(doc_type, config, config_dir)
      files = find_files_for_document_type(doc_type, directory, config_dir)

      files.each do |filepath|
        update_file_in_place(filepath, doc_dir)
      end

      cache_files(doc_type, directory, files)
    end

    def self.get_document_directory(doc_type, config, config_dir)
      doc_dir = config[doc_type.config_key]
      File.expand_path(doc_dir || '.', config_dir)
    end

    def self.find_files_for_document_type(doc_type, directory, _config_dir)
      doc_type.find_files(directory)
    end

    def self.update_file_in_place(filepath, doc_dir)
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
      document_type ||= find_document_type_for_file(filepath)
      return filepath unless document_type

      new_filename = document_type.generate_filename_from_existing(filepath)
      return filepath unless new_filename

      new_filepath = File.join(directory, new_filename)
      return filepath if File.basename(filepath) == new_filename

      FileUtils.mv(filepath, new_filepath)
      Diataxis.logger.info "Renamed: #{filepath} -> #{new_filepath}"
      new_filepath
    end

    def self.find_document_type_for_file(filepath)
      filename = File.basename(filepath)
      DocumentRegistry.all.find { |doc_type| doc_type.matches_filename_pattern?(filename) }
    end
  end
end
