# S04: Dead code removal, test gaps, and SOLID cleanup — UAT

**Milestone:** M001-3b7cia
**Written:** 2026-04-29T23:58:10.384Z

# S04: Dead code removal, test gaps, and SOLID cleanup — UAT

**Milestone:** M001-3b7cia
**Written:** 2026-04-30

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: This slice is purely about code cleanup and test coverage — no user-facing behavior changes, no runtime surfaces. Verification is fully captured by test suite results and dead code grep output.

## Preconditions

- Ruby environment with bundler installed
- `bundle install` has been run
- Working directory is the diataxis gem root

## Smoke Test

Run `bundle exec rspec && bundle exec cucumber` — expect 46 rspec examples (0 failures) and 6 cucumber scenarios (all passed).

## Test Cases

### 1. Dead code removal — FileManager methods gone

1. Open `lib/diataxis/file_manager.rb`
2. Search for `update_filenames`, `process_document_type`, `get_document_directory`, `find_files_for_document_type`, `update_file_in_place`, `cache_files`, `cached_files`
3. **Expected:** None of these methods exist in the file

### 2. Dead code removal — customize_readme_entry hook gone

1. Run `grep -r 'customize_readme_entry' lib/`
2. **Expected:** No matches found

### 3. Explicit fileutils require

1. Open `lib/diataxis/file_manager.rb`
2. Check the top of the file for require statements
3. **Expected:** `require 'fileutils'` is present

### 4. Project document type has creation test

1. Run `bundle exec rspec spec/diataxis_spec.rb -e "creating project"`
2. **Expected:** 3 examples, 0 failures — tests file creation with prefix, template structure (Context, Project Purpose, Desired Outcome sections), and README update with Projects section

### 5. 5why document type has creation test

1. Run `bundle exec rspec spec/diataxis_spec.rb -e "creating 5why"`
2. **Expected:** 3 examples, 0 failures — tests file creation with prefix, template structure (Problem Statement, Analysis, References sections), and README update with Five Why Analyses section

### 6. PR document type has creation test

1. Run `bundle exec rspec spec/diataxis_spec.rb -e "creating pr"`
2. **Expected:** 3 examples, 0 failures — tests file creation with prefix, template structure (Purpose, Background, Changes sections), and README update with Pull Requests section

### 7. Full test suite green

1. Run `bundle exec rspec`
2. Run `bundle exec cucumber`
3. **Expected:** 46 rspec examples (0 failures), 6 cucumber scenarios (all passed)

## Edge Cases

### No remaining dead public methods

1. Run `grep -n 'def self\.' lib/diataxis/**/*.rb` and verify each method has a caller outside its own definition
2. **Expected:** All listed methods are called somewhere. Only known residual: `DocumentRegistry.each` (minor, non-blocking)

## Failure Signals

- Any rspec example failing (should be 46/46)
- Any cucumber scenario failing (should be 6/6)
- Dead methods still present in FileManager or Document
- Missing `require 'fileutils'` in file_manager.rb

## Not Proven By This UAT

- Output quality of generated documents (deferred to S05)
- Runtime behavior changes (this slice made no behavioral changes)
- The project double-prefix filename issue (pre-existing, not introduced here)

## Notes for Tester

- The project document type has a known double-prefix rename quirk (project_test_project.md → project_project_test_project.md) — this is pre-existing behavior from the template title format, not introduced by this slice. The test uses glob-based assertion to work around it.
- `DocumentRegistry.each` was flagged as unused but intentionally left — it's a trivial one-liner that could serve as a public API convenience. Can be removed later if desired.
