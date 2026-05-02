# frozen_string_literal: true

require 'aruba/cucumber'

# Set default timeout for commands
Aruba.configure do |config|
  config.exit_timeout = 10
  config.io_wait_timeout = 2
end

Given('I set DIATAXIS_ROOT to the directory {string}') do |dir|
  set_environment_variable('DIATAXIS_ROOT', expand_path(dir))
end
