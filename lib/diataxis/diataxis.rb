# frozen_string_literal: true

require_relative 'config'
require_relative 'markdown_utils'
require_relative 'document_registry'
require_relative 'document'
require_relative 'document/howto'
require_relative 'document/explanation'
require_relative 'document/tutorial'
require_relative 'document/adr'
require_relative 'document/handover'
require_relative 'document/five_why_analysis'
require_relative 'document/note'
require_relative 'document/project'
require_relative 'document/pr'
require_relative 'file_manager'
require_relative 'readme_manager'

module Diataxis
  def self.logger
    Log.instance
  end
end
