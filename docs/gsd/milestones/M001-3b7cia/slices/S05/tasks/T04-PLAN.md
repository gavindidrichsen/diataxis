---
estimated_steps: 40
estimated_files: 4
skills_used: []
---

# T04: Create ADR-0015 documenting registry DSL and run final verification

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

## Inputs

- ``docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md` — ADR to mark as superseded`
- ``lib/diataxis/document_types.rb` — registry DSL (source of truth for the decision)`
- ``lib/diataxis/document.rb` — template method hooks`
- ``docs/how_to_add_a_new_document_template.md` — rewritten in T02, should be consistent with ADR-0015`

## Expected Output

- ``docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md` — new ADR documenting the registry DSL decision`
- ``docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md` — status updated to Superseded`

## Verification

test -f docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md && grep -q 'Accepted' docs/adr/0015-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md && grep -q 'Superseded' docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md && bundle exec rspec && bundle exec cucumber
