<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Scope Check — IDR, not ADR:**
- An IDR records an *implementation-design* decision made while building within an already-settled architecture — narrower and more local than an ADR (e.g. "why this repo over that one for a migration," "why this hook is scoped the way it is").
- If this decision changes system structure, technology choices, or component boundaries, it's an ADR, not an IDR — use `dia adr new` instead.
- Still unsure? Ask: "would reversing this decision require a rearchitecture, or just a rewrite of one component?" Rearchitecture → ADR. Rewrite → IDR.

**Additional Linking Rules:**
- **Related IDRs**: Link to other IDRs: [[0001-title|IDR-0001]].
-->

# {{idr_number}}. {{title}}

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

- Related IDRs, code, documentation, and local docs links go here.
