# frozen_string_literal: true

require_relative '../version'

module Diataxis
  module CLI
    # Handles displaying usage information and help
    class UsageDisplay
      def self.show_version
        puts "diataxis version #{VERSION}"
        exit 0
      end

      def self.show_usage(exit_code = 1)
        usage_text = build_usage_text

        raise UsageError.new(usage_text.strip, exit_code) unless exit_code.zero?

        puts usage_text
        exit 0
      end

      def self.show_unknown_command_error(command)
        raise UsageError.new("Unknown command: #{command}", 1)
      end

      private_class_method def self.build_usage_text
        <<~USAGE
          Usage: diataxis [options] <command> [arguments]

          Global Options:
            --verbose, -V         - Enable verbose output (debug level)
            --quiet, -q           - Suppress informational output (warnings only)
            --version, -v         - Show version number
            --help, -h            - Show this help message

          Commands:
            init                  - Initialize .diataxis config file
            howto new "Title"     - Create a new how-to guide
            tutorial new "Title"  - Create a new tutorial
            adr new "Title"      - Create a new architectural decision record
            explanation new "Title" - Create a new explanation document
            update <directory>    - Update document filenames and README.md
          #{'  '}
          Environment Variables:
            DIATAXIS_LOG_LEVEL    - Set log level (DEBUG, INFO, WARN, ERROR, FATAL)
            DIATAXIS_QUIET        - Set to 'true' to suppress output
        USAGE
      end
    end
  end
end
