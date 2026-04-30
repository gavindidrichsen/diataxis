---
id: T01
parent: S05
milestone: M001-3b7cia
key_files:
  - templates/references/note.md
  - templates/references/fivewhyanalysis.md
key_decisions:
  - Kept project.md unmodified — its GTD-specific HTML comment serves a different purpose than common.metadata (per D004)
  - Kept adr.md unmodified — follows community ADR standard format
  - Used handover.md's wrapper pattern as the closest reference for both templates since they are in the same references/ category
  - Included Issues linking rule in fivewhyanalysis.md template-specific guidelines to match its existing References section content
duration: 
verification_result: passed
completed_at: 2026-04-30T00:31:35.538Z
blocker_discovered: false
---

# T01: Added {{common.metadata}} HTML comment wrapper to note.md and fivewhyanalysis.md templates for consistency with the other 6 non-ADR templates

**Added {{common.metadata}} HTML comment wrapper to note.md and fivewhyanalysis.md templates for consistency with the other 6 non-ADR templates**

## What Happened

Two of 9 templates (`note.md` and `fivewhyanalysis.md`) lacked the `{{common.metadata}}` HTML comment wrapper that the other 6 non-ADR templates already use. This task added the standard wrapper pattern to both templates.

Read the existing wrapper pattern from `explanation.md` and `handover.md` as references. The pattern is an HTML comment block at the top of the template containing `# Common Guidelines` / `{{common.metadata}}` / `# Template-Specific Guidelines` with linking rules appropriate to each template type.

Added the wrapper to `note.md` with standard linking rules (Code, Docs, Local). Added the wrapper to `fivewhyanalysis.md` with linking rules that include Issues in addition to Code, Docs, and Local — matching the reference types already present in that template's References section.

Confirmed `project.md` was NOT modified (its GTD-specific HTML comment serves a different purpose per D004). Confirmed `adr.md` was NOT modified (community ADR standard format).

The `TemplateLoader` at `lib/diataxis/template_loader.rb:12-19` already handles `{{common.metadata}}` substitution — it checks for the placeholder and replaces it with the contents of `templates/common.metadata`. No code changes were needed; only the two template files were modified.

## Verification

Ran `bundle exec rspec` — 46 examples, 0 failures. All template-loading tests pass, including note and 5why template structure tests.

Ran `bundle exec cucumber` — 6 scenarios (6 passed), 39 steps (39 passed). No behavioral regressions.

Ran `grep -c 'common.metadata' templates/references/note.md` — returned 1 (present).
Ran `grep -c 'common.metadata' templates/references/fivewhyanalysis.md` — returned 1 (present).
Ran `grep -c 'common.metadata' templates/references/project.md` — returned 0 (correctly absent).
Ran `grep -c 'common.metadata' templates/references/adr.md` — returned 0 (correctly absent).

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bundle exec rspec` | 0 | ✅ pass | 297ms |
| 2 | `bundle exec cucumber` | 0 | ✅ pass | 2238ms |
| 3 | `grep -c 'common.metadata' templates/references/note.md` | 0 | ✅ pass (returns 1) | 10ms |
| 4 | `grep -c 'common.metadata' templates/references/fivewhyanalysis.md` | 0 | ✅ pass (returns 1) | 10ms |
| 5 | `grep -c 'common.metadata' templates/references/project.md` | 1 | ✅ pass (returns 0 — correctly absent) | 10ms |
| 6 | `grep -c 'common.metadata' templates/references/adr.md` | 1 | ✅ pass (returns 0 — correctly absent) | 10ms |

## Deviations

None

## Known Issues

None

## Files Created/Modified

- `templates/references/note.md`
- `templates/references/fivewhyanalysis.md`
