# How to add or amend log statements

## Description

This guide shows you how to add logging statements to the Diataxis codebase and modify existing ones. You'll learn to use the centralized logging system effectively, choose appropriate log levels, and ensure consistent formatting across the application.

## Prerequisites

- Basic understanding of Ruby syntax
- Familiarity with the Diataxis codebase structure
- Understanding of log levels (DEBUG, INFO, WARN, ERROR, FATAL)

## Adding New Log Statements

### Step 1: Use the centralized logger

All classes should use the centralized logger via `Diataxis.logger`:

```ruby
# In any Diataxis class
Diataxis.logger.info "User action completed successfully"
Diataxis.logger.warn "Configuration file not found, using defaults"
Diataxis.logger.error "Failed to create directory: #{error_message}"
```

### Step 2: Choose the appropriate log level

**INFO**: User-visible operations and high-level flow

```ruby
Diataxis.logger.info "Created new #{type}: #{@filename}"
Diataxis.logger.info "Found #{files.length} files matching #{search_pattern}"
```

**DEBUG**: Internal details for troubleshooting

```ruby
Diataxis.logger.debug "Processing file: #{filepath}"
Diataxis.logger.debug "Config loaded from: #{config_path}"
```

**WARN**: Recoverable issues or fallback behavior

```ruby
Diataxis.logger.warn "Config file missing, using defaults"
Diataxis.logger.warn "Skipping malformed file: #{filename}"
```

**ERROR**: Serious problems that affect functionality

```ruby
Diataxis.logger.error "Failed to write file: #{error.message}"
Diataxis.logger.error "Invalid configuration detected: #{validation_errors}"
```

### Step 3: Format messages consistently

**Use present tense and active voice:**

```ruby
# Good
Diataxis.logger.info "Creating directory: #{path}"
Diataxis.logger.info "File renamed: #{old_name} -> #{new_name}"

# Avoid
Diataxis.logger.info "Directory creation"
Diataxis.logger.info "Renaming file from #{old_name} to #{new_name}"
```

**Include relevant context:**

```ruby
# Good - includes context
Diataxis.logger.error "Failed to create #{doc_type} document: #{error.message}"

# Less helpful - lacks context
Diataxis.logger.error "Creation failed"
```

## Modifying Existing Log Statements

### Step 1: Locate the logging call

Use grep to find existing log statements:

```bash
# Find all log calls in the codebase
grep -r "Diataxis\.logger\." lib/

# Find specific log levels
grep -r "\.info\|\.warn\|\.error\|\.debug" lib/
```

### Step 2: Update the log level if needed

Consider if the current log level is appropriate:

```ruby
# Before - too verbose for normal operation
Diataxis.logger.info "Processing character #{char} at position #{i}"

# After - moved to debug level
Diataxis.logger.debug "Processing character #{char} at position #{i}"
```

### Step 3: Improve message clarity

Make messages more actionable and informative:

```ruby
# Before - unclear
Diataxis.logger.warn "Something went wrong"

# After - specific and actionable
Diataxis.logger.warn "Config validation failed: #{field} is required"
```

## Testing Your Changes

### Step 1: Test with different log levels

```bash
# Test normal operation (INFO level)
bundle exec dia howto new "Test Document"

# Test verbose mode (DEBUG level)
DIATAXIS_LOG_LEVEL=DEBUG bundle exec dia howto new "Test Document"

# Test quiet mode (WARN level)
DIATAXIS_LOG_LEVEL=WARN bundle exec dia howto new "Test Document"
```

### Step 2: Verify test suppression

Ensure tests run cleanly without log output:

```bash
# Tests run quietly by default (WARN level)
bundle exec rspec --format progress

# Enable verbose logging for debugging tests
DIATAXIS_LOG_LEVEL=INFO bundle exec rspec
DIATAXIS_LOG_LEVEL=DEBUG bundle exec rspec
```

### Step 3: Check log formatting

Verify messages appear with proper formatting:

- INFO messages: Clean output without severity prefix
- WARN/ERROR: Include severity prefix `[WARN]` or `[ERROR]`
- DEBUG: Include severity prefix `[DEBUG]`

## Common Patterns

### Class methods vs instance methods

Both use the same pattern:

```ruby
class MyClass
  def self.class_method
    Diataxis.logger.info "Class method executing"
  end

  def instance_method  
    Diataxis.logger.info "Instance method executing"
  end
end
```

### Error handling with logging

Log before raising errors:

```ruby
def create_file(path, content)
  File.write(path, content)
  Diataxis.logger.info "Created file: #{path}"
rescue StandardError => e
  Diataxis.logger.error "Failed to create file #{path}: #{e.message}"
  raise Diataxis::FileSystemError, "Could not create #{path}: #{e.message}"
end
```

### Conditional logging for performance

For expensive operations, use block form:

```ruby
# Only evaluate the message if DEBUG level is enabled
Diataxis.logger.debug { "Complex calculation result: #{expensive_operation}" }
```

## Appendix

### Environment Variables

- `DIATAXIS_LOG_LEVEL`: Set to DEBUG, INFO, WARN, ERROR, or FATAL (overrides all other settings)
- `DIATAXIS_QUIET`: Set to 'true' to suppress INFO messages (sets WARN level)

**Note**: For RSpec tests, `DIATAXIS_LOG_LEVEL` can override the default WARN level set in `spec_helper.rb`

### CLI Flags

- `--verbose`: Enables DEBUG level logging  
- `--quiet`: Enables WARN level logging (suppresses INFO)

### Sample Output

```bash
# Normal operation (INFO level)
$ bundle exec dia howto new "My Guide" 
Created new howto: /path/to/how_to_my_guide.md
Found 1 files matching /path/to/how-to/**/how_to_*.md
Created new README.md in /current/directory

# Verbose operation (DEBUG level)  
$ DIATAXIS_LOG_LEVEL=DEBUG bundle exec dia howto new "My Guide"
[DEBUG] Initializing document with title: My Guide
[DEBUG] Config loaded from: /path/to/.diataxis
Created new howto: /path/to/how_to_my_guide.md
[DEBUG] Scanning for files with pattern: /path/to/how-to/**/how_to_*.md
Found 1 files matching /path/to/how-to/**/how_to_*.md
[DEBUG] Processing README template
Created new README.md in /current/directory

# Quiet operation (WARN level)
$ DIATAXIS_QUIET=true bundle exec dia howto new "My Guide"
# (No INFO output, only warnings and errors would appear)
```
