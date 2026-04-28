# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class FiveWhyAnalysis < Document
    register_type(
      command: '5why',
      prefix: '5why',
      category: 'references',
      config_key: 'five_why_analyses',
      readme_section: 'Five Why Analyses'
    )
  end
end
