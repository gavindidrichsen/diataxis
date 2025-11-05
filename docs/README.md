# diataxis

## Description

## Usage

## Quickstart: Logging Examples

The Diataxis gem uses a centralized logging system that adapts to different environments and use cases. Here are common patterns:

### Basic Logging in Code

```ruby
# Add informational logging for user-visible operations
Diataxis.logger.info "Created new howto: #{filename}"

# Add debug logging for troubleshooting
Diataxis.logger.debug "Processing file: #{filepath}"

# Add warning logging for recoverable issues
Diataxis.logger.warn "Config file missing, using defaults"

# Add error logging before raising exceptions
Diataxis.logger.error "Failed to create file: #{error.message}"
```

### Environment-Based Control

```bash
# Normal operation - shows INFO and above
bundle exec dia howto new "My Guide"
# Output: Created new howto: /path/to/how_to_my_guide.md

# Verbose mode - shows DEBUG and above  
bundle exec dia --verbose howto new "My Guide"
# Output: [DEBUG] Verbose mode enabled
#         Created new howto: /path/to/how_to_my_guide.md

# Quiet mode - shows WARN and above only
bundle exec dia --quiet howto new "My Guide"
# Output: (no informational messages)

# Environment variable control
DIATAXIS_LOG_LEVEL=DEBUG bundle exec dia howto new "My Guide"
DIATAXIS_QUIET=true bundle exec dia howto new "My Guide"
```

### Testing Configuration

```bash
# Tests run quietly by default
bundle exec rspec

# Enable verbose logging for test debugging
DIATAXIS_LOG_LEVEL=DEBUG bundle exec rspec
```

### For Developers

- **Adding logging**: See [How to add or amend log statements](how-to/how_to_add_or_amend_log_statements.md) for practical guidance
- **Understanding the system**: See [Understanding the design of the logging system](explanations/understanding_the_design_of_the_logging_system.md) for architectural details

## Appendix

### How-To Guides

<!-- howtolog -->
* [How to add a new document template](how-to/how_to_add_a_new_document_template.md)
* [How to add or amend log statements](how-to/how_to_add_or_amend_log_statements.md)
* [How to manually test all diataxis features](how-to/how_to_manually_test_all_diataxis_features.md)
<!-- howtologstop -->

### Explanations

<!-- explanationlog -->
* [Understanding the design of the logging system](explanations/understanding_the_design_of_the_logging_system.md)
<!-- explanationlogstop -->

### Design Decisions

<!-- adrlog -->
* [ADR-0001](adr/0001-adopt-diataxis-documentation-framework.md) - Adopt Diataxis Documentation Framework
* [ADR-0002](adr/0002-use-configuration-file-for-document-paths.md) - Use Configuration File for Document Paths
* [ADR-0003](adr/0003-auto-generate-readme-with-document-links.md) - Auto-Generate README with Document Links
* [ADR-0004](adr/0004-use-linguistic-prefixes-for-document-classification.md) - Use Linguistic Prefixes for Document Classification
* [ADR-0005](adr/0005-use-purpose-driven-document-templates.md) - Use Purpose-Driven Document Templates
* [ADR-0006](adr/0006-implement-automated-readme-link-management.md) - Implement Automated README Link Management
* [ADR-0007](adr/0007-enable-recursive-document-discovery.md) - Enable Recursive Document Discovery
* [ADR-0008](adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md) - Refactor document templates into separate class files for improved maintainability
* [ADR-0009](adr/0009-hide-readme-sections-when-no-matching-documents-exist.md) - Hide README sections when no matching documents exist
* [ADR-0010](adr/0010-implement-custom-error-handling-system.md) - Implement Custom Error Handling System
* [ADR-0011](adr/0011-implement-centralized-logging-system-with-ruby-logger.md) - Implement centralized logging system with Ruby Logger
<!-- adrlogstop -->
