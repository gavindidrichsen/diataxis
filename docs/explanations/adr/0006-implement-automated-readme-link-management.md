# 6. Implement Automated README Link Management

Date: 2025-03-06
Status: Accepted

## Context

Maintaining documentation links in README files presents several challenges:

1. **Manual Updates**: As documentation grows, manually maintaining links becomes error-prone
2. **Link Consistency**: When files are renamed or moved, links can break
3. **Organization**: Different document types need appropriate categorization
4. **Discoverability**: Users need an easy way to find relevant documentation

This is particularly important in the context of the Diátaxis framework, where documents serve different purposes and need clear organization.

## Decision

We will implement an automated README link management system that:

1. Uses HTML comments as section markers:
```markdown
<!-- howtolog -->
[Links to How-To guides automatically inserted here]
<!-- howtologstop -->

<!-- tutoriallog -->
[Links to Tutorials automatically inserted here]
<!-- tutoriallogstop -->

<!-- explanationlog -->
[Links to Explanations automatically inserted here]
<!-- explanationlogstop -->

<!-- adrlog -->
[Links to ADRs automatically inserted here]
<!-- adrlogstop -->
```

2. Automatically manages links:
   - Scans configured document directories
   - Extracts titles from markdown files
   - Updates links between markers
   - Preserves other README content

3. Implements intelligent link formatting:
   - How-To: `[How to Configure System](how-to/how_to_configure_system.md)`
   - Tutorial: `[Getting Started](tutorials/tutorial_getting_started.md)`
   - Explanation: `[Understanding Architecture](explanations/understanding_architecture.md)`
   - ADR: `[ADR-0001](explanations/adr/0001-decision-title.md)`

4. Provides automatic updates:
   - When new documents are created
   - When documents are renamed
   - When titles are changed
   - During bulk updates (`dia update .`)

## Consequences

### Positive

1. **Reliability**: Links are always up-to-date and valid
2. **Consistency**: Links follow a standard format
3. **Organization**: Documents are properly categorized
4. **Maintenance**: No manual link management needed
5. **Discoverability**: Clear section organization helps users find documents

### Negative

1. **Flexibility**: Custom link arrangements require special handling
2. **Learning Curve**: Authors need to understand the marker system
3. **Dependencies**: README updates depend on the automation tool

### Neutral

1. **Performance**: Link updates add minimal overhead to operations
2. **Migration**: Existing READMEs need one-time setup of markers

## Notes

- The system preserves custom content outside marked sections
- Link formats are consistent with document naming conventions
- The automation runs as part of document creation and update workflows
What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?
