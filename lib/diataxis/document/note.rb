# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'

module Diataxis
  class Note < Document
    register_type(
      command: 'note',
      prefix: 'note',
      category: 'references',
      config_key: 'notes',
      readme_section: 'Notes'
    )
  end
end
