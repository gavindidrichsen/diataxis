# frozen_string_literal: true

require 'logger'
require_relative '../errors'

module Diataxis
  module CLI
    # Extracts global flags (--verbose, --quiet, --tag) from argv before command routing.
    class GlobalFlagsHandler
      # `default_tags` is the resolved default-tags input (a comma-separated
      # string, e.g. from DIATAXIS_TAGS, or nil). It is passed in by the caller
      # rather than read from ENV here, so this stays free of ambient state.
      def self.process!(args, default_tags: nil)
        state = { tags: [], remaining: [], stdout: false, destination_override: nil }

        index = 0
        index = consume_token(args, index, state) while index < args.length

        args.replace(state[:remaining])
        { tags: (parse_tags(default_tags) + state[:tags]).uniq, stdout: state[:stdout],
          destination_override: state[:destination_override] }
      end

      # Handles the token at args[index], mutating `state` accordingly, and
      # returns the index to resume scanning from (past any consumed value,
      # e.g. --tag's argument).
      private_class_method def self.consume_token(args, index, state)
        token = args[index]
        return consume_tag_token(args, index, state) if tag_token?(token)

        handle_flag_token(token, state)
        index + 1
      end

      private_class_method def self.tag_token?(token)
        %w[--tag --tags -t].include?(token) || token.match?(/\A--tags?=/)
      end

      private_class_method def self.consume_tag_token(args, index, state)
        token = args[index]
        match = token.match(/\A--tags?=(.*)\z/)
        if match
          value = match[1]
          state[:tags] << value unless value.empty?
          return index + 1
        end

        index += 1
        state[:tags] << args[index] if index < args.length
        index + 1
      end

      private_class_method def self.handle_flag_token(token, state)
        case token
        when '--verbose', '-V'
          Diataxis::Log.level = Logger::DEBUG
          Diataxis.logger.debug('Verbose mode enabled')
        when '--quiet', '-q'
          Diataxis::Log.level = Logger::WARN
        when '--stdout'
          state[:stdout] = true
        when '--here'
          state[:destination_override] = merge_destination_override(state[:destination_override], :local)
        when '--root'
          state[:destination_override] = merge_destination_override(state[:destination_override], :root)
        else
          state[:remaining] << token
        end
      end

      private_class_method def self.merge_destination_override(current, requested)
        raise UsageError.new('--here and --root are mutually exclusive.', 1) if current && current != requested

        requested
      end

      private_class_method def self.parse_tags(value)
        return [] if value.nil? || value.strip.empty?

        value.split(',').map(&:strip).reject(&:empty?)
      end
    end
  end
end
