---
id: T01
parent: S03
milestone: M001-3b7cia
key_files:
  - lib/diataxis/document.rb
key_decisions:
  - Used start_with? guard before regex sub to avoid unnecessary regex work on the common path
  - Extracted prefix into a local variable for clarity and to avoid repeated hash lookups
duration: 
verification_result: passed
completed_at: 2026-04-29T23:01:13.834Z
blocker_discovered: false
---

# T01: Add prefix-stripping to generate_filename_from_file and generate_filename to prevent filename doubling when slug already starts with the type prefix

**Add prefix-stripping to generate_filename_from_file and generate_filename to prevent filename doubling when slug already starts with the type prefix**

## What Happened

Added prefix-stripping logic to both filename-generation methods in `lib/diataxis/document.rb`:

1. **`generate_filename_from_file` (class method, line 46):** After the slug is built, a new local `prefix` variable captures `type_config[:prefix]`. If the slug starts with `prefix + separator`, the leading prefix+separator is stripped via `String#sub` before the prefix is prepended again. This prevents titles like "Project: Fixing foo" (which slugify to `project_fixing_foo`) from becoming `project_project_fixing_foo.md`.

2. **`generate_filename` (instance method, line 134):** Identical logic applied — after slug construction, strip a leading `prefix + sep` if present before the final `"#{prefix}#{sep}#{slug}.md"` concatenation.

The stripping uses `Regexp.escape` on both the prefix and separator to handle any special characters safely. The `start_with?` guard ensures the regex is only applied when the slug actually begins with the prefix, avoiding unnecessary regex work on the common case.

## Verification

Ran the full test suite to confirm the fix introduces no regressions:

- `bundle exec rspec` — 37 examples, 0 failures (0.25s)
- `bundle exec cucumber` — 6 scenarios, 39 steps, all passed (1.8s)

Both suites pass cleanly. The existing tests for explanation documents (which have a `title_prefix` of "Understanding") confirm that the title-prefix stripping and the new slug-prefix stripping work together correctly.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bundle exec rspec` | 0 | ✅ pass | 640ms |
| 2 | `bundle exec cucumber` | 0 | ✅ pass | 1797ms |

## Deviations

None. The plan's suggested line numbers and logic matched the actual code exactly.

## Known Issues

None. Regression tests for the prefix-doubling scenario specifically are planned for T02.

## Files Created/Modified

- `lib/diataxis/document.rb`
