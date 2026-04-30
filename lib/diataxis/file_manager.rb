# frozen_string_literal: true

require 'fileutils'
require_relative 'config'
require_relative 'document_registry'

module Diataxis
  class FileManager
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
