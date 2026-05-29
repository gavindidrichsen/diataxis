# frozen_string_literal: true

require_relative 'cli/global_flags_handler'
require_relative 'cli/command_router'
require_relative 'cli/usage_display'

module Diataxis
  # Command Line Interface module for the Diataxis documentation framework
  # Handles parsing and routing of CLI commands to appropriate handlers
  module CLI
    # The composition root: the ONLY place that reads the environment. `root`
    # and `default_tags` default to the env vars, but callers (notably tests)
    # can inject them explicitly to stay hermetic. Everything downstream
    # receives the resolved values as arguments and never touches ENV.
    def self.run(args, root: ENV.fetch('DIATAXIS_ROOT', nil), default_tags: ENV.fetch('DIATAXIS_TAGS', nil))
      return UsageDisplay.show_usage if args.empty?

      options = GlobalFlagsHandler.process!(args, default_tags: default_tags)

      command = args.shift

      CommandRouter.route(command, args, tags: options[:tags], root: root)
    end
  end
end
