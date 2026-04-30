# S05: Output consistency polish and collaborative review

**Goal:** Generated sample documents reviewed and approved; consistent code evidence style, link formatting, and structural patterns across all types; all help documentation updated to reflect the new registration and metadata architecture.
**Demo:** After this: Generated sample documents reviewed and approved; consistent code evidence style, link formatting, and structural patterns across all types

## Must-Haves

- `note.md` and `fivewhyanalysis.md` templates include `{{common.metadata}}` in an HTML comment wrapper consistent with the other 6 templates
- `how_to_add_a_new_document_template.md` completely rewritten describing the new 3-step process (register call + template file + optional config)
- `how_to_manually_test_all_diataxis_features.md` covers all 9 document types (not just 4)
- `README.md` Usage section shows examples for all 9 document types
- ADR-0015 documents the registry DSL + template method pattern, superseding ADR-0008
- `bundle exec rspec` — 46 examples, 0 failures
- `bundle exec cucumber` — 6 scenarios, all passed
- R015 requirement satisfied: all help documentation reflects the new architecture

## Proof Level

- This slice proves: - This slice proves: final-assembly (documentation matches codebase)
- Real runtime required: yes (test suites must pass, `dia new <type>` must work)
- Human/UAT required: yes (user reviews template consistency decisions and doc quality)

## Integration Closure

- Upstream surfaces consumed: `lib/diataxis/document_types.rb` (registry DSL), `lib/diataxis/cli/usage_display.rb` (auto-generated help), `lib/diataxis/cli/command_router.rb` (auto-routing), `templates/common.metadata`, all 9 template files
- New wiring introduced in this slice: none (documentation only, plus minor template metadata additions)
- What remains before the milestone is truly usable end-to-end: nothing — this is the terminal slice

## Verification

- Not provided.

## Tasks

- [x] **T01: Add common.metadata to note and fivewhyanalysis templates and normalize reference sections** `est:30m`
  ## Description

Two of 9 templates (`note.md`, `fivewhyanalysis.md`) lack the `{{common.metadata}}` HTML comment wrapper that the other 6 non-ADR templates use. This task adds the wrapper to these two templates for consistency, and normalizes the reference section heading across templates. `project.md` is left as-is because its GTD-specific HTML comment serves a different purpose (philosophy guide, not style rules). `adr.md` is left as-is because it follows the community ADR standard format.

**Auto-mode assumption:** Adding `{{common.metadata}}` to `note.md` and `fivewhyanalysis.md` is non-controversial since 6 of 7 non-ADR templates already have it. The project template's GTD metadata serves a distinct purpose and should not be conflated with common.metadata (per D004). ADR format is a community standard. These decisions will be documented for user review.

## Steps

1. Read `templates/references/note.md` and add an HTML comment wrapper at the top with `# Common Guidelines` / `{{common.metadata}}` / `# Template-Specific Guidelines` matching the pattern used in `explanation.md`, `handover.md`, `pr.md`, etc.
2. Read `templates/references/fivewhyanalysis.md` and add the same HTML comment wrapper at the top.
3. Verify the `TemplateLoader` resolves `{{common.metadata}}` correctly by running `bundle exec rspec` — the existing tests exercise template loading for all types.
4. Run `bundle exec cucumber` to confirm no behavioral regressions.
5. Verify the generated output by inspecting what `dia new note` and `dia new 5why` produce in a temp directory — confirm the common.metadata content appears in the HTML comment.

## Must-Haves

- [ ] `templates/references/note.md` has `<!--\n# Common Guidelines\n{{common.metadata}}\n...-->` wrapper at top
- [ ] `templates/references/fivewhyanalysis.md` has the same wrapper at top
- [ ] `templates/references/project.md` is NOT modified (GTD metadata is intentionally distinct)
- [ ] `templates/references/adr.md` is NOT modified (community standard format)
- [ ] All 46 rspec examples pass
- [ ] All 6 cucumber scenarios pass

## Verification

- `bundle exec rspec` — 46 examples, 0 failures
- `bundle exec cucumber` — 6 scenarios, all passed
- `grep -c 'common.metadata' templates/references/note.md` returns 1
- `grep -c 'common.metadata' templates/references/fivewhyanalysis.md` returns 1

## Inputs

- `templates/references/note.md` — current template without common.metadata
- `templates/references/fivewhyanalysis.md` — current template without common.metadata
- `templates/common.metadata` — the shared style guidelines content
- `templates/explanation/explanation.md` — reference for the HTML comment wrapper pattern
- `templates/references/handover.md` — reference for the HTML comment wrapper pattern

## Expected Output

