# frozen_string_literal: true

require_relative 'usage_display'
require_relative 'command_handlers'
require_relative '../document_registry'

module Diataxis
  module CLI
    class CommandRouter
      BUILTIN_COMMANDS = {
        '--version' => :version,
        '-v' => :version,
        '--help' => :help,
        '-h' => :help,
        'init' => :init,
        'update' => :update
      }.freeze

      def self.route(command, args, tags: [])
        action = BUILTIN_COMMANDS[command]

        if action
          execute_builtin(action, args)
        elsif DocumentRegistry.lookup(command)
          CommandHandlers.handle_document(command, args, tags: tags)
        else
          UsageDisplay.show_unknown_command_error(command)
        end
      end

      private_class_method def self.execute_builtin(action, args)
        case action
        when :version
          UsageDisplay.show_version
        when :help
          UsageDisplay.show_usage(0)
        when :init
          CommandHandlers.handle_init(args)
        when :update
          CommandHandlers.handle_update(args)
        end
      end
    end
  end
end
