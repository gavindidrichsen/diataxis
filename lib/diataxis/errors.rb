# frozen_string_literal: true

module Diataxis
  # Base error class for all Diataxis-specific errors
  class Error < StandardError
    def initialize(message = nil)
      super
    end
  end

  # Raised when user provides invalid command line arguments or usage
  class UsageError < Error
    attr_reader :usage_message, :exit_code

    def initialize(usage_message, exit_code = 1)
      @usage_message = usage_message
      @exit_code = exit_code
      super("Invalid usage: #{usage_message}")
    end
  end

  # Raised when there are issues with document creation, validation, or file operations
  class DocumentError < Error
    attr_reader :document_type, :title

    def initialize(message, document_type: nil, title: nil)
      @document_type = document_type
      @title = title
      super(message)
    end
  end

  # Raised when configuration is invalid or missing
  class ConfigurationError < Error
    attr_reader :config_path

    def initialize(message, config_path: nil)
      @config_path = config_path
      super(message)
    end
  end

  # Raised when file system operations fail
  class FileSystemError < Error
    attr_reader :path, :operation

    def initialize(message, path: nil, operation: nil)
      @path = path
      @operation = operation
      super(message)
    end
  end

  # Raised when template loading or processing fails
  class TemplateError < Error
    attr_reader :template_name, :search_paths

    def initialize(message, template_name: nil, search_paths: nil)
      @template_name = template_name
      @search_paths = search_paths
      super(message)
    end
  end
end
