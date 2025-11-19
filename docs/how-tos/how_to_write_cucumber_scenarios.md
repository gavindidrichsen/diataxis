# How to write Cucumber scenarios

## Description

This guide shows you how to write effective Cucumber scenarios using Gherkin syntax and Aruba step definitions for CLI testing.

## Prerequisites

- Cucumber and Aruba installed in your project
- Basic understanding of Gherkin syntax (Given/When/Then)
- Feature directory structure created (`features/` with `support/` and `step_definitions/`)

## Usage

### Use descriptive feature and scenario names

```gherkin
Feature: Configuration Management
  As a developer
  I want to customize configuration paths
  So that I can organize my documentation

  Scenario: Create document with custom configuration
    Given a file named ".config" with:
      """
      {"path": "custom/location"}
      """
    When I run `bundle exec my_cli create`
    Then the file "custom/location/output.md" should exist
```

### Use Background for common setup

Avoid repeating setup steps in every scenario:

```gherkin
Feature: Document Operations

  Background:
    Given a file named ".config" with:
      """
      {"enabled": true}
      """
    And a directory named "docs"

  Scenario: Create document
    When I run `cli create "My Doc"`
    Then the file "docs/my_doc.md" should exist

  Scenario: Update document
    Given a file named "docs/existing.md" with "content"
    When I run `cli update docs/existing.md`
    Then the file "docs/existing.md" should contain "updated"
```

### Use Scenario Outlines for similar tests

Test multiple inputs with one scenario:

```gherkin
Scenario Outline: Create different document types
  When I run `bundle exec dia <type> new "<title>"`
  Then the file "<path>" should exist
  And the output should contain "Created new <type>"

  Examples:
    | type        | title         | path                              |
    | howto       | Setup Guide   | docs/how-tos/how_to_setup_guide.md |
    | tutorial    | Get Started   | docs/tutorials/tutorial_get_started.md |
    | explanation | Architecture  | docs/explanations/understanding_architecture.md |
```

### Test command output

```gherkin
Scenario: Show verbose output
  When I run `bundle exec my_cli --verbose process`
  Then the output should contain "Processing started"
  And the output should contain "Processing complete"
  And the output should match /Processed \d+ items/
```

### Test error conditions

```gherkin
Scenario: Handle missing file
  When I run `bundle exec my_cli process missing.txt`
  Then the exit status should not be 0
  And the stderr should contain "File not found"
```

### Test file content

```gherkin
Scenario: Generate configuration file
  When I run `bundle exec my_cli init`
  Then the file ".config" should contain exactly:
    """
    {
      "version": "1.0",
      "enabled": true
    }
    """
```

### Use tags for organization

```gherkin
@smoke
Scenario: Basic functionality works
  When I run `bundle exec my_cli --version`
  Then the exit status should be 0

@slow @integration
Scenario: Full processing pipeline
  Given large input files
  When I run `bundle exec my_cli process --all`
  Then all output files should be generated
```

Run specific tags:

```bash
# Run smoke tests only
bundle exec cucumber --tags @smoke

# Skip slow tests
bundle exec cucumber --tags "not @slow"
```

### Keep scenarios focused and independent

Each scenario should:

- Test one specific behavior
- Be independent (not rely on other scenarios)
- Clean up after itself (Aruba does this automatically)
- Have clear, descriptive names

### Use meaningful data

Bad:
```gherkin
Given a file named "test.txt" with "abc123"
```

Good:
```gherkin
Given a file named "user_config.json" with:
  """
  {
    "username": "john_doe",
    "role": "admin"
  }
  """
```

## Appendix

### Common Aruba step definitions

**File operations:**
- `Given a file named "path" with:` - Create file with content
- `Given an empty file named "path"` - Create empty file
- `Given a directory named "path"` - Create directory
- `Then the file "path" should exist` - Verify file exists
- `Then the file "path" should contain "text"` - Check file content

**Command execution:**
- `When I run \`command\`` - Run command
- `When I successfully run \`command\`` - Run and expect success
- `Then the exit status should be 0` - Check exit code
- `Then the output should contain "text"` - Check stdout
- `Then the stderr should contain "text"` - Check stderr

### Troubleshooting: Ambiguous step matches

If you encounter "Ambiguous match" errors:

#### Multiple step definitions match

Symptoms: Error message showing multiple matching step definitions

Solution:

- Make your step text more specific
- Check for duplicate step definitions in `step_definitions/`
- Use different wording to avoid conflicts

### Troubleshooting: Undefined steps

If you see "Undefined step" warnings:

#### Missing step definitions

Symptoms: Yellow text showing undefined steps after test run

Solution:

- Check if you're using correct Aruba step syntax
- Verify `require 'aruba/cucumber'` is in `features/support/env.rb`
- For custom steps, create definitions in `features/step_definitions/`
