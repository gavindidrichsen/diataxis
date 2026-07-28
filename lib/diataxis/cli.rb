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
    # `choose_destination` is a test-only seam for the interactive prompt that
    # DestinationResolver falls back to when DIATAXIS_ROOT and a local
    # .diataxis config both apply; real non-interactive control is via the
    # `--here`/`--root` flags (parsed below into destination_override), not
    # this parameter.
    def self.run(args, root: ENV.fetch('DIATAXIS_ROOT', nil), default_tags: ENV.fetch('DIATAXIS_TAGS', nil),
                 choose_destination: nil)
      return UsageDisplay.show_usage if args.empty?

      options = GlobalFlagsHandler.process!(args, default_tags: default_tags)

      command = args.shift

      CommandRouter.route(command, args, tags: options[:tags], root: root, stdout: options[:stdout],
                                         destination_override: options[:destination_override],
                                         choose_destination: choose_destination)
    end
  end
end
