# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class Project < Document
    register_type(
      command: 'project',
      prefix: 'project',
      category: 'references',
      config_key: 'projects',
      readme_section: 'Projects',
      template: 'project',
      section_tag: 'project'
    )
  end
end
