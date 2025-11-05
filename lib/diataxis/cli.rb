# frozen_string_literal: true

require_relative 'cli/global_flags_handler'
require_relative 'cli/command_router'
require_relative 'cli/usage_display'

module Diataxis
  module CLI
    # Main CLI entry point - delegates to specialized handlers
    def self.run(args)
      return UsageDisplay.show_usage if args.empty?

      # remove global flags (-verbose, -q) if they exist and set the log level
      GlobalFlagsHandler.process!(args)

      # extract the first argument, e.g., howto, etc., and remove from $args
      command = args.shift

      # route to the appropriate command handler
      CommandRouter.route(command, args)
    end
  end
end
