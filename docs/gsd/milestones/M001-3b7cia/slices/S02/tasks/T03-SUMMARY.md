---
id: T03
parent: S02
milestone: M001-3b7cia
key_files:
  - lib/diataxis/document/adr.rb
  - lib/diataxis/document/howto.rb
  - lib/diataxis/document/explanation.rb
  - lib/diataxis/document/tutorial.rb
  - lib/diataxis/document/handover.rb
  - lib/diataxis/document/five_why_analysis.rb
  - lib/diataxis/document/note.rb
  - lib/diataxis/document/project.rb
  - lib/diataxis/document/pr.rb
key_decisions:
  - Kept HowTo initialize override as-is — works correctly as named subclass, forcing through customize_title adds complexity for no benefit
  - ADR pattern fix uses type_config[:config_key] lookup with fallback to 'default', matching the base class pattern from S01
duration: 
verification_result: passed
completed_at: 2026-04-29T17:35:37.473Z
blocker_discovered: false
---

# T03: Fix ADR pattern bug (Config.path_for→Config.load) and add template:/section_tag: to all 9 document subclass register_type calls

**Fix ADR pattern bug (Config.path_for→Config.load) and add template:/section_tag: to all 9 document subclass register_type calls**

## What Happened

Fixed the pre-existing bug in ADR's `pattern` class method where `Config.path_for('default')` always loaded config from the process cwd and looked up only the 'default' key, ignoring the config_root parameter and ADR-specific directory config. Replaced with `Config.load(config_root)` and lookup via `type_config[:config_key]` with fallback to `'default'` — the same pattern the base class Document already uses after the S01 fix.

Added `template:` and `section_tag:` keys to all 9 document subclass `register_type` calls (ADR, HowTo, Explanation, Tutorial, Handover, FiveWhyAnalysis, Note, Project, PR). These keys enable TemplateLoader and ReadmeManager to resolve template files and README section tags via config lookup rather than deriving them from the class name — critical for the registry DSL where anonymous subclasses have no class name.

HowTo's `initialize` override was intentionally left as-is per the task plan's decision: it works correctly, HowTo remains a named subclass, and forcing it through `customize_title` would add complexity for no benefit.

## Verification

1. `bundle exec rspec` — 37 examples, 0 failures
2. `bundle exec cucumber` — 6 scenarios, 39 steps, all passed
3. `grep -l 'template:' lib/diataxis/document/*.rb | wc -l` — returns 9 (all document subclass files)
4. `grep 'Config.path_for' lib/diataxis/document/adr.rb` — no output (bug removed)

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bundle exec rspec` | 0 | ✅ pass | 195ms |
| 2 | `bundle exec cucumber` | 0 | ✅ pass | 1912ms |
| 3 | `grep -l 'template:' lib/diataxis/document/*.rb | wc -l` | 0 | ✅ pass (9 files) | 50ms |
| 4 | `grep 'Config.path_for' lib/diataxis/document/adr.rb` | 1 | ✅ pass (no matches) | 30ms |

## Deviations

None — implementation matched the task plan exactly.

## Known Issues

None.

## Files Created/Modified

- `lib/diataxis/document/adr.rb`
- `lib/diataxis/document/howto.rb`
- `lib/diataxis/document/explanation.rb`
- `lib/diataxis/document/tutorial.rb`
- `lib/diataxis/document/handover.rb`
- `lib/diataxis/document/five_why_analysis.rb`
- `lib/diataxis/document/note.rb`
- `lib/diataxis/document/project.rb`
- `lib/diataxis/document/pr.rb`
