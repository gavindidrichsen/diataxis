---
id: T01
parent: S02
milestone: M001-3b7cia
key_files:
  - lib/diataxis/document.rb
key_decisions:
  - Placed all 4 hooks in the protected section alongside apply_title_prefix, since they serve the same purpose (subclass extension points)
  - customize_filename returns nil (not false) as the sentinel for 'use default logic' — consistent with Ruby idiom and allows truthy/falsy guard
duration: 
verification_result: passed
completed_at: 2026-04-29T17:27:02.936Z
blocker_discovered: false
---

# T01: Add 4 template method hooks (customize_title, customize_filename, customize_content, customize_readme_entry) to Document base class with no-op defaults

**Add 4 template method hooks (customize_title, customize_filename, customize_content, customize_readme_entry) to Document base class with no-op defaults**

## What Happened

Added 4 protected template method hooks to `Document` in `lib/diataxis/document.rb`:

1. **`customize_title(title)`** — returns title unchanged. Wired into `initialize` after `apply_title_prefix`, so subclasses (e.g. HowTo) can normalize titles.

2. **`customize_filename(title, dir)`** — returns nil (meaning "use default logic"). Wired into `initialize` after the default filename is computed; only overrides when non-nil, so ADR can inject auto-numbered filenames.

3. **`customize_content(content)`** — returns content unchanged. Wired into the `content` method wrapping `TemplateLoader.load_template`, so ADR can inject adr_number/status into template output.

4. **`customize_readme_entry(title, path, filepath)`** — returns nil. Not wired into the class-level `format_readme_entry` in this task (that delegation happens in T03 when ADR overrides it).

All hooks use no-op defaults so existing behavior is completely unchanged. This is confirmed by the full test suite passing with zero modifications to any test file.

## Verification

Ran the full verification suite:
- `bundle exec rspec`: 37 examples, 0 failures (0.29s)
- `bundle exec cucumber`: 6 scenarios, 39 steps all passing (1.7s)
- `grep -c 'def customize_' lib/diataxis/document.rb`: returns 4

All existing behavior preserved — zero test changes required.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bundle exec rspec` | 0 | ✅ pass — 37 examples, 0 failures | 290ms |
| 2 | `bundle exec cucumber` | 0 | ✅ pass — 6 scenarios, 39 steps all passing | 1708ms |
| 3 | `grep -c 'def customize_' lib/diataxis/document.rb` | 0 | ✅ pass — returns 4 | 50ms |

## Deviations

None — implementation matched the plan exactly.

## Known Issues

None.

## Files Created/Modified

- `lib/diataxis/document.rb`
