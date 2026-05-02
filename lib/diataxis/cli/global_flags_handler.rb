# frozen_string_literal: true

require 'logger'

module Diataxis
  module CLI
    # Extracts global flags (--verbose, --quiet, --tag) from argv before command routing.
    class GlobalFlagsHandler
      def self.process!(args)
        tags = []
        remaining = []
        i = 0

        while i < args.length
          case args[i]
          when '--verbose', '-V'
            Diataxis::Log.level = Logger::DEBUG
            Diataxis.logger.debug('Verbose mode enabled')
          when '--quiet', '-q'
            Diataxis::Log.level = Logger::WARN
          when '--tag', '-t'
            i += 1
            tags << args[i] if i < args.length
          else
            remaining << args[i]
          end
          i += 1
        end

        env_tags = parse_env_tags
        merged = (env_tags + tags).uniq

        args.replace(remaining)
        { tags: merged }
      end

      private_class_method def self.parse_env_tags
        value = ENV.fetch('DIATAXIS_TAG', nil)
        return [] if value.nil? || value.strip.empty?

        value.split(',').map(&:strip).reject(&:empty?)
      end
    end
  end
end
