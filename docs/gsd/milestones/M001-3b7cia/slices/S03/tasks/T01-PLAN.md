---
estimated_steps: 5
estimated_files: 1
skills_used: []
---

# T01: Add prefix-stripping logic to generate_filename_from_file and generate_filename in document.rb

Fix the two methods that build filenames from titles. Both methods build a slug from the title and prepend type_config[:prefix], but neither checks whether the slug already starts with the prefix. The fix: after building the slug, strip a leading `prefix + separator` if present before prepending it again.

In `generate_filename_from_file` (class method, line 46): after the slug is built on line 46, add prefix-stripping before line 47.

In `generate_filename` (instance method, line 134): after the slug is built on line 134, add prefix-stripping before line 135.

The stripping logic: `slug = slug.sub(/^#{Regexp.escape(prefix)}#{Regexp.escape(sep)}/, '') if slug.start_with?("#{prefix}#{sep}")`

This ensures that a title like 'Project: Fixing foo' which slugifies to 'project_fixing_foo' stays as 'project_fixing_foo' after prefix prepend, not 'project_project_fixing_foo'.

## Inputs

- `lib/diataxis/document.rb — current Document class with the bug in both methods`

## Expected Output

- `lib/diataxis/document.rb — modified with prefix-stripping logic in both generate_filename_from_file and generate_filename`

## Verification

bundle exec rspec && bundle exec cucumber
