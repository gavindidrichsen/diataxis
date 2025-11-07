# 10. Implement Custom Error Handling System

Date: 2025-11-04

## Status

Accepted

## Context

The Diataxis CLI application was experiencing testing difficulties due to its use of direct `exit()` calls for error handling. This created several problems:

1. **Testing Complexity**: Tests required complex mocking of `SystemExit` and `Kernel#exit` methods, making them fragile and hard to maintain.

2. **Exit Code Issues**: RSpec would return non-zero exit codes when tests raised `SystemExit`, even when the tests were expected to pass, causing CI pipeline failures.

3. **Poor Error Context**: Direct exit calls provided minimal context about what went wrong, making debugging difficult for both developers and users.

4. **Execution Flow Problems**: When mocking exit calls to prevent actual program termination, execution would continue beyond error points, leading to unexpected behaviors like attempting to create documents with invalid parameters.

5. **Maintenance Burden**: Each CLI command method contained repetitive error handling code with inconsistent messaging and exit codes.

The original approach mixed presentation concerns (displaying error messages and exiting) with business logic (command validation and execution), violating separation of concerns principles.

## Decision

We will implement a structured custom error handling system with the following components:

1. **Error Hierarchy**: Create a hierarchy of custom error classes inheriting from `Diataxis::Error`:
   - `UsageError`: For CLI usage violations (with `usage_message` and `exit_code` attributes)
   - `DocumentError`: For document creation and validation issues
   - `ConfigurationError`: For configuration-related problems
   - `FileSystemError`: For file and directory operation failures

2. **Centralized Error Handling**: Move error presentation and exit code handling to the top-level executable (`exe/dia`) using a rescue block that catches custom errors and handles display/exit appropriately.

3. **Structured Error Context**: Each error type carries specific contextual information (file paths, operations, document types) to provide rich debugging information.

4. **Clean Separation**: CLI methods throw structured errors for business logic violations, while the executable handles presentation concerns.

5. **Testable Design**: Tests can directly assert on specific error types and their contextual information without complex mocking.

## Consequences

### Positive

- **Simplified Testing**: Tests can directly verify expected error types and their context without SystemExit mocking
- **Better User Experience**: Clear, contextual error messages help users understand and fix issues
- **Maintainable Code**: Consistent error handling patterns across all CLI commands
- **Robust CI Pipeline**: No more exit code issues in test runs
- **Rich Error Context**: Each error carries specific information about what went wrong and where
- **Extensible Design**: New error types can be easily added as the application grows

### Negative

- **Additional Code**: Requires creating and maintaining custom error classes
- **Learning Curve**: Developers need to understand the error hierarchy and choose appropriate error types
- **Migration Effort**: Existing code needed to be updated to use the new error system

### Neutral

- **Testing Approach**: Tests now verify business logic errors rather than system-level exit behaviors
- **Error Flow**: Errors bubble up through the call stack rather than immediately terminating execution
