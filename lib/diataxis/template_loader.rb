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
    # Templates are stored in templates/ directory at gem root following Diataxis structure
    # @param document_class [Class] The document class requesting the template
    # @return [String] Path to template file
    def self.find_template_file(document_class)
      class_name = document_class.name.split('::').last
      template_filename = "#{class_name.downcase}.md"

      # Map document classes to their Diataxis category subdirectories
      category = case class_name
                 when 'HowTo'
                   'how-tos'
                 when 'Tutorial'
                   'tutorials'
                 when 'Explanation'
                   'explanations'
                 when 'ADR', 'Handover', 'FiveWhyAnalysis', 'Note', 'Project'
                   'references'
                 else
                   # Fallback to root templates directory
                   ''
                 end

      # Use gem's built-in template (gem_root/templates/{category}/)
      # From lib/diataxis/template_loader.rb, go up to gem root
      gem_root = File.expand_path('../..', __dir__)
      gem_template = if category.empty?
                       File.join(gem_root, 'templates', template_filename)
                     else
                       File.join(gem_root, 'templates', category, template_filename)
                     end

      return gem_template if File.exist?(gem_template)

      raise TemplateError.new("Gem template not found: #{template_filename}",
                              template_name: template_filename,
                              search_paths: [gem_template])
    end
  end
end
