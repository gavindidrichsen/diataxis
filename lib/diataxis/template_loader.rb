# frozen_string_literal: true

require_relative 'config'
require_relative 'errors'

module Diataxis
  module TemplateLoader
    def self.load_template(document_class, title, **variables)
      template_path = find_template_file(document_class)
      content = File.read(template_path)

      content = content.gsub('{{title}}', title)
                       .gsub('{{date}}', Time.now.strftime('%Y-%m-%d'))

      variables.each do |key, value|
        content = content.gsub("{{#{key}}}", value.to_s)
      end

      content
    end

    def self.find_template_file(document_class)
      class_name = document_class.name.split('::').last
      template_filename = "#{class_name.downcase}.md"
      category = document_class.type_config[:category]

      gem_root = File.expand_path('../..', __dir__)
      gem_template = File.join(gem_root, 'templates', category, template_filename)

      return gem_template if File.exist?(gem_template)

      raise TemplateError.new("Gem template not found: #{template_filename}",
                              template_name: template_filename,
                              search_paths: [gem_template])
    end
  end
end
