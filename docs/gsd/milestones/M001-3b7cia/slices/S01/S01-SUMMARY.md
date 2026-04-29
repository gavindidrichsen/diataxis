---
id: S01
parent: M001-3b7cia
milestone: M001-3b7cia
provides:
  - ["templates/common.metadata — universal formatting rules file (~9 lines)", "TemplateLoader#resolve_placeholder — extended to handle {{common.metadata}} by reading and injecting the common metadata file content", "Templates updated with {{common.metadata}} placeholder replacing hardcoded common blocks", "Document#pattern — fixed to respect type-specific config directories"]
requires:
  []
affects:
  []
key_files:
  - ["templates/common.metadata", "lib/diataxis/template_loader.rb", "lib/diataxis/document.rb", "diataxis.gemspec", "spec/template_loader_spec.rb", "templates/explanations/explanation.md", "templates/tutorials/tutorial.md", "templates/how-tos/howto.md", "templates/explanations/pr.md", "templates/references/handover.md"]
key_decisions:
  - ["common.metadata contains raw guideline content only — no HTML comment delimiters or section headers; templates own the wrapper structure", "TemplateLoader resolves {{common.metadata}} before {{title}}/{{date}} to prevent double-substitution", "Gemspec uses Dir['templates/**/*'] glob to capture all template files including non-.md files", "Fixed Document#pattern to use type-specific config_key instead of hardcoded 'default' key"]
patterns_established:
  - ["Layered template system: common.metadata (raw content) + template-owned HTML comment wrapper with section headers", "Placeholder resolution ordering: common.metadata → title → date", "Type-specific config lookup pattern: Config.load(config_root)[type_config[:config_key]]"]
observability_surfaces:
  - none
drill_down_paths:
  []
duration: ""
verification_result: passed
completed_at: 2026-04-29T04:57:54.451Z
blocker_discovered: false
---

# S01: Common metadata template injection

**Extracted universal formatting rules to templates/common.metadata, wired {{common.metadata}} placeholder resolution in TemplateLoader, updated all 5 metadata-bearing templates, added unit tests, and fixed a pre-existing Document#pattern bug that broke custom config directory lookups.**

## What Happened

## What This Slice Delivered

This slice established the common metadata injection system — the foundation for eliminating duplicated template metadata across the diataxis gem.

### T01: Common metadata file and TemplateLoader extension

Created `templates/common.metadata` with the 6 universal formatting rule bullets (Style Guidelines header + 6 items). Extended `TemplateLoader.load_template()` to resolve `{{common.metadata}}` placeholders before `{{title}}`/`{{date}}` substitutions. If a template contains the placeholder, the loader reads `templates/common.metadata` relative to `gem_root` and injects the content. Missing file raises `TemplateError` with a descriptive message. Templates without the placeholder are unaffected. Broadened the gemspec glob from `Dir['templates/*.md']` to `Dir['templates/**/*']` to include the new non-`.md` file.

### T02: Template updates with section-header structure

All 5 metadata-bearing templates (explanation, tutorial, howto, pr, handover) were updated to use `{{common.metadata}}` inside an explicit `<!-- # Common Guidelines ... # Template-Specific Guidelines ... -->` HTML comment structure. The common.metadata file contains raw guideline content only — no HTML delimiters or section headers — and templates own the wrapper structure. Type-specific metadata lines remain hardcoded after `# Template-Specific Guidelines` in each template. Templates without metadata (adr, note, fivewhyanalysis, project) were left untouched.

### T03: TemplateLoader unit tests

Added `spec/template_loader_spec.rb` with 6 focused test cases: placeholder resolution, ordering guarantee (placeholder resolved before title/date), no-placeholder templates pass through, missing common.metadata raises TemplateError, and behavioral equivalence for explanation and handover document types.

### Bug fix: Document#pattern custom config lookup

During slice completion verification, `bundle exec cucumber` revealed a pre-existing bug in `Document#pattern` (document.rb line 28-30). The method called `Config.path_for('default')` which always returned the `'default'` config key value (typically `'docs'`), ignoring type-specific directory overrides like `"howtos": "test_docs/how-to"`. This meant `find_files` searched the wrong directory when custom config paths were set, causing the README generation to miss document sections entirely.

**Fix:** Changed `pattern()` to load config from the passed `config_root` and use the document type's `config_key` to look up the correct configured directory: `config[type_config[:config_key]] || config['default']`. This restored correct behavior for all Cucumber scenarios including the previously-failing `configuration_management.feature:26`.

## Verification

## Verification Results

All slice-level verification checks pass:

| # | Command | Exit Code | Result |
|---|---------|-----------|--------|
| 1 | `bundle exec rspec` | 0 | 37 examples, 0 failures |
| 2 | `bundle exec rspec spec/template_loader_spec.rb` | 0 | 6 examples, 0 failures |
| 3 | `bundle exec cucumber` | 0 | 6 scenarios, 39 steps — all passed |
| 4 | `grep -r '{{common.metadata}}' templates/` | 0 | Found in all 5 target templates |
| 5 | `test -f templates/common.metadata` | 0 | File exists |

The previously-failing Cucumber scenario (`configuration_management.feature:26 — README contains correct how-to link`) now passes after fixing the `Document#pattern` bug.

## Requirements Advanced

- R001 — Common metadata injection fully implemented — templates/common.metadata created, TemplateLoader resolves {{common.metadata}}, all 5 target templates updated
- R002 — Per-template specific metadata confirmed hardcoded — each of the 5 templates retains type-specific instructions after # Template-Specific Guidelines header

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

The slice closer discovered and fixed a pre-existing bug in Document#pattern (document.rb) that was unrelated to template metadata work but was causing the Cucumber verification gate to fail. The pattern() method used Config.path_for('default') instead of the type-specific config key, breaking custom directory configurations. This fix was necessary to pass all verification checks.

## Known Limitations

None.

## Follow-ups

S02 (Registry DSL and template method pattern) can now build on the common metadata system established here. The TemplateLoader's placeholder resolution is extensible for future placeholders if needed.

## Files Created/Modified

- `templates/common.metadata` — New file: 6 universal formatting rule bullets (Style Guidelines header + 6 items)
- `lib/diataxis/template_loader.rb` — Extended load_template to resolve {{common.metadata}} placeholder before title/date substitutions
- `lib/diataxis/document.rb` — Fixed pattern() to use type-specific config_key instead of hardcoded 'default' — fixes custom config directory lookups
- `diataxis.gemspec` — Broadened templates glob from Dir['templates/*.md'] to Dir['templates/**/*']
- `spec/template_loader_spec.rb` — New file: 6 unit tests for TemplateLoader placeholder resolution
- `templates/explanations/explanation.md` — Replaced hardcoded Style Guidelines with {{common.metadata}} in section-header structure
- `templates/tutorials/tutorial.md` — Replaced hardcoded Style Guidelines with {{common.metadata}} in section-header structure
- `templates/how-tos/howto.md` — Replaced hardcoded Style Guidelines with {{common.metadata}} in section-header structure
- `templates/explanations/pr.md` — Replaced hardcoded Style Guidelines with {{common.metadata}} in section-header structure
- `templates/references/handover.md` — Replaced hardcoded Style Guidelines with {{common.metadata}} in section-header structure
