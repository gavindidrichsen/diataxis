# frozen_string_literal: true

require 'bundler/gem_tasks'

# Override the default :spec task to prevent double execution
task :spec do
  require 'rspec/core'
  RSpec::Core::Runner.run(['spec'])
end

task default: :spec
