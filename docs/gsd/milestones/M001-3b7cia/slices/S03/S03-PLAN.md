# S03: Fix dia update filename-doubling bug when slug starts with prefix

**Goal:** Fix the filename-doubling bug where `dia update .` prepends the prefix again when the slug already starts with the prefix word (e.g. project_fixing_foo.md → project_project_fixing_foo.md). After this slice, `dia update .` is idempotent for all 9 document types — running it twice produces the same filename.
**Demo:** dia update . on a directory with files like project_fixing_foo.md no longer renames them to project_project_fixing_foo.md; regression tests cover all 9 document types

## Must-Haves

- `bundle exec rspec` passes with 0 failures including new regression tests\n- `bundle exec cucumber` passes with 0 failures\n- New regression tests cover prefix-doubling scenario for at least project, note, and explanation types\n- Running `dia update .` twice on a test directory produces identical filenames both times (idempotent)

## Proof Level

- This slice proves: integration — real runtime required, no UAT needed

## Integration Closure

Not provided.

## Verification

- Not provided.

## Tasks

- [ ] **T01: Add prefix-stripping logic to generate_filename_from_file and generate_filename in document.rb** `est:20m`
  Fix the two methods that build filenames from titles. Both methods build a slug from the title and prepend type_config[:prefix], but neither checks whether the slug already starts with the prefix. The fix: after building the slug, strip a leading `prefix + separator` if present before prepending it again.

In `generate_filename_from_file` (class method, line 46): after the slug is built on line 46, add prefix-stripping before line 47.

In `generate_filename` (instance method, line 134): after the slug is built on line 134, add prefix-stripping before line 135.

The stripping logic: `slug = slug.sub(/^#{Regexp.escape(prefix)}#{Regexp.escape(sep)}/, '') if slug.start_with?("#{prefix}#{sep}")`

This ensures that a title like 'Project: Fixing foo' which slugifies to 'project_fixing_foo' stays as 'project_fixing_foo' after prefix prepend, not 'project_project_fixing_foo'.
  - Files: `lib/diataxis/document.rb`
  - Verify: bundle exec rspec && bundle exec cucumber

- [ ] **T02: Add regression tests for filename-doubling bug covering multiple document types** `est:30m`
  Add rspec tests that verify the prefix-doubling bug is fixed. Test scenarios:

1. `generate_filename_from_file` with a file whose title contains the type word (e.g. 'Project: Fixing the dia update bug') — should produce 'project_fixing_the_dia_update_bug.md', not 'project_project_fixing_the_dia_update_bug.md'

2. `generate_filename_from_file` with a file whose title does NOT start with the type word — should still work correctly (no regression)

3. `generate_filename` (instance method) with a title that would produce a slug starting with the prefix — should not double

4. Test with at least 3 document types: project (no title_prefix), note (no title_prefix), and explanation (has title_prefix 'Understanding')

5. Test that `generate_filename_from_existing` returns nil when the filename is already correct (idempotency check)

Create a new spec file spec/document_filename_spec.rb or add to existing spec/diataxis_spec.rb.
  - Files: `spec/document_filename_spec.rb`, `lib/diataxis/document.rb`
  - Verify: bundle exec rspec spec/document_filename_spec.rb && bundle exec rspec && bundle exec cucumber

## Files Likely Touched

- lib/diataxis/document.rb
- spec/document_filename_spec.rb
