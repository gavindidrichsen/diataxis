# Understanding the design of the logging system

## Purpose

This document explains the architectural decisions and design principles behind Diataxis's logging system. You'll understand:

- Why we chose Ruby's standard Logger over custom solutions
- How the centralized singleton pattern works and its benefits
- Why environment-based configuration is crucial for different contexts
- How the log level hierarchy supports both development and production use
- Why test-aware logging was essential for clean test output

## Background

The Diataxis CLI application initially used direct `puts` statements throughout the codebase for user feedback. While functional, this approach created several problems:

**The Original Problem:**

- **Noisy test output**: RSpec runs were cluttered with operational messages
- **No granular control**: Users couldn't adjust verbosity for different contexts  
- **Inconsistent formatting**: Messages had no standardized format
- **Poor debugging support**: No way to enable detailed internal logging
- **Testing complications**: Mocking `puts` calls was complex and fragile

**The Solution Requirements:**
We needed a logging system that could:

- Suppress output during automated testing
- Support different verbosity levels for development vs. production
- Provide consistent, professional-grade logging infrastructure
- Maintain backward compatibility with existing user-visible output
- Follow Ruby community best practices

## Key Concepts

### Centralized Logger Singleton

The system uses a singleton pattern with Ruby's standard `Logger` class to ensure consistent behavior across the entire application.

```ruby
module Diataxis
  class Log
    def self.instance
      @logger ||= configure_logger
    end
  end
  
  # Convenient access method
  def self.logger
    Log.instance
  end
end
```

**Why singleton?**

- **Consistency**: All parts of the application use the same logger configuration
- **Performance**: Logger is created once and reused, avoiding repeated initialization
- **Memory efficiency**: Single logger instance reduces memory footprint
- **Configuration persistence**: Log level and formatting settings persist across calls

**Why Ruby's Logger?**

- **Battle-tested**: Mature, well-documented standard library component
- **Feature-complete**: Built-in log levels, custom formatting, and output control
- **Thread-safe**: Handles concurrent access properly in multi-threaded environments
- **Extensible**: Easy to add custom formatters, outputs, or log rotation

