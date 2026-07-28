<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Scope Check — WoW, not ADR:**
- A WoW records a *team process / working-agreement* decision — how people coordinate (branching discipline, review norms, escalation paths) — never a technical decision about the system itself. If what you're recording changes system structure, technology choices, component boundaries, or an internal implementation choice, use `dia adr new` instead (tag it `-scope/implementation` if it's the narrower, implementation-level kind — see the ADR template's Scope Check).

**Trace the WoW back to what surfaced it (mandatory):**
- A WoW is almost always distilled from something else — a 5-Whys root cause, a project/investigation doc, a support ticket, a retro, a repeated friction point. Name that source in Context and link it (wiki-link for a local doc, permalink for a ticket/PR/commit). A WoW with no traceable origin is just an opinion, not a decision worth recording.
- State the working agreement itself in Decision as an actionable, quotable rule — worded so it can be cited later (e.g. "per WoW-branch-discipline, always create a feature branch before...").

**Tag for later collection:**
- Apply a topic tag alongside the standard tags so related WoWs group together, e.g. `-wow/branching`, `-wow/testing`, `-wow/review`. `dia update` already lists every WoW under the auto-generated "### Ways of Working" README section — consistent topic tags make that list filterable/groupable when you come back to summarize.

**Additional Linking Rules:**
- **Related WoWs**: Link to other WoW records with a normal wiki-link: [[wow_slug|title]].
-->

# {{title}}

Date: {{date}}

## Context

What problem, investigation, or recurring friction surfaced this working agreement? Name and link the source (a fivewhy, a project doc, a ticket, a retro) — this is what makes the WoW traceable rather than an unmoored opinion.

## Decision

State the working agreement as an actionable, quotable rule — worded so it can be cited later.

## Consequences

What becomes easier or more difficult to do because of this agreement?

## Related Topics

- Related WoW records, code, documentation, and local docs links go here.
