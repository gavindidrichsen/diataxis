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
        'note' => :note,
        'project' => :project,
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

      HANDLER_MAP = {
        init: ->(args) { CommandHandlers.handle_init(args) },
        howto: ->(args) { CommandHandlers.handle_howto(args) },
        tutorial: ->(args) { CommandHandlers.handle_tutorial(args) },
        adr: ->(args) { CommandHandlers.handle_adr(args) },
        explanation: ->(args) { CommandHandlers.handle_explanation(args) },
        handover: ->(args) { CommandHandlers.handle_handover(args) },
        five_why: ->(args) { CommandHandlers.handle_five_why(args) },
        note: ->(args) { CommandHandlers.handle_note(args) },
        project: ->(args) { CommandHandlers.handle_project(args) },
        update: ->(args) { CommandHandlers.handle_update(args) }
      }.freeze

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
        handler = HANDLER_MAP[action]
        handler&.call(args)
      end
    end
  end
end
