# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class PR < Document
    register_type(
      command: 'pr',
      prefix: 'pr',
      category: 'explanations',
      config_key: 'explanations',
      readme_section: 'Pull Requests',
      template: 'pr',
      section_tag: 'pr'
    )
  end
end
