# frozen_string_literal: true

require_relative 'file_manager'

module Diataxis
  # Renames every document under a directory so its filename matches its
  # `# title`, repointing wiki-links to renamed files (see FileManager).
  class DocumentRenamer
    def initialize(directory, document_types)
      @directory = directory
      @document_types = document_types
    end

    # @return [Integer] how many documents were renamed
    def rename_all
      @document_types.sum { |doc_type| rename_type(doc_type) }
    end

    private

    def rename_type(doc_type)
      doc_type.find_files(@directory).count do |filepath|
        FileManager.update_filename(filepath, File.dirname(filepath), doc_type, root: @directory) != filepath
      end
    end
  end
end
