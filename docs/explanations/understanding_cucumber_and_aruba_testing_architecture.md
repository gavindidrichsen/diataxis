# Understanding Cucumber and Aruba testing architecture

## Purpose

This document answers:

- Why use Cucumber and Aruba for CLI testing?
- How do Cucumber, Gherkin, and Aruba work together?
- What happens when you run a Cucumber test?
- How does Aruba create isolated test environments?

## Background

[Cucumber](https://cucumber.io/) is a Behavior-Driven Development (BDD) framework that allows you to write tests in plain English using the Gherkin language. [Aruba](https://github.com/cucumber/aruba) extends Cucumber specifically for testing command-line applications.

The combination provides:

- **Readable tests** that serve as living documentation
- **Isolated environments** where each test runs independently
- **Built-in assertions** for common CLI testing scenarios
- **Automatic cleanup** between test runs

## Key Concepts

### Gherkin Language

[Gherkin](https://cucumber.io/docs/gherkin/reference/) is the structured language used to write Cucumber tests. It uses keywords that map to test phases:

- **Feature**: High-level description of functionality being tested
- **Scenario**: A specific test case
- **Background**: Setup steps common to all scenarios in a feature
- **Given**: Preconditions (arrange)
- **When**: Actions being tested (act)
- **Then**: Expected outcomes (assert)
- **And/But**: Additional steps of the same type

Example:
```gherkin
Feature: User authentication
  Scenario: Successful login
    Given a user exists with email "test@example.com"
    When I run `login --email test@example.com`
    Then the exit status should be 0
    And the output should contain "Login successful"
```

This structure makes tests readable by non-technical stakeholders while remaining executable.

### Step Definitions

Step definitions are Ruby code that executes when Cucumber encounters a step in a scenario. Each Gherkin step maps to a step definition using regex or Cucumber expressions.

Aruba provides built-in step definitions for common CLI operations:

- File operations (`Given a file named...`)
- Command execution (`When I run...`)
- Output assertions (`Then the output should contain...`)
- Exit status checks (`Then the exit status should be 0`)

**Code Location**: Aruba's step definitions are in the [aruba gem](https://github.com/cucumber/aruba/tree/v2.3.2/lib/aruba/cucumber) - specifically:
- [File steps](https://github.com/cucumber/aruba/blob/v2.3.2/lib/aruba/cucumber/file.rb)
- [Command steps](https://github.com/cucumber/aruba/blob/v2.3.2/lib/aruba/cucumber/command.rb)
- [Testing framework steps](https://github.com/cucumber/aruba/blob/v2.3.2/lib/aruba/cucumber/testing_frameworks.rb)

You can also create custom step definitions in `features/step_definitions/` for application-specific behavior.

### Temporary Test Directories

Aruba creates a fresh temporary directory for each scenario, ensuring:

- **Isolation**: Tests don't interfere with each other
- **Safety**: Tests don't modify your actual project files
- **Cleanup**: Everything is deleted after the test runs

The directory structure:
```
tmp/aruba/
  cucumber-<timestamp>-<pid>/
    your-test-files-and-output
```

All file operations (`Given a file named...`) and commands (`When I run...`) execute within this temporary directory.

### Test Execution Flow

When you run `bundle exec cucumber`, here's what happens:

1. **Parse features**: Cucumber reads `.feature` files and parses Gherkin
2. **Match steps**: Each step is matched to a step definition (Ruby code)
3. **Execute Background**: Common setup steps run before each scenario
4. **Create temp directory**: Aruba creates isolated directory for this scenario
5. **Run scenario steps**: 
   - **Given** steps set up test data and files
   - **When** steps execute commands
   - **Then** steps verify outcomes
6. **Cleanup**: Temporary directory is removed
7. **Report results**: Summary shows passed/failed scenarios and steps

### Aruba's Command Execution

When you use `When I run \`command\``, Aruba:

1. Spawns the command as a subprocess
2. Captures stdout and stderr separately
3. Records the exit status
4. Waits for completion (with timeout)
5. Makes output available for assertions

This allows you to test:
- What the command prints
- Whether it succeeds or fails
- What files it creates
- How long it takes

**Code Location**: Command execution logic is in:
- [aruba/command.rb](https://github.com/cucumber/aruba/blob/v2.3.2/lib/aruba/command.rb)
- [aruba/processes/spawn_process.rb](https://github.com/cucumber/aruba/blob/v2.3.2/lib/aruba/processes/spawn_process.rb)

### Background vs Before Hooks

Cucumber provides two ways to set up test context:

**Background**: Gherkin steps visible in the feature file
```gherkin
Background:
  Given a file named "config.json" with "{}"
```

**Before hooks**: Ruby code in `features/support/env.rb`
```ruby
Before do
  # Ruby code here
end
```

Use **Background** for:
- Setup that's part of the test's story
- Steps users should see in documentation

Use **Before hooks** for:
- Technical setup (environment variables, etc.)
- Setup that would clutter the scenario

### Tags and Filtering

Tags organize and filter scenarios:

```gherkin
@smoke @critical
Scenario: Essential functionality
  ...

@slow @integration
Scenario: Full system test
  ...
```

Run specific subsets:
```bash
# Run smoke tests only
bundle exec cucumber --tags @smoke

# Skip slow tests
bundle exec cucumber --tags "not @slow"

# Combine conditions
bundle exec cucumber --tags "@smoke and not @skip"
```

This enables:
- Fast smoke test suites
- Skipping tests in development
- Running integration tests only in CI

### Formatters and Reporting

Cucumber supports multiple output formats:

- **Pretty** (default): Human-readable console output
- **Progress**: Dots for each step (`.` pass, `F` fail)
- **JSON**: Machine-readable for CI tools
- **HTML**: Browser-viewable test reports
- **JUnit**: Compatible with Jenkins and other CI systems

You can use multiple formatters simultaneously:
```bash
bundle exec cucumber \
  --format pretty \
  --format json --out reports/cucumber.json \
  --format html --out reports/cucumber.html
```

## Why This Architecture Works

### Living Documentation

Gherkin scenarios serve as both tests AND documentation. Non-developers can read and understand what the CLI does, while the tests ensure accuracy.

### Test Isolation

Temporary directories mean tests can create/modify files without risk. Each scenario starts clean, preventing flaky tests from interdependencies.

### Maintainability

Aruba's built-in steps handle common patterns. You don't write boilerplate for "run command and check output" - it's already there.

### Debugging Support

The `@pause` tag, verbose output, and Pry integration make it easy to understand failures and fix tests.

## Related Topics

- [Cucumber Documentation](https://cucumber.io/docs/cucumber/)
- [Aruba Documentation](https://github.com/cucumber/aruba)
- [Gherkin Reference](https://cucumber.io/docs/gherkin/reference/)
- [Cucumber Best Practices](https://cucumber.io/docs/bdd/)
- Reference: [Cucumber & Aruba Cheatsheet](../../../tools/@cheatsheets/cucumber.md)
