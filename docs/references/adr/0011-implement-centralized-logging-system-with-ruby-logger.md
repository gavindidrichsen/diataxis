# 11. Implement centralized logging system with Ruby Logger

Date: 2025-11-05

## Status

Accepted

## Context

The Diataxis CLI application previously used direct `puts` statements throughout the codebase for user feedback and diagnostic output. This approach created several operational and maintenance challenges:

### Problems with Direct Output

1. **Noisy test output**: RSpec runs were cluttered with operational messages, making test failures harder to identify
2. **No verbosity control**: Users couldn't adjust output detail for different contexts (development, CI/CD, quiet operation)
3. **Inconsistent formatting**: Messages had no standardized format or severity indicators
4. **Poor debugging support**: No way to enable detailed internal logging for troubleshooting
5. **Testing complexity**: Mocking `puts` calls was complex and fragile, leading to brittle tests

### Requirements for Solution

We needed a logging system that could:

- Suppress output during automated testing while preserving debugging capability
- Support different verbosity levels for various operational contexts
- Provide professional-grade logging infrastructure following Ruby community standards
- Maintain backward compatibility with existing user-visible output expectations
- Enable easy integration with CLI argument processing (`--verbose`, `--quiet` flags)
- Support environment-based configuration for deployment flexibility

## Decision

We will implement a centralized logging system using Ruby's standard `Logger` class with the following architecture:

### 1. Singleton Pattern with Centralized Access

```ruby
module Diataxis
  class Log
    def self.instance
      @logger ||= configure_logger
    end
  end
  
  # Module-level access method for consistent usage
  def self.logger
    Log.instance
  end
end
```

### 2. Environment-Based Configuration Hierarchy

The system respects configuration sources in this priority order:

1. **CLI flags** (highest priority): `--verbose`/`--quiet` for immediate user control
2. **DIATAXIS_LOG_LEVEL**: Environment variable for explicit level setting (DEBUG, INFO, WARN, ERROR, FATAL)
3. **DIATAXIS_QUIET**: Boolean flag for simple output suppression
4. **Default INFO level** (lowest priority): Sensible default for interactive use

### 3. Test-Aware Logging

- Tests run at WARN level by default to suppress operational noise
- Environment variable override allows debugging: `DIATAXIS_LOG_LEVEL=DEBUG bundle exec rspec`
- Clean separation between test and development logging needs

### 4. CLI-Optimized Formatting

- **INFO messages**: Clean output without timestamps or severity prefixes for user-friendly display
- **DEBUG/WARN/ERROR**: Include severity indicators for clarity during troubleshooting
- **No timestamps**: Appropriate for CLI context where operations are immediate and temporal context is obvious

### 5. Log Level Usage Patterns

- **DEBUG**: Internal implementation details, configuration loading, performance timing
- **INFO**: User-visible operations (file creation, discovery results, high-level flow)
- **WARN**: Recoverable issues (missing config files, deprecated features, performance concerns)
- **ERROR**: Serious problems (file creation failures, invalid configuration, permission issues)
- **FATAL**: Application-ending problems (critical system failures, unrecoverable exceptions)

## Consequences

### Positive

- **Unified logging approach** across entire application eliminates inconsistent output patterns
- **Improved debugging capability** for both development and production issues through granular log levels
- **Clean separation** between user-facing output and diagnostic information
- **Test output clarity** improves developer productivity by suppressing operational noise during testing
- **Flexible verbosity control** via CLI flags or environment variables adapts to different usage contexts
- **Foundation for future enhancements** such as log rotation, multiple outputs, or structured logging if needed
- **Standard Ruby Logger API** familiar to Ruby developers reduces learning curve
- **Performance-conscious design** with singleton pattern and lazy evaluation avoids overhead

### Negative

- **Additional abstraction layer** between code and output adds slight complexity
- **Need for consistent log level choices** across codebase requires developer discipline
- **Slight learning curve** for developers unfamiliar with Ruby Logger, though minimal given its standard library status

### Integration Points

- **CLI argument processing**: Global flags modify log level before command execution
- **Error handling**: Log context before raising exceptions for better debugging
- **Configuration system**: Log config file discovery and fallback behavior
- **File operations**: Log creation, discovery, and modification activities

### Alternatives Considered and Rejected

- **Custom logging solution**: Would require reinventing thread safety, log levels, formatting - increases maintenance burden
- **Popular logging gems** (semantic_logger, logging): Overkill for CLI application, additional dependencies without clear benefits
- **Structured logging** (JSON output): Inappropriate for CLI users who read logs directly
- **RSpec detection for test environment**: Unreliable due to load order and detection complexity

This decision provides a robust, flexible logging foundation that improves both developer experience and user interaction with the Diataxis CLI tool.
