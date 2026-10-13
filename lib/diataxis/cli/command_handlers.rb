# frozen_string_literal: true

require_relative '../config'
require_relative '../document_registry'
require_relative '../document_renamer'
require_relative '../errors'
require_relative 'destination_resolver'

module Diataxis
  module CLI
    class CommandHandlers
      def self.handle_init(args, root: nil)
        directory = args.empty? ? normalize_root(root) : File.expand_path(args[0])
        Diataxis.logger.debug("Initializing Diataxis config in directory: #{directory}")

        validate_directory!(directory)

        Config.create(directory)
      end

      def self.handle_document(command, args, tags: [], root: nil, stdout: false, destination_override: nil,
                               choose_destination: nil)
        validate_document_args!(args, command)
        document_class = DocumentRegistry.lookup(command)
        if stdout
          print_document(args, document_class, tags: tags)
        else
          create_document(args, document_class, tags: tags, root: root,
                                                destination_override: destination_override,
                                                choose_destination: choose_destination)
        end
      end

      # `dia update <directory>` applies to exactly that directory; without one it
      # applies to DIATAXIS_ROOT. There is no implicit current directory, and the
      # target must itself be a .diataxis root.
      def self.handle_update(args, root: nil)
        directory = update_target(args, root)
        validate_directory!(directory)
        require_diataxis_root!(directory)

        Config.load(directory)

        renamed = DocumentRenamer.new(directory, DocumentRegistry.all).rename_all
        Diataxis.logger.info(update_summary(renamed))
      end

      private_class_method def self.update_target(args, root)
        return File.expand_path(args[0]) unless args.empty?
        return File.expand_path(root) unless root.nil? || root.to_s.empty?

        raise UsageError, 'No directory given and DIATAXIS_ROOT is not set. ' \
                          'Run `dia update <directory>` (for example `dia update .`) or set DIATAXIS_ROOT.'
      end

      private_class_method def self.require_diataxis_root!(directory)
        config_file = File.join(directory, Config::CONFIG_FILE)
        return if File.file?(config_file)

        ancestor = Config.find_config(directory)
        hint = ancestor ? "Found #{ancestor}; run `dia update #{File.dirname(ancestor)}`." : 'Run `dia init` there first.'
        raise ConfigurationError.new("'#{directory}' is not a #{Config::CONFIG_FILE} root (no #{Config::CONFIG_FILE} in it). #{hint}",
                                     config_path: config_file)
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

      private_class_method def self.create_document(args, document_class, tags: [], root: nil,
                                                    destination_override: nil, choose_destination: nil)
        title = args[1..].join(' ')
        destination = resolve_destination(root, destination_override, choose_destination)

        # Document.new resolves the configured target directory itself (see
        # Document#get_configured_directory) starting from `destination.directory`.
        # Do not pre-resolve and pass that resolved subdirectory in here instead: a
        # second, independent config lookup starting from an already-resolved
        # subdirectory can find a *different*, nested .diataxis file before it
        # reaches the root one, and re-apply the relative path against that
        # nested file's location, silently doubling it (e.g. docs/docs/...).
        document_class.new(title, destination.directory, tags: tags, standalone: destination.standalone?).create
      end

      private_class_method def self.update_summary(renamed)
        return 'All document filenames already match their titles.' if renamed.zero?

        "Renamed #{renamed} document(s) to match their titles."
      end

      private_class_method def self.resolve_destination(root, destination_override, choose_destination)
        prompt_kwargs = choose_destination ? { prompt: choose_destination } : {}
        DestinationResolver.resolve(root: root, override: destination_override, **prompt_kwargs)
      end
    end
  end
end
