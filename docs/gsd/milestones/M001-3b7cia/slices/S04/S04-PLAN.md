# S04: Dead code removal, test gaps, and SOLID cleanup

**Goal:** Remove dead code, close test coverage gaps for untested document types (project, 5why, pr), and fix SOLID issues. After this slice, every public method is either called or removed, all 9 document types have creation and content tests, and the codebase is clean for final review.
**Demo:** After this: dead code removed, all document types have test coverage, no SOLID violations, all tests green

## Must-Haves

- `bundle exec rspec` passes with 0 failures including new tests for project, 5why, and pr document types\n- `bundle exec cucumber` passes with 0 failures\n- FileManager.update_filenames and related dead methods removed\n- Document#customize_readme_entry removed (unused hook)\n- file_manager.rb has explicit `require 'fileutils'`\n- No unused public methods remain in lib/diataxis/

## Proof Level

- This slice proves: This slice proves: integration — real runtime required, no UAT needed

## Integration Closure

Not provided.

## Verification

- Not provided.

## Tasks

- [x] **T01: Remove dead code from FileManager and Document** `est:15m`
  Remove unused methods from FileManager and Document base class.

1. In file_manager.rb: remove `update_filenames`, `process_document_type`, `get_document_directory`, `find_files_for_document_type`, `update_file_in_place`, `cache_files`, `cached_files` (lines 8-51). These methods are never called — ReadmeManager handles all file update logic directly via FileManager.update_filename.
2. In file_manager.rb: add `require 'fileutils'` at line 3 (currently relies on implicit load from document.rb).
3. In document.rb: remove `customize_readme_entry` (line 107-108) — defined as a protected no-op hook but never called or overridden anywhere. The actual README formatting is handled by the class method `format_readme_entry`.
4. Run tests to confirm nothing breaks.
  - Files: `lib/diataxis/file_manager.rb`, `lib/diataxis/document.rb`
  - Verify: bundle exec rspec && bundle exec cucumber

- [x] **T02: Add creation and content tests for project, 5why, and pr document types** `est:25m`
  The existing spec covers howto, tutorial, adr, explanation, handover, and note — but project, 5why (fivewhyanalysis), and pr have zero creation or content tests. Add test contexts for all three in spec/diataxis_spec.rb.

For each type, test:
1. File is created with correct filename prefix
2. Content includes the expected title and key template sections
3. README is updated with correct section and link

Reference the existing handover and note test contexts (lines 171-228) for the pattern. Use the registered command names: 'project', '5why', 'pr'.
  - Files: `spec/diataxis_spec.rb`
  - Verify: bundle exec rspec spec/diataxis_spec.rb && bundle exec rspec && bundle exec cucumber

- [x] **T03: Verify no remaining dead code and run full test suite** `est:10m`
  Final verification sweep:
1. Grep for any remaining unused public methods in lib/diataxis/ (check that every `def self.` method is called somewhere)
2. Run full rspec and cucumber suites
3. Confirm the cleanup is complete and nothing was missed
  - Files: `lib/diataxis/file_manager.rb`, `lib/diataxis/document.rb`, `spec/diataxis_spec.rb`
  - Verify: bundle exec rspec && bundle exec cucumber

## Files Likely Touched

- lib/diataxis/file_manager.rb
- lib/diataxis/document.rb
- spec/diataxis_spec.rb
