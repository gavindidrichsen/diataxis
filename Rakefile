# frozen_string_literal: true

require 'bundler/gem_tasks'

# Override the default :spec task to prevent double execution
desc 'Run RSpec test suite'
task :spec do
  require 'rspec/core'
  RSpec::Core::Runner.run(['spec'])
end

task default: :spec
