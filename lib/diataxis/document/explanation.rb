# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class Explanation < Document
    register_type(
      command: 'explanation',
      prefix: 'understanding',
      category: 'explanations',
      config_key: 'explanations',
      readme_section: 'Explanations',
      title_prefix: 'Understanding',
      template: 'explanation',
      section_tag: 'explanation'
    )
  end
end
