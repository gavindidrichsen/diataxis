# frozen_string_literal: true

require 'fileutils'
require_relative '../config'
require_relative '../document_registry'
require_relative '../readme_manager'
require_relative '../errors'

module Diataxis
  module CLI
    class CommandHandlers
      def self.handle_init(args, root: nil)
        directory = args.empty? ? normalize_root(root) : File.expand_path(args[0])
        Diataxis.logger.debug("Initializing Diataxis config in directory: #{directory}")

        validate_directory!(directory)

        config = default_config
        Config.create(directory, config)
      end

      def self.handle_document(command, args, tags: [], root: nil)
        validate_document_args!(args, command)
        document_class = DocumentRegistry.lookup(command)
        create_document_with_readme_update(args, document_class, tags: tags, root: root)
      end

      def self.handle_update(args, root: nil)
        directory = args.empty? ? normalize_root(root) : File.expand_path(args[0])
        validate_directory!(directory)

        Config.load(directory)

        readme_manager = ReadmeManager.new(directory, DocumentRegistry.all)
        readme_manager.update
      end

      private_class_method def self.validate_directory!(directory)
        return if Dir.exist?(directory)

        raise FileSystemError.new("'#{directory}' is not a valid directory.",
                                  path: directory, operation: 'directory_check')
      end

      private_class_method def self.validate_document_args!(args, command_name)
        return unless args.length < 2 || args[0] != 'new'

        raise UsageError.new("Usage: diataxis #{command_name} new \"Title of the #{command_name.capitalize}\"", 1)
      end

      private_class_method def self.ensure_config_exists!(directory)
        config_path = File.join(directory, Config::CONFIG_FILE)
        return if File.exist?(config_path)

        raise ConfigurationError.new(
          "No .diataxis configuration file found in #{directory}.\n" \
          "Please run 'dia init' to create a configuration file.",
          config_path: config_path
        )
      end

      # Normalises an already-resolved root (passed down from CLI.run) into a
      # concrete directory. Does NOT read the environment — an empty/nil root
      # means "use the current working directory".
      private_class_method def self.normalize_root(root)
        return Dir.pwd if root.nil? || root.to_s.empty?

        File.expand_path(root)
      end

      private_class_method def self.create_document_with_readme_update(args, document_class, tags: [], root: nil)
        directory = normalize_root(root)
        ensure_config_exists!(directory)

        title = args[1..].join(' ')

        path = Config.path_for(document_class.config_key, directory)
        document_dir = File.join(directory, path)
        FileUtils.mkdir_p(document_dir)

        document_class.new(title, document_dir, tags: tags).create

        ReadmeManager.new(directory, DocumentRegistry.all).update
      end

      private_class_method def self.default_config
        Config::DEFAULT_CONFIG
      end
    end
  end
end
