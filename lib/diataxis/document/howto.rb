# frozen_string_literal: true

require_relative '../document'
require_relative '../template_loader'
require_relative '../errors'

module Diataxis
  class HowTo < Document
    register_type(
      command: 'howto',
      prefix: 'howto',
      category: 'howto',
      config_key: 'howtos',
      readme_section: 'How-To Guides',
      template: 'howto',
      section_tag: 'howto'
    )

    # Only intercepts the title (to rewrite it into "How to ..."); every other
    # positional/keyword argument is forwarded to Document#initialize verbatim,
    # so new base keywords (e.g. preview:) work here without changes.
    def initialize(title, *args, **kwargs)
      super(validate_title(title), *args, **kwargs)
    end

    private

    def validate_title(title)
      if title.nil? || title.strip.empty?
        raise DocumentError.new('Title cannot be empty', document_type: 'howto', title: title)
      end

      return title if title.downcase.start_with?('how to')

      action = title.strip.sub(/[.!?]\s*$/, '')
      "How to #{action[0].downcase}#{action[1..]}"
    end
  end
end
