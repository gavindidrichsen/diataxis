# frozen_string_literal: true

# Set log level before loading diataxis to ensure it's picked up
# Allow override via environment variable for debugging
ENV['DIATAXIS_LOG_LEVEL'] ||= 'WARN'

require 'diataxis'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up after tests
  config.after(:suite) do
    ENV.delete('DIATAXIS_LOG_LEVEL')
  end
end
