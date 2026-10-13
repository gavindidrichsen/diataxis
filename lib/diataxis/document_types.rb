# frozen_string_literal: true

require_relative 'document'
require_relative 'document_registry'
require_relative 'document/adr'
require_relative 'document/howto'

module Diataxis
  module DocumentRegistry
    def self.configure(&block)
      @types = {}
      builder = RegistryBuilder.new
      block.call(builder)
      builder.registrations.each { |reg| apply_registration(reg) }
    end

    class RegistryBuilder
      attr_reader :registrations

      def initialize
        @registrations = []
      end

      def register(config)
        @registrations << config
      end
    end

    private_class_method def self.apply_registration(config)
      handler = config.delete(:handler)
      klass = handler || Class.new(Document)

      klass.register_type(**config)
    end
  end

  DocumentRegistry.configure do |r|
    r.register(
      command: 'explanation',
      prefix: 'explanation',
      category: 'explanation',
      config_key: 'explanations',
      template: 'explanation'
    )

    r.register(
      command: 'tutorial',
      prefix: 'tutorial',
      category: 'tutorial',
      config_key: 'tutorials',
      template: 'tutorial'
    )

    r.register(
      command: 'project',
      prefix: 'project',
      category: 'references',
      config_key: 'projects',
      template: 'project'
    )

    r.register(
      command: 'pr',
      prefix: 'pr',
      category: 'explanation',
      config_key: 'explanations',
      template: 'pr'
    )

    r.register(
      command: 'fivewhy',
      prefix: 'fivewhy',
      category: 'explanation',
      config_key: 'explanations',
      template: 'fivewhy'
    )

    r.register(
      command: 'wow',
      prefix: 'wow',
      category: 'references',
      config_key: 'wow',
      template: 'wow'
    )

    r.register(
      handler: Diataxis::ADR,
      command: 'adr',
      prefix: '[0-9][0-9][0-9][0-9]',
      category: 'references',
      config_key: 'adr',
      slug_separator: '-',
      template: 'adr'
    )

    r.register(
      handler: Diataxis::HowTo,
      command: 'howto',
      prefix: 'howto',
      category: 'howto',
      config_key: 'howtos',
      template: 'howto'
    )

    r.register(
      command: 'cheatsheet',
      prefix: 'cheatsheet',
      category: 'references',
      config_key: 'cheatsheets',
      template: 'cheatsheet'
    )
  end
end