**Code Location**: [`lib/diataxis/logging.rb`](https://github.com/gavindidrichsen/diataxis/blob/development/lib/diataxis/logging.rb)

### Environment-Based Configuration

The logger dynamically configures itself based on environment variables, providing different behavior for different contexts without code changes.

```ruby
def self.determine_log_level
  # Priority 1: Explicitly set level (via CLI flags)
  return @explicit_level if @explicit_level
  
  # Priority 2: Environment variable
  if ENV['DIATAXIS_LOG_LEVEL']
    case ENV['DIATAXIS_LOG_LEVEL'].upcase
    when 'DEBUG' then Logger::DEBUG
    when 'INFO' then Logger::INFO  
    when 'WARN' then Logger::WARN
    # ...
    end
  # Priority 3: Quiet mode
  elsif ENV['DIATAXIS_QUIET'] == 'true'
    Logger::WARN
  # Priority 4: Default
  else
    Logger::INFO
  end
end
```

**Why environment-based configuration?**

- **Context awareness**: Different environments (development, testing, CI/CD) need different logging behavior
- **No code changes**: Behavior modification without touching application code
- **Deployment flexibility**: Easy to adjust logging in production environments
- **Testing isolation**: Tests can run quietly without affecting development logging

**Priority hierarchy explanation:**

1. **CLI flags** (highest priority): Immediate user control via `--verbose` or `--quiet`
2. **DIATAXIS_LOG_LEVEL**: Explicit level setting for precise control
3. **DIATAXIS_QUIET**: Simple boolean for suppressing info messages
4. **Default INFO** (lowest priority): Sensible default for interactive use

### Log Level Hierarchy and Usage Patterns

The system uses Ruby Logger's standard five-level hierarchy, but applies them according to CLI application patterns:

**DEBUG (Level 0)** - Internal implementation details

- File processing steps
- Configuration loading details  
- Internal state changes
- Performance timing information

**INFO (Level 1)** - User-visible operations  

- Document creation confirmations
- File discovery results
- README generation status
- High-level operation flow

**WARN (Level 2)** - Recoverable issues

- Missing configuration files (using defaults)
- Malformed files being skipped
- Deprecated feature usage
- Performance concerns

**ERROR (Level 3)** - Serious problems

- File creation failures  
- Invalid configuration
- Permission issues
- Unrecoverable operation failures

**FATAL (Level 4)** - Application-ending problems

- Critical system failures
- Corrupted essential data
- Unhandleable exceptions

**Why this hierarchy works for CLI applications:**

- **INFO as default**: Provides helpful feedback for interactive users
- **DEBUG for troubleshooting**: Developers can enable detailed tracing
- **WARN for production**: Operators see issues but not normal operations
- **ERROR for monitoring**: Automated systems can detect real problems

### Custom Formatting for CLI Context

The logger uses custom formatting to provide clean, context-appropriate output:

```ruby
logger.formatter = proc do |severity, datetime, progname, msg|
  case severity
  when 'INFO'
    "#{msg}\n"  # Clean messages for CLI users
  when 'DEBUG'  
    "[DEBUG] #{msg}\n"  # Severity for debugging context
  else
    "[#{severity}] #{msg}\n"  # Severity for warnings/errors
  end
end
```

**Design rationale:**

- **INFO messages are clean**: No timestamp or severity prefix clutters user output
- **Non-INFO includes severity**: Helps users understand message importance
- **No timestamps in CLI**: Unlike server logs, CLI operations are immediate and temporal context is obvious
- **Consistent line endings**: Ensures proper output formatting across platforms

### Test-Aware Logging Architecture

The system automatically suppresses verbose logging during test execution to maintain clean test output:

```ruby
# In spec/spec_helper.rb
ENV['DIATAXIS_LOG_LEVEL'] = 'WARN'
require 'diataxis'
```

**Why test-specific configuration is essential:**

- **Clean test output**: Developers see test results, not operational noise
- **Faster test runs**: Less I/O improves test performance  
- **CI/CD compatibility**: Automated systems get focused, parseable output
- **Debugging capability**: Can still enable verbose logging for specific test debugging

**Alternative approaches considered and rejected:**

- **RSpec detection**: Unreliable due to load order and framework detection complexity
- **Test doubles/mocks**: Complex setup and maintenance burden
- **Conditional logging**: Would scatter test-awareness throughout codebase

### Module-Level Access Pattern

All Diataxis classes access logging through a consistent module-level method:

```ruby
module Diataxis
  def self.logger
    Log.instance
  end
end

# Usage throughout codebase:
Diataxis.logger.info "Operation completed"
```

**Benefits of this pattern:**

- **Consistency**: Same access method everywhere
- **Simplicity**: No need for includes or mixins
- **Testability**: Easy to stub for testing if needed
- **Future flexibility**: Can change underlying implementation without touching call sites

**Code Location**: [`lib/diataxis/diataxis.rb`](https://github.com/gavindidrichsen/diataxis/blob/development/lib/diataxis/diataxis.rb)

## Design Trade-offs and Alternatives

### Why Not Custom Logging?

**Considered**: Building a custom logging solution tailored specifically for CLI applications.

**Rejected because**:

- **Reinventing the wheel**: Ruby's Logger already handles the hard parts (thread safety, formatting, levels)
- **Maintenance burden**: Custom code means ongoing maintenance and bug fixes
- **Missing features**: Would need to reimplement log rotation, multiple outputs, etc.
- **Community familiarity**: Developers already know Logger's API and patterns

### Why Not Popular Logging Gems?

**Considered**: Using gems like `semantic_logger` or `logging`.

**Rejected because**:

- **Overkill for CLI**: These gems target complex server applications
- **Additional dependencies**: Prefer standard library when sufficient
- **Complexity**: More configuration options than needed for our use case
- **Size**: CLI applications should minimize gem dependencies

### Why Not Structured Logging?

**Considered**: JSON or other structured log formats.

**Rejected because**:

- **Human readability**: CLI users read logs directly, not through log aggregation systems
- **Simplicity**: Plain text is easier to understand and debug
- **Context**: CLI operations are typically simple enough that structured data adds little value

## Integration Points

### CLI Argument Processing

The logging system integrates with CLI argument processing to support `--verbose` and `--quiet` flags:

```ruby
# In CLI class
def self.handle_global_flags(args)
  if args.include?('--verbose')
    Diataxis::Log.set_level(Logger::DEBUG)
  elsif args.include?('--quiet')  
    Diataxis::Log.set_level(Logger::WARN)
  end
end
```

### Error Handling Integration

Logging coordinates with the error handling system to provide context before raising exceptions:

```ruby
def create_file(path, content)
  File.write(path, content)
  Diataxis.logger.info "Created new #{type}: #{path}"
rescue StandardError => e
  Diataxis.logger.error "Failed to create #{path}: #{e.message}"
  raise Diataxis::FileSystemError, "Could not create file: #{e.message}"
end
```

### Configuration System Integration

The configuration loader uses logging to inform users about config file discovery and fallbacks:

```ruby
def self.load(directory)
  config_path = find_config(directory)
  if config_path
    JSON.parse(File.read(config_path))
  else
    Diataxis.logger.debug "No config file found, using defaults"
    DEFAULT_CONFIG
  end
end
```

## Performance Considerations

### Lazy Initialization

The singleton logger uses lazy initialization to avoid setup costs until logging is actually needed:

```ruby
def self.instance
  @logger ||= configure_logger  # Only created when first accessed
end
```

### Block Form for Expensive Messages

For computationally expensive log messages, Ruby's Logger supports block form:

```ruby
# Only evaluates the block if DEBUG level is enabled
Diataxis.logger.debug { "Expensive calculation: #{costly_operation}" }
```

### Memory Management

- Single logger instance prevents memory leaks from multiple logger objects
- String interpolation in log messages is only performed if the message will be output
- No log message buffering reduces memory footprint for CLI applications

## Related Topics

- [How to add or amend log statements](./how_to_add_or_amend_log_statements.md) - Practical guide for developers
- [ADR #11: Implement Test-Aware Logging System](../adr/0011-implement-test-aware-logging-system.md) - Architectural decision record
- [Ruby Logger Documentation](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html) - Official Ruby Logger documentation
