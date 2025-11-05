# frozen_string_literal: true

require 'fileutils'
require_relative '../config'
require_relative '../document'
require_relative '../readme_manager'
require_relative '../errors'

module Diataxis
  module CLI
    # Individual command handlers for different CLI commands
    class CommandHandlers
      def self.handle_init(args)
        directory = args.empty? ? Dir.pwd : File.expand_path(args[0])
        Diataxis.logger.debug("Initializing Diataxis config in directory: #{directory}")

        validate_directory!(directory)

        config = default_config
        Config.create(directory, config)
      end

      def self.handle_howto(args)
        validate_document_args!(args, 'howto')
        create_document_with_readme_update(args, HowTo, 'howtos', [HowTo, Tutorial, Explanation])
      end

      def self.handle_tutorial(args)
        validate_document_args!(args, 'tutorial')
        create_document_with_readme_update(args, Tutorial, 'tutorials', [HowTo, Tutorial, Explanation])
      end

      def self.handle_adr(args)
        validate_document_args!(args, 'adr')
        create_document_with_readme_update(args, ADR, 'adr', [HowTo, Tutorial, ADR])
      end

      def self.handle_explanation(args)
        validate_document_args!(args, 'explanation')
        create_document_with_readme_update(args, Explanation, 'explanations', [HowTo, Tutorial, Explanation])
      end

      def self.handle_update(args)
        raise UsageError.new('Usage: diataxis update <directory>', 1) if args.empty?

        directory = File.expand_path(args[0])
        validate_directory!(directory)

        Config.load(directory)
        document_types = [HowTo, Tutorial, Explanation, ADR]

        readme_manager = ReadmeManager.new(directory, document_types)
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

      private_class_method def self.create_document_with_readme_update(args, document_class, config_key, readme_types)
        directory = Dir.pwd
        title = args[1..].join(' ')
        config = Config.load(directory)

        document_dir = File.join(directory, config[config_key])
        FileUtils.mkdir_p(document_dir)

        document_class.new(title, document_dir).create

        # Update README after document creation
        ReadmeManager.new(directory, readme_types).update
      end

      private_class_method def self.default_config
        {
          'readme' => 'docs/README.md',
          'howtos' => 'docs/how-to',
          'tutorials' => 'docs/tutorials',
          'explanations' => 'docs/explanations',
          'adr' => 'docs/adr'
        }
      end
    end
  end
end
