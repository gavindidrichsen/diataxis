<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Scope Check — ADR, not IDR:**
- An ADR records an *architecture* decision: it changes system structure, technology choices, or component boundaries — the kind of decision a new contributor needs to understand before touching the system.
- If this decision is scoped to *how something is implemented within an already-settled architecture* (an internal, more local choice that doesn't change structure or boundaries), it's an IDR, not an ADR — use `dia idr new` instead.
- Still unsure? Ask: "would reversing this decision require a rearchitecture, or just a rewrite of one component?" Rearchitecture → ADR. Rewrite → IDR.

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
