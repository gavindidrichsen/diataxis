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

  # No env-var neutralisation needed here: document-creating specs inject the
  # root explicitly via the `run_cli` helper, and the dedicated DIATAXIS_ROOT /
  # DIATAXIS_TAGS describe blocks set those vars themselves. The core no longer
  # reads ENV — only Diataxis::CLI.run does, at the boundary.

  # Clean up after tests
  config.after(:suite) do
    ENV.delete('DIATAXIS_LOG_LEVEL')
  end
end
