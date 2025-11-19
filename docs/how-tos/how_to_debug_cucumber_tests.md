# How to debug Cucumber tests

## Description

This guide shows you techniques for debugging failing Cucumber tests, inspecting test execution, and troubleshooting common issues.

## Prerequisites

- Cucumber and Aruba installed
- Existing feature files with scenarios
- Basic understanding of Gherkin syntax

## Usage

### Use verbose output

See detailed information about test execution:

```bash
bundle exec cucumber --expand --verbose
```

This shows:
- Full step definitions being executed
- Command output in real-time
- File paths and locations

### Add debug output steps

Inspect the test environment during execution:

```gherkin
Scenario: Debug file creation
  When I run `bundle exec dia howto new "Test"`
  And I run `pwd`
  And I run `ls -la`
  And I run `cat test_docs/README.md`
  Then the output should contain "test_docs"
```

### Use the @pause tag

Pause execution for interactive debugging:

```gherkin
@pause
Scenario: Interactive debugging
  Given a file named "config.json" with "test"
  When I run `bundle exec my_cli process`
  # Test will pause here - you can explore the temp directory
```

Run normally:

```bash
bundle exec cucumber
```

Aruba will pause and give you an interactive prompt.

### Inspect the temporary directory

Aruba creates temporary directories for each scenario. Print the path:

```gherkin
Scenario: Find temp directory
  When I run `pwd`
  Then the output should match /tmp/
```

Or add this to see the working directory:

```ruby
# In features/support/env.rb
After do
  puts "Working directory: #{current_dir}"
end
```

### Use Pry for breakpoints

Add Pry to your Gemfile:

```bash
bundle add pry --group development
```

Require it in `features/support/env.rb`:

```ruby
require 'pry'
```

Create a custom step for breakpoints in `features/step_definitions/debug_steps.rb`:

```ruby
When('I debug') do
  binding.pry
end
```

Use in scenarios:

```gherkin
Scenario: Debug with Pry
  Given a file named "test.txt" with "content"
  When I debug
  When I run `cat test.txt`
```

### Check actual vs expected output

When output doesn't match, Cucumber shows the difference:

```bash
expected: "Created new howto: test.md"
     got: "Created new howto: /full/path/test.md" (using ==)
```

Fix by using partial matches:

```gherkin
# Instead of exact match
Then the output should be "Created new howto: test.md"

# Use contains
Then the output should contain "Created new howto:"
And the output should contain "test.md"
```

### Use glob patterns for paths

Handle variable paths:

```gherkin
Then the output should match /Created new howto: .*test\.md/
```

Or in your step implementation, use Aruba's matchers.

### Run a single scenario

Test just one scenario by line number:

```bash
bundle exec cucumber features/my_feature.feature:23
```

### Dry run to check syntax

Verify Gherkin syntax without running tests:

```bash
bundle exec cucumber --dry-run
```

### Check step definitions

List all available steps:

```bash
bundle exec cucumber --steps
```

Find where a step is defined:

```bash
bundle exec cucumber --expand features/my_feature.feature
```

### Increase Aruba timeouts

If commands are timing out:

```ruby
# In features/support/env.rb
Aruba.configure do |config|
  config.exit_timeout = 30        # Increase from 10
  config.io_wait_timeout = 5      # Increase from 2
end
```

### Capture and inspect failures

Save failed scenario output:

```bash
bundle exec cucumber --format html --out report.html
```

Or use JSON for programmatic inspection:

```bash
bundle exec cucumber --format json --out report.json
```

## Appendix

### Sample debug workflow

```bash
# 1. Run test and see failure
bundle exec cucumber features/my_feature.feature

# 2. Run with verbose output
bundle exec cucumber --expand --verbose features/my_feature.feature

# 3. Add debug steps to scenario
# Edit feature file to add: And I run `ls -la`

# 4. Run single scenario
bundle exec cucumber features/my_feature.feature:15

# 5. Use @pause tag if needed
# Add @pause above scenario

# 6. Fix the issue
# Update scenario or code

# 7. Verify fix
bundle exec cucumber features/my_feature.feature
```

### Troubleshooting: Timeout errors

If commands time out during execution:

#### Command takes too long

Symptoms: `Aruba::ArubaTimeout` error

Solution:

- Increase timeout in `features/support/env.rb`
- Check if command is actually hanging
- Use `--verbose` to see what's happening
- Verify command works outside Cucumber

### Troubleshooting: File not found errors

If tests can't find expected files:

#### Working directory mismatch

Symptoms: "File not found" or "No such file or directory"

Solution:

- Print current directory: `When I run \`pwd\``
- List files: `When I run \`ls -la\``
- Remember Aruba uses temp directories
- Use relative paths, not absolute
- Check file creation steps ran successfully

### Troubleshooting: Output doesn't match

If output assertions fail:

#### Extra whitespace or formatting

Symptoms: Content is there but assertion fails

Solution:

- Use `should contain` instead of `should be`
- Check for extra newlines or spaces
- Use regex: `should match /pattern/`
- Print actual output: `And I run \`cat file.txt\``