- `templates/references/note.md` — updated with HTML comment wrapper containing {{common.metadata}}
- `templates/references/fivewhyanalysis.md` — updated with HTML comment wrapper containing {{common.metadata}}
  - Files: `templates/references/note.md`, `templates/references/fivewhyanalysis.md`, `templates/common.metadata`, `templates/explanation/explanation.md`
  - Verify: bundle exec rspec && bundle exec cucumber && grep -q 'common.metadata' templates/references/note.md && grep -q 'common.metadata' templates/references/fivewhyanalysis.md

- [ ] **T02: Rewrite how_to_add_a_new_document_template.md for registry DSL architecture** `est:45m`
  ## Description

The current `docs/how_to_add_a_new_document_template.md` is completely stale — it describes the old 8-step process (create a class file in `lib/diataxis/document/`, implement DocumentInterface, update command_router, update command_handlers, update diataxis.rb, update usage_display.rb). None of these steps apply anymore. The new process is:

1. Add a `register` call in `lib/diataxis/document_types.rb`
2. Create a `.md` template file in `templates/<category>/`
3. Optionally add a config key to `Config::DEFAULT_CONFIG` if a custom directory is needed
4. Run tests

The `UsageDisplay` auto-generates help from `DocumentRegistry.command_names`. The `CommandRouter` auto-routes via `DocumentRegistry.lookup`. `CommandHandlers.handle_document` is generic for all registered types. Only ADR and HowTo retain custom handler classes (for auto-numbering and title normalization respectively).

This is the primary deliverable for requirement R015.

## Steps

1. Read `lib/diataxis/document_types.rb` to confirm the current registry DSL shape and all 9 registered types.
2. Read `lib/diataxis/cli/usage_display.rb` to confirm help text is auto-generated from `DocumentRegistry.command_names`.
3. Read `lib/diataxis/cli/command_router.rb` to confirm auto-routing via `DocumentRegistry.lookup`.
4. Read `lib/diataxis/cli/command_handlers.rb` to confirm `handle_document` is generic.
5. Completely rewrite `docs/how_to_add_a_new_document_template.md` with:
   - Updated prerequisites (no need to understand class inheritance)
   - Key files: only `document_types.rb` and `templates/<category>/`
   - New 4-step process with a worked example (adding a hypothetical "checklist" type using the new simple register call — NOT the old class-file approach)
   - Explanation of what's automatic: help text generation, command routing, document creation
   - When you need a custom handler class (only for special behavior like ADR auto-numbering)
   - Testing section updated for the current test patterns
6. Verify the document is well-formed markdown with no stale references to old files/classes.

## Must-Haves

- [ ] No references to `lib/diataxis/document/<type>.rb` class files (old pattern)
- [ ] No references to manually updating `command_router.rb`, `command_handlers.rb`, `usage_display.rb`, or `diataxis.rb`
- [ ] Describes the `DocumentRegistry.configure` / `register` DSL with a concrete example
- [ ] Explains auto-generated help, auto-routing, and generic `handle_document`
- [ ] Mentions when a custom handler class is needed (ADR, HowTo examples)
- [ ] Includes a testing section with current rspec patterns

## Verification

- `test -f docs/how_to_add_a_new_document_template.md` — file exists
- `grep -c '^## ' docs/how_to_add_a_new_document_template.md` returns >= 4 (has 4+ sections)
- `! grep -q 'document/checklist.rb' docs/how_to_add_a_new_document_template.md` — no old class file references
- `! grep -q 'command_router' docs/how_to_add_a_new_document_template.md` — no stale CLI references
- `grep -q 'DocumentRegistry' docs/how_to_add_a_new_document_template.md` — mentions the registry
- `grep -q 'document_types.rb' docs/how_to_add_a_new_document_template.md` — references the correct file

## Inputs

- `docs/how_to_add_a_new_document_template.md` — the stale document to rewrite
- `lib/diataxis/document_types.rb` — the registry DSL configuration (source of truth)
- `lib/diataxis/cli/usage_display.rb` — auto-generated help text
- `lib/diataxis/cli/command_router.rb` — auto-routing logic
- `lib/diataxis/cli/command_handlers.rb` — generic handle_document method

## Expected Output

- `docs/how_to_add_a_new_document_template.md` — completely rewritten for the new architecture
  - Files: `docs/how_to_add_a_new_document_template.md`, `lib/diataxis/document_types.rb`, `lib/diataxis/cli/usage_display.rb`, `lib/diataxis/cli/command_router.rb`, `lib/diataxis/cli/command_handlers.rb`
  - Verify: test -f docs/how_to_add_a_new_document_template.md && grep -q 'DocumentRegistry' docs/how_to_add_a_new_document_template.md && grep -q 'document_types.rb' docs/how_to_add_a_new_document_template.md && ! grep -q 'command_router' docs/how_to_add_a_new_document_template.md

