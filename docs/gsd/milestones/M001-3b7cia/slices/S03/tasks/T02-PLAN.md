---
estimated_steps: 7
estimated_files: 2
skills_used: []
---

# T02: Add regression tests for filename-doubling bug covering multiple document types

Add rspec tests that verify the prefix-doubling bug is fixed. Test scenarios:

1. `generate_filename_from_file` with a file whose title contains the type word (e.g. 'Project: Fixing the dia update bug') — should produce 'project_fixing_the_dia_update_bug.md', not 'project_project_fixing_the_dia_update_bug.md'

2. `generate_filename_from_file` with a file whose title does NOT start with the type word — should still work correctly (no regression)

3. `generate_filename` (instance method) with a title that would produce a slug starting with the prefix — should not double

4. Test with at least 3 document types: project (no title_prefix), note (no title_prefix), and explanation (has title_prefix 'Understanding')

5. Test that `generate_filename_from_existing` returns nil when the filename is already correct (idempotency check)

Create a new spec file spec/document_filename_spec.rb or add to existing spec/diataxis_spec.rb.

## Inputs

- `lib/diataxis/document.rb — fixed Document class from T01`
- `spec/spec_helper.rb — existing test helper`

## Expected Output

- `spec/document_filename_spec.rb — new regression test file with prefix-doubling tests`

## Verification

bundle exec rspec spec/document_filename_spec.rb && bundle exec rspec && bundle exec cucumber
