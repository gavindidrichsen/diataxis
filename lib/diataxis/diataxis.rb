# frozen_string_literal: true

require_relative 'config'
require_relative 'markdown_utils'
require_relative 'document_registry'
require_relative 'document'
require_relative 'document/adr'
require_relative 'document/howto'
require_relative 'document_types'
require_relative 'file_manager'
require_relative 'readme_manager'

module Diataxis
  def self.logger
    Log.instance
  end
end
