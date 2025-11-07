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
        'handover' => :handover,
        '5why' => :five_why,
        'update' => :update
      }.freeze

      def self.route(command, args)
        action = COMMAND_MAP[command]

        if action.nil?
          UsageDisplay.show_unknown_command_error(command)
        else
          execute_action(action, args)
        end
      end

      private_class_method def self.execute_action(action, args)
        case action
        when :version
          UsageDisplay.show_version
        when :help
          UsageDisplay.show_usage(0)
        else
          execute_command_handler(action, args)
        end
      end

      private_class_method def self.execute_command_handler(action, args)
        case action
        when :init then CommandHandlers.handle_init(args)
        when :howto then CommandHandlers.handle_howto(args)
        when :tutorial then CommandHandlers.handle_tutorial(args)
        when :adr then CommandHandlers.handle_adr(args)
        when :explanation then CommandHandlers.handle_explanation(args)
        when :handover then CommandHandlers.handle_handover(args)
        when :five_why then CommandHandlers.handle_five_why(args)
        when :update then CommandHandlers.handle_update(args)
        end
      end
    end
  end
end
