# frozen_string_literal: true

require 'logger'

module Diataxis
  module CLI
    # Extracts global flags (--verbose, --quiet, --tag) from argv before command routing.
    class GlobalFlagsHandler
      # `default_tags` is the resolved default-tags input (a comma-separated
      # string, e.g. from DIATAXIS_TAGS, or nil). It is passed in by the caller
      # rather than read from ENV here, so this stays free of ambient state.
      def self.process!(args, default_tags: nil)
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
          when '--tag', '--tags', '-t'
            i += 1
            tags << args[i] if i < args.length
          when /\A--tags?=(.*)\z/
            tags << Regexp.last_match(1) unless Regexp.last_match(1).empty?
          else
            remaining << args[i]
          end
          i += 1
        end

        merged = (parse_tags(default_tags) + tags).uniq

        args.replace(remaining)
        { tags: merged }
      end

      private_class_method def self.parse_tags(value)
        return [] if value.nil? || value.strip.empty?

        value.split(',').map(&:strip).reject(&:empty?)
      end
    end
  end
end
