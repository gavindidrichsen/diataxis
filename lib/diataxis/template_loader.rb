# frozen_string_literal: true

require_relative 'config'
require_relative 'errors'

module Diataxis
  module TemplateLoader
    def self.load_template(document_class, title, **variables)
      template_path = find_template_file(document_class)
      content = File.read(template_path)

      if content.include?('{{common.metadata}}')
        common_path = File.join(File.expand_path('../..', __dir__), 'templates', 'common.metadata')
        unless File.exist?(common_path)
          raise TemplateError.new("Common metadata file not found: templates/common.metadata",
                                  search_paths: [common_path])
        end

        content = content.gsub('{{common.metadata}}', File.read(common_path).chomp)
      end

      content = content.gsub('{{title}}', title)
                       .gsub('{{date}}', Time.now.strftime('%Y-%m-%d'))

      variables.each do |key, value|
        content = content.gsub("{{#{key}}}", value.to_s)
      end

      content
    end

    def self.find_template_file(document_class)
      template_name = document_class.type_config[:template] ||
                      document_class.name&.split('::')&.last&.downcase
      raise TemplateError.new("Cannot determine template name for #{document_class}") unless template_name

      template_filename = "#{template_name}.md"
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