- [ ] **T03: Update manual test doc and README to cover all 9 document types** `est:45m`
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
  - Files: `docs/how_to_manually_test_all_diataxis_features.md`, `README.md`, `lib/diataxis/document_types.rb`
  - Verify: grep -q 'dia note new' README.md && grep -q 'dia pr new' README.md && grep -q 'dia 5why new' README.md && grep -q 'dia handover new' README.md && grep -q 'dia project new' README.md

- [ ] **T04: Create ADR-0015 documenting registry DSL and run final verification** `est:30m`
  ## Description

The architecture has fundamentally changed since ADR-0008 (class files) and ADR-0012 (external templates). Neither documents the registry DSL that replaced per-type class files, nor the template method pattern for custom behavior. ADR-0015 should document:

1. The `DocumentRegistry.configure` DSL in `document_types.rb` supersedes per-type class files
2. Template method hooks in `Document` base class (`customize_title`, `customize_filename`, `customize_content`) replace per-type behavior
3. Only ADR and HowTo retain custom handler classes — all other types use generic registration
4. Adding a new simple type requires only a `register` call and a `.md` template file

After creating the ADR, update ADR-0008's status from "Proposed" to "Superseded by ADR-0015". Then run the full test suite as final slice verification.

The ADR should be created using `dia adr new` so it gets proper auto-numbering and README integration.

## Steps

1. Create the ADR using `bundle exec dia adr new "Replace per-type class files with registry DSL and template method hooks"` in the project directory.
2. Edit the generated ADR file (`docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md`) to fill in:
   - Status: Accepted
   - Context: The old architecture required 8 steps and 5+ file changes to add a new document type. ADR-0008 established per-type class files. ADR-0012 moved to external templates. But class files remained as boilerplate.
   - Decision: Replace per-type class files with a pure Ruby registry DSL (`DocumentRegistry.configure` block). Custom behavior uses template method hooks in the `Document` base class. Only types with genuinely unique behavior (ADR auto-numbering, HowTo title normalization) retain custom handler classes.
   - Consequences: Adding a new type is now 2 files (register call + template). CLI routing, help text, and document creation are automatic. Trade-off: custom behavior requires understanding the template method pattern.
   - References: Link to ADR-0008, ADR-0012, `lib/diataxis/document_types.rb`
3. Read `docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md` and update its Status to "Superseded by [ADR-0015](0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md)".
4. Run `bundle exec dia update .` to ensure the README picks up the new ADR.
5. Run `bundle exec rspec` — expect 46 examples, 0 failures.
6. Run `bundle exec cucumber` — expect 6 scenarios, all passed.

## Must-Haves

- [ ] ADR-0015 exists in `docs/adr/` with proper auto-numbered filename
- [ ] ADR-0015 has Status: Accepted, filled Context/Decision/Consequences sections
- [ ] ADR-0008 status updated to "Superseded by ADR-0015"
- [ ] `dia update .` picks up ADR-0015 in README
- [ ] Full test suite passes (rspec + cucumber)

## Verification

- `test -f docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md` — ADR exists
- `grep -q 'Accepted' docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md` — status is Accepted
- `grep -q 'Superseded' docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md` — old ADR updated
- `bundle exec rspec` — 46 examples, 0 failures
- `bundle exec cucumber` — 6 scenarios, all passed

## Inputs

- `docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md` — ADR to mark as superseded
- `lib/diataxis/document_types.rb` — registry DSL (source of truth for the decision)
- `lib/diataxis/document.rb` — template method hooks
- `docs/how_to_add_a_new_document_template.md` — rewritten in T02, should be consistent with ADR-0015

## Expected Output

- `docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md` — new ADR documenting the registry DSL decision
- `docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md` — status updated to Superseded
  - Files: `docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md`, `docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md`, `lib/diataxis/document_types.rb`, `lib/diataxis/document.rb`
  - Verify: test -f docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md && grep -q 'Accepted' docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md && grep -q 'Superseded' docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md && bundle exec rspec && bundle exec cucumber

## Files Likely Touched

- templates/references/note.md
- templates/references/fivewhyanalysis.md
- templates/common.metadata
- templates/explanation/explanation.md
- docs/how_to_add_a_new_document_template.md
- lib/diataxis/document_types.rb
- lib/diataxis/cli/usage_display.rb
- lib/diataxis/cli/command_router.rb
- lib/diataxis/cli/command_handlers.rb
- docs/how_to_manually_test_all_diataxis_features.md
- README.md
- docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md
- docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md
- lib/diataxis/document.rb
