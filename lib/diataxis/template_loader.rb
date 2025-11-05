# frozen_string_literal: true

require_relative 'config'
require_relative 'errors'

module Diataxis
  # Utility module for template loading functionality
  # Provides shared methods for loading and processing markdown templates
  module TemplateLoader
    # Loads and processes a markdown template with variable substitution
    # @param document_class [Class] The document class requesting the template
    # @param title [String] The document title
    # @param variables [Hash] Additional template variables
    # @return [String] Processed template content
    def self.load_template(document_class, title, **variables)
      template_path = find_template_file(document_class)
      content = File.read(template_path)

      # Replace title and date placeholders
      content = content.gsub('{{title}}', title)
                       .gsub('{{date}}', Time.now.strftime('%Y-%m-%d'))

      # Replace any additional variables
      variables.each do |key, value|
        content = content.gsub("{{#{key}}}", value.to_s)
      end

      content
    end

    # Finds template file using gem's built-in templates only
    # Templates are stored in templates/ directory at gem root (best practice)
    # @param document_class [Class] The document class requesting the template
    # @return [String] Path to template file
    def self.find_template_file(document_class)
      template_filename = "#{document_class.name.split('::').last.downcase}.md"

      # Use gem's built-in template (gem_root/templates/)
      # From lib/diataxis/template_loader.rb, go up to gem root
      gem_root = File.expand_path('../..', __dir__)
      gem_template = File.join(gem_root, 'templates', template_filename)

      return gem_template if File.exist?(gem_template)

      raise TemplateError.new("Gem template not found: #{template_filename}",
                              template_name: template_filename,
                              search_paths: [gem_template])
    end
  end
end
