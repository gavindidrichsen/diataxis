---
estimated_steps: 43
estimated_files: 5
skills_used: []
---

# T02: Rewrite how_to_add_a_new_document_template.md for registry DSL architecture

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

## Inputs

- ``docs/how_to_add_a_new_document_template.md` — the stale document to rewrite`
- ``lib/diataxis/document_types.rb` — the registry DSL configuration (source of truth)`
- ``lib/diataxis/cli/usage_display.rb` — auto-generated help text`
- ``lib/diataxis/cli/command_router.rb` — auto-routing logic`
- ``lib/diataxis/cli/command_handlers.rb` — generic handle_document method`

## Expected Output

- ``docs/how_to_add_a_new_document_template.md` — completely rewritten for the new architecture`

## Verification

test -f docs/how_to_add_a_new_document_template.md && grep -q 'DocumentRegistry' docs/how_to_add_a_new_document_template.md && grep -q 'document_types.rb' docs/how_to_add_a_new_document_template.md && ! grep -q 'command_router' docs/how_to_add_a_new_document_template.md
