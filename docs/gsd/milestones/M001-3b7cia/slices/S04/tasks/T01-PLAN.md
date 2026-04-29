---
estimated_steps: 5
estimated_files: 2
skills_used: []
---

# T01: Remove dead code from FileManager and Document

Remove unused methods from FileManager and Document base class.

1. In file_manager.rb: remove `update_filenames`, `process_document_type`, `get_document_directory`, `find_files_for_document_type`, `update_file_in_place`, `cache_files`, `cached_files` (lines 8-51). These methods are never called — ReadmeManager handles all file update logic directly via FileManager.update_filename.
2. In file_manager.rb: add `require 'fileutils'` at line 3 (currently relies on implicit load from document.rb).
3. In document.rb: remove `customize_readme_entry` (line 107-108) — defined as a protected no-op hook but never called or overridden anywhere. The actual README formatting is handled by the class method `format_readme_entry`.
4. Run tests to confirm nothing breaks.

## Inputs

- `lib/diataxis/file_manager.rb — contains dead methods to remove`
- `lib/diataxis/document.rb — contains unused customize_readme_entry hook`

## Expected Output

- `lib/diataxis/file_manager.rb — dead methods removed, explicit fileutils require added`
- `lib/diataxis/document.rb — unused customize_readme_entry hook removed`

## Verification

bundle exec rspec && bundle exec cucumber
