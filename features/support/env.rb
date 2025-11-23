# frozen_string_literal: true

require 'aruba/cucumber'

# Set default timeout for commands
Aruba.configure do |config|
  config.exit_timeout = 10
  config.io_wait_timeout = 2
end
