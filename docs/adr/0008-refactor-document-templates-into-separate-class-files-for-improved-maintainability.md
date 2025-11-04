# 8. Refactor document templates into separate class files for improved maintainability

Date: 2025-11-04

## Status

Proposed

## Context

The Diataxis gem's document classes (HowTo, Explanation, Tutorial, ADR) were all defined in a single monolithic file `lib/diataxis/diataxis.rb` along with supporting classes like FileManager and ReadmeManager. This created several maintenance challenges:

1. **Template Updates**: Modifying document templates required editing a large, complex file with multiple class definitions
2. **Code Navigation**: Finding specific document type logic was difficult in a 500+ line file
3. **Extensibility**: Adding new document types required modifications to the main file, increasing risk of introducing bugs
4. **Separation of Concerns**: Business logic for different document types was intermixed, violating single responsibility principle

I wanted to make it easier to update existing templates and add new ones.

## Decision

Refactor the document class hierarchy into a modular directory structure:

- Extract base `Document` class to `lib/diataxis/document.rb`
- Create `lib/diataxis/document/` directory containing separate files for each document type:
  - `howto.rb` - HowTo document class and template
  - `explanation.rb` - Explanation document class and template  
  - `tutorial.rb` - Tutorial document class and template
  - `adr.rb` - ADR document class and template
- Move `FileManager` to `lib/diataxis/file_manager.rb`
- Move `ReadmeManager` to `lib/diataxis/readme_manager.rb`
- Update main `diataxis.rb` to require all modular components

Maintain full backward compatibility with existing CLI commands and functionality.

## Consequences

### What becomes easier

1. **Template Maintenance**: Each document type's template is now in its own focused file, making updates straightforward
2. **Adding New Document Types**: Simply create a new file in `lib/diataxis/document/` following the established pattern
3. **Code Navigation**: Developers can quickly locate specific document type logic
4. **Testing**: Each class can be tested in isolation with focused test files
5. **Code Reviews**: Changes to specific document types are easier to review in isolation

### What becomes more difficult

1. **File Management**: More files to track in version control, though this is minimal overhead
2. **Initial Learning**: New contributors need to understand the directory structure, though it follows Ruby conventions

### Risks Mitigated

- Verified full functionality through comprehensive testing of all CLI commands
- Maintained existing require structure to ensure no breaking changes
- Preserved all existing class relationships and dependencies

The refactoring successfully achieves the goal of improved maintainability while preserving all existing functionality.
