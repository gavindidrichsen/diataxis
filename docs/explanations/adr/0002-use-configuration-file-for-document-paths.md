# 2. Use Configuration File for Document Paths

Date: 2025-02-20

## Status

Accepted

## Context

When organizing documentation according to the Diataxis framework, we need to specify where different types of documents (how-tos, tutorials, explanations, reference) should be stored. There are several ways we could handle this:

* Hardcode the paths in the code
* Use command-line arguments for each path
* Use environment variables
* Use a configuration file

We need a solution that is:

* Flexible enough to work with different project structures
* Easy to version control
* Simple to modify without changing code
* Discoverable by new users

## Decision

We will use a `.diataxis` JSON configuration file to specify document paths. This file will:

* Be placed in the project root directory
* Use JSON format for easy parsing and modification
* Include paths for each document type:

```json
{
  "readme": "docs/README.md",
  "howtos": "docs/how-to",
  "tutorials": "docs/tutorials",
  "adr": "docs/exp/adr"
}
```

* Support both absolute and relative paths
* Fall back to sensible defaults if not specified

## Consequences

### Positive

* Project-specific configuration is easy to version control
* Users can customize document locations without modifying code
* JSON format is widely understood and easy to edit
* Configuration is centralized in one discoverable location
* Default values mean minimal configuration is needed to get started

### Negative

* Additional file to maintain in the project
* Need to handle file parsing errors and validation
* Need to implement configuration file discovery logic
* May need to handle backward compatibility if format changes
