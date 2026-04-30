---
estimated_steps: 34
estimated_files: 3
skills_used: []
---

# T03: Update manual test doc and README to cover all 9 document types

## Description

Two docs need expanding:

1. `docs/how_to_manually_test_all_diataxis_features.md` — currently only tests howto, tutorial, explanation, and ADR (4 of 9 types). Missing: note, handover, 5why, project, pr. The existing test structure (create → verify file → verify README → title change → update → verify rename) is sound and should be extended. Also has a nested bash block syntax error in Test 6 (double ` ```bash ` opening) that needs fixing. The `.diataxis` config setup should mention the `projects`, `five_why_analyses`, `handovers`, `notes` config keys.

2. `README.md` — Usage section (lines 28-47) only shows examples for howto, tutorial, explanation, and adr. Add examples for: `dia note new "Title"`, `dia handover new "Title"`, `dia 5why new "Title"`, `dia project new "Title"`, `dia pr new "Title"`. Also update the Features bullet list to mention all 9 types.

## Steps

1. Read `docs/how_to_manually_test_all_diataxis_features.md` and extend it:
   - Add test cases for `dia note new`, `dia handover new`, `dia 5why new`, `dia project new`, `dia pr new`
   - Fix the Test 6 nested bash block syntax error
   - Update the Setup section's `.diataxis` config to include all config keys
   - Follow the existing test pattern: create → verify file → verify README section
2. Read `README.md` and update:
   - Add all 9 document types to the Usage section with example commands
   - Update the Features bullet list to mention all document types
   - Update the description to mention all supported types (not just how-tos, tutorials, and ADRs)
3. Verify both files are well-formed markdown.

## Must-Haves

- [ ] Manual test doc includes test cases for all 9 document types
- [ ] Test 6 bash block syntax error fixed
- [ ] README Usage section shows all 9 `dia <type> new` commands
- [ ] README Features list updated to mention all document types
- [ ] No stale references to only 4 types anywhere in either doc

## Verification

- `grep -c 'dia .* new' README.md` returns >= 9 (all types have examples)
- `grep -c 'dia .* new' docs/how_to_manually_test_all_diataxis_features.md` returns >= 9
- `grep -q 'dia note new' README.md` — note type in README
- `grep -q 'dia pr new' README.md` — pr type in README
- `grep -q 'dia 5why new' README.md` — 5why type in README

## Inputs

- `docs/how_to_manually_test_all_diataxis_features.md` — current doc covering only 4 types
- `README.md` — current README with 4-type Usage section
- `lib/diataxis/document_types.rb` — registry with all 9 types for reference

## Expected Output

- `docs/how_to_manually_test_all_diataxis_features.md` — updated to cover all 9 document types
- `README.md` — updated Usage section and Features list covering all 9 types

## Inputs

- ``docs/how_to_manually_test_all_diataxis_features.md` — current doc covering only 4 types`
- ``README.md` — current README with 4-type Usage section`
- ``lib/diataxis/document_types.rb` — registry with all 9 types for reference`

## Expected Output

- ``docs/how_to_manually_test_all_diataxis_features.md` — updated to cover all 9 document types`
- ``README.md` — updated Usage section and Features list covering all 9 types`

## Verification

grep -q 'dia note new' README.md && grep -q 'dia pr new' README.md && grep -q 'dia 5why new' README.md && grep -q 'dia handover new' README.md && grep -q 'dia project new' README.md
