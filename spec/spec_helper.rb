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

  # Neutralise any ambient diataxis env vars (e.g. exported in a dev shell) so
  # the generic specs resolve documents to their temp dirs and don't pick up
  # stray default tags. Specs that exercise these vars set them explicitly in
  # their own examples; this only clears values leaking in from the environment.
  config.around do |example|
    managed = %w[DIATAXIS_ROOT DIATAXIS_TAGS]
    saved = managed.to_h { |key| [key, ENV.fetch(key, nil)] }
    managed.each { |key| ENV.delete(key) }
    example.run
  ensure
    saved.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end

  # Clean up after tests
  config.after(:suite) do
    ENV.delete('DIATAXIS_LOG_LEVEL')
  end
end
