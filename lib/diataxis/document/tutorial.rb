# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class Tutorial < Document
    register_type(
      command: 'tutorial',
      prefix: 'tutorial',
      category: 'tutorials',
      config_key: 'tutorials',
      readme_section: 'Tutorials',
      template: 'tutorial',
      section_tag: 'tutorial'
    )
  end
end
