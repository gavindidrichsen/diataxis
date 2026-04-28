# S01: Common metadata template injection — Handoff

**Date:** 2026-04-28
**Status:** Planned, ready for execution
**Branch:** development (clean)

## What happened

- Milestone M001-3b7cia (Template Metadata and Registration Refactor) was planned with 5 slices
- S01 research was completed — identified the 6 universal formatting rule bullets shared across 5 templates
- S01 was planned, then **replanned** per user feedback on template structure

## Key design decision (user-directed)

The user wants templates to own the full HTML comment structure with explicit section headers:

```markdown
<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines
...type-specific metadata stays here...
-->
```

This means `common.metadata` contains only the raw guideline bullets — no `<!--`, no `-->`, no section headers. The template controls the wrapper. This is simpler and more transparent than the original research proposal.

## What's ready

- **S01-PLAN.md** is current with 3 tasks:
  - T01: Create common.metadata + extend TemplateLoader + fix gemspec (30m)
  - T02: Update 5 templates to use placeholder with section-header structure (45m)
  - T03: Add TemplateLoader unit tests (30m)
- **Task plans** (T01-PLAN.md, T02-PLAN.md, T03-PLAN.md) have full steps, must-haves, and verification
- **Research** (S01-RESEARCH.md) has the detailed line-by-line analysis of all templates

## What to do next

1. Execute S01 tasks (T01 → T02 → T03) — `/gsd auto` or manual execution
2. After S01 completes, plan S02 (Registry DSL and template method pattern)

## Decisions in effect

- D001: `{{common.metadata}}` placeholder mechanism (collaborative, non-revisable)
- D002: Pure Ruby registry DSL (collaborative, non-revisable) — S02 scope
- D003: Template method with default no-ops (collaborative, revisable if >5 custom types) — S02 scope
- D004: Narrow common metadata scope (~6 bullets) (collaborative, non-revisable)

## Requirements owned by S01

- R001: Common metadata template injection (active)
- R002: Per-template specifics stay hardcoded (active)
