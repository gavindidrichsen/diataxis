# frozen_string_literal: true

require_relative 'config'
require_relative 'errors'

module Diataxis
  module TemplateLoader
    def self.load_template(document_class, title, tags: [], **variables)
      content = read_and_resolve_common(document_class)
      content = substitute_variables(content, title, variables)
      content = prepend_front_matter(content, tags) if tags && !tags.empty?
      content
    end

    def self.read_and_resolve_common(document_class)
      template_path = find_template_file(document_class)
      content = File.read(template_path)
      return content unless content.include?('{{common.metadata}}')

      common_path = File.join(File.expand_path('../..', __dir__), 'templates', 'common.metadata')
      unless File.exist?(common_path)
        raise TemplateError.new('Common metadata file not found: templates/common.metadata',
                                search_paths: [common_path])
      end

      content.gsub('{{common.metadata}}', File.read(common_path).chomp)
    end
    private_class_method :read_and_resolve_common

    def self.substitute_variables(content, title, variables)
      content = content.gsub('{{title}}', title)
                       .gsub('{{date}}', Time.now.strftime('%Y-%m-%d'))
      variables.each { |key, value| content = content.gsub("{{#{key}}}", value.to_s) }
      content
    end
    private_class_method :substitute_variables

    def self.prepend_front_matter(content, tags)
      front_matter = "---\ntags:\n#{tags.map { |t| "  - #{t}" }.join("\n")}\n---\n\n"
      "#{front_matter}#{content}"
    end
    private_class_method :prepend_front_matter

    def self.find_template_file(document_class)
      template_name = document_class.type_config[:template] ||
                      document_class.name&.split('::')&.last&.downcase
      raise TemplateError, "Cannot determine template name for #{document_class}" unless template_name

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
