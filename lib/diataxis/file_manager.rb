# frozen_string_literal: true

require 'fileutils'
require_relative 'config'
require_relative 'document_registry'
require_relative 'wiki_link_updater'

module Diataxis
  class FileManager
    # `root`, when given, is the tree whose wiki-links get repointed at the new
    # filename after a rename.
    def self.update_filename(filepath, directory, document_type = nil, root: nil)
      document_type ||= find_document_type_for_file(filepath)
      return filepath unless document_type

      new_filename = document_type.generate_filename_from_existing(filepath)
      return filepath unless new_filename

      new_filepath = File.join(directory, new_filename)
      return filepath if File.basename(filepath) == new_filename

      FileUtils.mv(filepath, new_filepath)
      Diataxis.logger.info "Renamed: #{filepath} -> #{new_filepath}"
      WikiLinkUpdater.update_links(root, filepath, new_filepath, document_type: document_type) if root
      new_filepath
    end

    def self.find_document_type_for_file(filepath)
      filename = File.basename(filepath)
      DocumentRegistry.all.find { |doc_type| doc_type.matches_filename_pattern?(filename) }
    end
  end
end
