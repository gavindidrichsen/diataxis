# frozen_string_literal: true

require_relative '../config'
require_relative '../document_registry'
require_relative '../readme_manager'
require_relative '../errors'
require_relative 'destination_resolver'

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

      def self.handle_document(command, args, tags: [], root: nil, stdout: false, destination_override: nil,
                               choose_destination: nil)
        validate_document_args!(args, command)
        document_class = DocumentRegistry.lookup(command)
        if stdout
          print_document(args, document_class, tags: tags)
        else
          create_document_with_readme_update(args, document_class, tags: tags, root: root,
                                                                   destination_override: destination_override,
                                                                   choose_destination: choose_destination)
        end
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

      # Normalises an already-resolved root (passed down from CLI.run) into a
      # concrete directory. Does NOT read the environment — an empty/nil root
      # means "use the current working directory".
      private_class_method def self.normalize_root(root)
        return Dir.pwd if root.nil? || root.to_s.empty?

        File.expand_path(root)
      end

      # Renders the document template to stdout instead of writing a file.
      # Needs no config and creates nothing on disk (see Document#render and the
      # `preview:` flag): handy for piping a fresh template into another tool.
      private_class_method def self.print_document(args, document_class, tags: [])
        title = args[1..].join(' ')
        puts document_class.new(title, tags: tags, preview: true).render
      end

      private_class_method def self.create_document_with_readme_update(args, document_class, tags: [], root: nil,
                                                                       destination_override: nil,
                                                                       choose_destination: nil)
        title = args[1..].join(' ')
        destination = resolve_destination(root, destination_override, choose_destination)

        # Document.new resolves the configured target directory itself (see
        # Document#get_configured_directory) starting from `destination.directory`.
        # Do not pre-resolve and pass that resolved subdirectory in here instead: a
        # second, independent config lookup starting from an already-resolved
        # subdirectory can find a *different*, nested .diataxis file before it
        # reaches the root one, and re-apply the relative path against that
        # nested file's location, silently doubling it (e.g. docs/docs/...).
        if destination.standalone?
          document_class.new(title, destination.directory, tags: tags, standalone: true).create
        else
          document_class.new(title, destination.directory, tags: tags).create
          ReadmeManager.new(destination.directory, DocumentRegistry.all).update
        end
      end

      private_class_method def self.resolve_destination(root, destination_override, choose_destination)
        prompt_kwargs = choose_destination ? { prompt: choose_destination } : {}
        DestinationResolver.resolve(root: root, override: destination_override, **prompt_kwargs)
      end

      private_class_method def self.default_config
        Config::DEFAULT_CONFIG
      end
    end
  end
end
