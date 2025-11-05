# frozen_string_literal: true

require_relative 'usage_display'
require_relative 'command_handlers'

module Diataxis
  module CLI
    # Routes CLI commands to appropriate handlers
    class CommandRouter
      COMMAND_MAP = {
        '--version' => :version,
        '-v' => :version,
        '--help' => :help,
        '-h' => :help,
        'init' => :init,
        'howto' => :howto,
        'tutorial' => :tutorial,
        'adr' => :adr,
        'explanation' => :explanation,
        'update' => :update
      }.freeze

      def self.route(command, args)
        action = COMMAND_MAP[command]

        case action
        when :version
          UsageDisplay.show_version
        when :help
          UsageDisplay.show_usage(0)
        when :init
          CommandHandlers.handle_init(args)
        when :howto
          CommandHandlers.handle_howto(args)
        when :tutorial
          CommandHandlers.handle_tutorial(args)
        when :adr
          CommandHandlers.handle_adr(args)
        when :explanation
          CommandHandlers.handle_explanation(args)
        when :update
          CommandHandlers.handle_update(args)
        else
          UsageDisplay.show_unknown_command_error(command)
        end
      end
    end
  end
end
