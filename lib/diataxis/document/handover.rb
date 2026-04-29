# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class Handover < Document
    register_type(
      command: 'handover',
      prefix: 'handover',
      category: 'references',
      config_key: 'handovers',
      readme_section: 'Handovers',
      template: 'handover',
      section_tag: 'handover'
    )
  end
end
