<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Scope Check — how broad is this decision?**
- ADRs span a spectrum: some change system structure, technology choices, or component boundaries; others are narrower, made while building within an already-settled architecture (e.g. "why this repo over that one for a migration," "why this hook is scoped the way it is").
- Tag the narrower kind with `-scope/implementation` (`-t -scope/implementation`, or add it to the frontmatter `tags:` list by hand) so readers and AI agents can gauge blast radius at a glance, without a separate document type or numbering stream to maintain.
- Leave the tag off for decisions that do change structure, technology choices, or component boundaries — that's the default, untagged case.
- Still unsure? Ask: "would reversing this decision require a rearchitecture, or just a rewrite of one component?" Rearchitecture → no tag. Rewrite of one component → tag `-scope/implementation`.

**Additional Linking Rules:**
- **Related ADRs**: Link to other ADRs: [[0001-title|ADR-0001]].
-->

# {{adr_number}}. {{title}}

Date: {{date}}

## Status

{{status}}

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?

## Related Topics

- Related ADRs, code, documentation, and local docs links go here.
