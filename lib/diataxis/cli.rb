# frozen_string_literal: true

require_relative 'cli/global_flags_handler'
require_relative 'cli/command_router'
require_relative 'cli/usage_display'

module Diataxis
  # Command Line Interface module for the Diataxis documentation framework
  # Handles parsing and routing of CLI commands to appropriate handlers
  module CLI
    def self.run(args)
      return UsageDisplay.show_usage if args.empty?

      options = GlobalFlagsHandler.process!(args)

      command = args.shift

      CommandRouter.route(command, args, tags: options[:tags])
    end
  end
end
