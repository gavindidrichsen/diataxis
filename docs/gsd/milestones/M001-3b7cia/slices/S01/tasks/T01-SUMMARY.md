---
id: T01
parent: S01
milestone: M001-3b7cia
key_files:
  - templates/common.metadata
  - lib/diataxis/template_loader.rb
  - diataxis.gemspec
key_decisions:
  - Used Dir['templates/**/*'] glob instead of explicitly listing common.metadata — captures future non-.md template files too
  - Placed common.metadata resolution before {{title}}/{{date}} gsub to match the plan's specified ordering
duration: 
verification_result: passed
completed_at: 2026-04-28T19:54:14.007Z
blocker_discovered: false
---

# T01: Add common.metadata template file, extend TemplateLoader to resolve {{common.metadata}} placeholder, and broaden gemspec glob to include all template files

**Add common.metadata template file, extend TemplateLoader to resolve {{common.metadata}} placeholder, and broaden gemspec glob to include all template files**

## What Happened

Created `templates/common.metadata` containing the 6 universal formatting rule bullets (Style Guidelines header + 6 dash-prefixed items) that are identical across all templates carrying metadata. The file contains raw guideline content only — no HTML comment delimiters, no section headers — following the design decision that templates own the full comment wrapper structure.

Extended `TemplateLoader.load_template()` to resolve `{{common.metadata}}` before the existing `{{title}}`/`{{date}}` substitutions. The implementation checks if the template content contains the placeholder; if so, it locates `templates/common.metadata` relative to `gem_root` (same `File.expand_path('../..', __dir__)` pattern used by `find_template_file`), reads it with `.chomp`, and performs the gsub. If the common file is missing, a `TemplateError` is raised with a descriptive message and search paths. Templates without the placeholder are unaffected — no error, no action.

Fixed `diataxis.gemspec` line 30: changed the safety-net glob from `Dir['templates/*.md']` (which only matched `.md` files in the root templates directory) to `Dir['templates/**/*']` (which captures all files in all subdirectories, including the new `common.metadata` file and existing subdirectory templates).

## Verification

Ran all four verification checks from the task plan:

1. `ruby -e "require_relative 'lib/diataxis'; puts Diataxis::TemplateLoader.methods"` — module loads without error, `load_template` and `find_template_file` methods present.
2. `bundle exec rspec` — all 37 existing specs pass (0 failures, 0.18s). No templates modified yet so existing behavior unaffected.
3. Verified gemspec glob `Dir['templates/**/*']` outputs include `templates/common.metadata`.
4. `test -f templates/common.metadata` — file exists.

Additionally ran a functional Ruby test confirming: (a) placeholder resolves correctly when present, (b) templates without the placeholder are unaffected, (c) common.metadata file is found at the expected gem_root-relative path.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `ruby -e "require_relative 'lib/diataxis'; puts Diataxis::TemplateLoader.methods"` | 0 | pass | 500ms |
| 2 | `bundle exec rspec` | 0 | pass — 37 examples, 0 failures | 1100ms |
| 3 | `ruby -e "puts Dir['templates/**/*']" (gemspec glob check)` | 0 | pass — common.metadata included in output | 200ms |
| 4 | `test -f templates/common.metadata` | 0 | pass | 50ms |
| 5 | `ruby functional test (placeholder resolution, no-placeholder passthrough, file lookup)` | 0 | pass — all 3 assertions passed | 300ms |

## Deviations

The plan's verification command `grep -q 'common.metadata' diataxis.gemspec` returns FAIL because we used a wildcard glob `templates/**/*` rather than an explicit filename reference. The glob correctly includes the file (verified by running the glob in Ruby), so this is a cosmetic mismatch in the verification command, not a real failure.

## Known Issues

None.

## Files Created/Modified

- `templates/common.metadata`
- `lib/diataxis/template_loader.rb`
- `diataxis.gemspec`
