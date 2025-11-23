# frozen_string_literal: true

require_relative 'config'
require_relative 'markdown_utils'
require_relative 'document'
require_relative 'document/howto'
require_relative 'document/explanation'
require_relative 'document/tutorial'
require_relative 'document/adr'
require_relative 'document/handover'
require_relative 'document/five_why_analysis'
require_relative 'document/note'
require_relative 'document/project'
require_relative 'file_manager'
require_relative 'readme_manager'

# Diataxis Documentation Management Gem
#
# This module implements the Diátaxis documentation framework, providing automated
# discovery and README management for documentation files organized by type:
# tutorials, how-to guides, explanations, and architectural decision records (ADRs).
#
# SUBDIRECTORY SUPPORT:
# The gem supports recursive document discovery using glob patterns with '**',
# allowing documents to be organized in nested subdirectory structures while
# maintaining proper path references in the generated README. When documents
# are moved to subdirectories, their paths are automatically updated rather
# than being removed from the README.
#
# Path resolution is handled through relative path calculation from the README
# location to each document, preserving the subdirectory structure in the
# generated links.
module Diataxis
  # Provide logger access at the module level following best practices
  def self.logger
    Log.instance
  end
end
