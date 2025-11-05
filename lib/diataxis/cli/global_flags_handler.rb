# frozen_string_literal: true

require 'logger'

module Diataxis
  module CLI
    # Handles global CLI flags like --verbose and --quiet
    class GlobalFlagsHandler
      # Process global flags and remove them from args array
      def self.process!(args)
        # if flags exist then remove them from args and set logging level
        # otherwise leave args unchanged
        args.delete_if do |arg|
          case arg
          when '--verbose', '-V'
            Diataxis::Log.level = Logger::DEBUG
            Diataxis.logger.debug('Verbose mode enabled')
            true # remove this flag from args
          when '--quiet', '-q'
            Diataxis::Log.level = Logger::WARN
            true # remove this flag from args
          else
            false # keep this arg (not a global flag)
          end
        end
      end
    end
  end
end
