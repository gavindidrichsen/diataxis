# frozen_string_literal: true

require_relative '../document'
require_relative '../config'

module Diataxis
  # Tutorial document type for step-by-step learning content
  # Follows the Diataxis framework's tutorial format
  class Tutorial < Document
    # Returns a glob pattern for finding tutorial documents recursively
    # Supports subdirectory organization for complex tutorial series
    # Example: docs/tutorials/tutorial_basics.md AND docs/tutorials/series_one/tutorial_advanced.md
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['tutorials'] || '.'
      File.join(path, '**', 'tutorial_*.md')
    end

    protected

    def content
      <<~CONTENT
        # #{title}

        ## Learning Objectives

        What the reader will learn from this tutorial.

        ## Prerequisites

        What the reader needs to know or have installed before starting.

        ## Tutorial

        Step-by-step instructions...
      CONTENT
    end
  end
end