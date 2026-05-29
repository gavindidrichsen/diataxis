# frozen_string_literal: true

# Neutralise any ambient diataxis env vars (e.g. exported in a dev shell) BEFORE
# aruba loads, so its per-scenario environment is seeded clean and spawned
# commands stay hermetic. Scenarios that exercise these vars set them explicitly
# via aruba steps below.
%w[DIATAXIS_ROOT DIATAXIS_TAGS].each { |key| ENV.delete(key) }

require 'aruba/cucumber'

# Set default timeout for commands
Aruba.configure do |config|
  config.exit_timeout = 10
  config.io_wait_timeout = 2
end

Given('I set DIATAXIS_ROOT to the directory {string}') do |dir|
  set_environment_variable('DIATAXIS_ROOT', expand_path(dir))
end
