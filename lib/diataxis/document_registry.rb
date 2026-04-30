# frozen_string_literal: true

module Diataxis
  module DocumentRegistry
    @types = {}

    def self.register(command_name, document_class)
      @types[command_name.to_s] = document_class
    end

    def self.lookup(command_name)
      @types[command_name.to_s]
    end

    def self.all
      @types.values
    end

    def self.command_names
      @types.keys
    end

    def self.each(&block)
      @types.each_value(&block)
    end
  end
end
