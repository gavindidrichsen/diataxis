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
      klass = if handler
                handler
              else
                Class.new(Document)
              end

      klass.register_type(**config)
    end
  end

  DocumentRegistry.configure do |r|
    r.register(
      command: 'explanation',
      prefix: 'explanation',
      category: 'explanation',
      config_key: 'explanations',
      readme_section: 'Explanations',
      template: 'explanation',
      section_tag: 'explanation'
    )

    r.register(
      command: 'tutorial',
      prefix: 'tutorial',
      category: 'tutorial',
      config_key: 'tutorials',
      readme_section: 'Tutorials',
      template: 'tutorial',
      section_tag: 'tutorial'
    )

    r.register(
      command: 'handover',
      prefix: 'handover',
      category: 'references',
      config_key: 'handovers',
      readme_section: 'Handovers',
      template: 'handover',
      section_tag: 'handover'
    )

    r.register(
      command: '5why',
      prefix: '5why',
      category: 'references',
      config_key: 'five_why_analyses',
      readme_section: 'Five Why Analyses',
      template: 'fivewhyanalysis',
      section_tag: 'fivewhyanalysis'
    )

    r.register(
      command: 'note',
      prefix: 'note',
      category: 'references',
      config_key: 'notes',
      readme_section: 'Notes',
      template: 'note',
      section_tag: 'note'
    )

    r.register(
      command: 'project',
      prefix: 'project',
      category: 'references',
      config_key: 'projects',
      readme_section: 'Projects',
      template: 'project',
      section_tag: 'project'
    )

    r.register(
      command: 'pr',
      prefix: 'pr',
      category: 'explanation',
      config_key: 'explanations',
      readme_section: 'Pull Requests',
      template: 'pr',
      section_tag: 'pr'
    )

    r.register(
      handler: Diataxis::ADR,
      command: 'adr',
      prefix: '[0-9][0-9][0-9][0-9]',
      category: 'references',
      config_key: 'adr',
      readme_section: 'Design Decisions',
      slug_separator: '-',
      template: 'adr',
      section_tag: 'adr'
    )

    r.register(
      handler: Diataxis::HowTo,
      command: 'howto',
      prefix: 'howto',
      category: 'howto',
      config_key: 'howtos',
      readme_section: 'How-To Guides',
      template: 'howto',
      section_tag: 'howto'
    )
  end
end
