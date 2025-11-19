# Getting Started with Cucumber Testing

## Learning Objectives

By completing this tutorial, you will:

- Set up Cucumber and Aruba for CLI testing in a Ruby project
- Write your first feature file with scenarios
- Understand Gherkin syntax (Given/When/Then)
- Run tests and interpret results
- Use Aruba's built-in step definitions for CLI testing

## Prerequisites

- Ruby installed (version 2.7 or higher)
- Bundler installed
- Basic understanding of command-line interfaces
- A Ruby project or gem to test

## Tutorial

### Install Cucumber and Aruba

Add the gems to your project:

```bash
bundle add cucumber aruba --group development
```

### Create the directory structure

Set up the standard Cucumber directories:

```bash
mkdir -p features/support features/step_definitions
```

### Configure Aruba

Create `features/support/env.rb`:

```ruby
require 'aruba/cucumber'

Aruba.configure do |config|
  config.exit_timeout = 10
  config.io_wait_timeout = 2
end
```

This loads Aruba and sets reasonable timeouts for command execution.

### Write your first feature

Create `features/hello_world.feature`:

```gherkin
Feature: Hello World
  As a new user
  I want to run a simple command
  So that I can verify my setup works

  Scenario: Run echo command
    When I run `echo "Hello, Cucumber!"`
    Then the exit status should be 0
    And the output should contain "Hello, Cucumber!"
```

### Understanding Gherkin syntax

- **Feature**: Describes what you're testing at a high level
- **Scenario**: A specific test case
- **Given**: Sets up initial context (preconditions)
- **When**: The action being tested
- **Then**: Expected outcomes
- **And/But**: Additional steps of the same type

### Run your first test

```bash
bundle exec cucumber
```

You should see:

```
Feature: Hello World

  Scenario: Run echo command
    When I run `echo "Hello, Cucumber!"`
    Then the exit status should be 0
    And the output should contain "Hello, Cucumber!"

1 scenario (1 passed)
3 steps (3 passed)
```

### Test a real CLI command

Now test your own CLI. Create `features/my_cli.feature`:

```gherkin
Feature: My CLI Tool
  
  Scenario: Show help message
    When I run `bundle exec my_cli --help`
    Then the exit status should be 0
    And the output should contain "Usage:"
```

### Add file creation tests

Test that your CLI creates files correctly:

```gherkin
Feature: File Creation

  Background:
    Given a file named "config.json" with:
      """
      {"setting": "value"}
      """

  Scenario: Create output file
    When I run `bundle exec my_cli generate`
    Then the file "output.txt" should exist
    And the file "output.txt" should contain "success"
```

### Run specific tests

Run a specific feature file:

```bash
bundle exec cucumber features/my_cli.feature
```

Run a specific scenario by line number:

```bash
bundle exec cucumber features/my_cli.feature:10
```

### View detailed output

See more details about what's happening:

```bash
bundle exec cucumber --expand --verbose
```

## What You've Learned

You now know how to:

- Install and configure Cucumber with Aruba
- Write feature files using Gherkin syntax
- Use Aruba's step definitions for CLI testing
- Run tests and interpret results
- Test command output and file operations

## Next Steps

- Read "How to write Cucumber scenarios" for advanced scenario patterns
- Read "How to debug Cucumber tests" when tests fail
- Explore the Cucumber cheatsheet for more commands and options
