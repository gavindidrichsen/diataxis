# frozen_string_literal: true

module Diataxis
  # Interface module defining the contract for document filename generation
  # Include this module to ensure implementation of required methods
  module DocumentInterface
    def self.included(base)
      base.extend(AbstractMethods)
    end

    # Abstract methods that must be implemented by including classes
    module AbstractMethods
      # Mark method as implementing interface contract - for clarity and documentation
      def implements(interface_method_name)
        @last_implemented_method = interface_method_name
      end

      # Override method_added to validate interface implementations
      def method_added(method_name)
        super
        return unless @last_implemented_method == method_name

        # Optional: Add validation or metadata tracking here
        @last_implemented_method = nil
      end

      # Interface method: MUST be implemented by including classes
      # Returns a glob pattern for finding documents of this type
      def pattern(config_root = '.')
        raise NotImplementedError, "#{name} must implement .pattern(config_root)"
      end

      # Interface method: MUST be implemented by including classes
      # Generates new filename from existing file path
      # Each document type extracts title and any context it needs from the file
      def generate_filename_from_file(filepath)
        raise NotImplementedError, "#{name} must implement .generate_filename_from_file(filepath)"
      end

      # Interface method: MUST be implemented by including classes
      # Checks if filename matches this document type's pattern
      def matches_filename_pattern?(filename)
        raise NotImplementedError, "#{name} must implement .matches_filename_pattern?(filename)"
      end

      # Interface method: MUST be implemented by including classes
      # Returns the README section title for this document type
      def readme_section_title
        raise NotImplementedError, "#{name} must implement .readme_section_title"
      end

      # Interface method: MUST be implemented by including classes
      # Returns the configuration key for this document type's directory
      def config_key
        raise NotImplementedError, "#{name} must implement .config_key"
      end

      # Interface method: MUST be implemented by including classes
      # Formats a README entry for a document of this type
      # @param title [String] The document title (extracted from first line)
      # @param relative_path [String] Path to document relative to README
      # @param filepath [String] Full path to the document file
      def format_readme_entry(title, relative_path, filepath)
        raise NotImplementedError, "#{name} must implement .format_readme_entry(title, relative_path, filepath)"
      end

      # Interface method: MUST be implemented by including classes
      # Finds all files of this document type using recursive search
      # @param config_root [String] Root directory for configuration
      # @return [Array<String>] Sorted array of file paths
      def find_files(config_root = '.')
        raise NotImplementedError, "#{name} must implement .find_files(config_root)"
      end
    end
  end
end
