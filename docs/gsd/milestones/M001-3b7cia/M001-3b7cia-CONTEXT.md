# M001-3b7cia: Template Metadata and Registration Refactor

**Gathered:** 2026-04-28
**Status:** Ready for planning

## Project Description

Refactor the diataxis Ruby gem to eliminate duplicated template metadata, replace per-type shell class files with a pure Ruby registry DSL, and add template method hooks for custom document behavior. The gem is primarily a utility for AI tools — it generates diataxis document templates with embedded metadata instructions so AI tools produce consistently formatted content.

## Why This Milestone

The current codebase has significant duplication: 7 of 9 document type classes are empty shells, and identical metadata blocks are copy-pasted across templates. Adding a new document type requires touching 3+ files with boilerplate. This refactoring makes the gem maintainable and extensible — adding a new type becomes a register call and a template file.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Add a new simple document template by writing one `register` call and one `.md` template file — zero new Ruby class files
- Run `dia new <type>` for any type and get the same output as before the refactor
- See consistent code evidence style, link formatting, and structural patterns across all generated documents regardless of type

### Entry point / environment

- Entry point: `dia` CLI command (e.g., `dia new explanation "My Topic"`)
- Environment: local dev terminal
- Live dependencies involved: none

## Completion Class

- Contract complete means: all existing tests pass, registry DSL loads correctly, metadata injection resolves `{{common.metadata}}`
- Integration complete means: `dia new <type>` for every registered type produces behaviorally equivalent output
- Operational complete means: none — this is a CLI tool, no service lifecycle

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- `dia new <type>` for every registered type produces documents with correct metadata (common + specific)
- Adding a hypothetical new simple type requires only a register call and a template file
- Generated sample documents across all types show consistent formatting patterns when reviewed collaboratively

## Scope

### In Scope

- Extract universal formatting rules into `templates/common.metadata`
- `{{common.metadata}}` placeholder resolution in `TemplateLoader`
- Pure Ruby registry DSL in `lib/diataxis/document_types.rb` replacing shell class files
- Template method pattern in `Document` base class: `customize_title`, `customize_filename`, `customize_content`, `customize_readme_entry`
- ADR and HowTo retain custom classes with overrides only
- Eliminate empty shell class files (`explanation.rb`, `note.rb`, `tutorial.rb`, `five_why_analysis.rb`, `handover.rb`, `project.rb`, `pr.rb`)
- Test simplification while retaining functional coverage
- Collaborative output review and metadata iteration
- Update all help documentation to reflect new architecture (how-to guides, manual test doc, README)
- Review ADRs for successor ADR documenting the registry DSL and template method pattern

### Out of Scope / Non-Goals

- Auto-discovery of templates (zero-config, no registration needed) — deferred
- Section-based metadata override/merge logic — explicitly rejected in favor of template injection
- Changes to the `.diataxis` config file format
- Changes to README generation logic beyond what's needed for the refactor
- New document types (except as verification of the simplified process)

## Architectural Decisions

### Metadata injection via template placeholder

**Decision:** Use `{{common.metadata}}` placeholder in templates, resolved by `TemplateLoader` from `templates/common.metadata`. Templates that want common metadata include the placeholder; those that don't omit it. Template-specific metadata stays hardcoded in the template itself.

**Rationale:** Simpler than file-based composition or section-based override. Explicit inclusion beats magic merging. The narrow common metadata (~9 lines of universal formatting rules) is the only truly shared content — everything else is intentionally different per document type.

**Alternatives Considered:**
- Section-based override with `.metadata` companion files — rejected as unnecessary complexity
- Append-only merge of common + specific files — rejected because shared content is narrower than expected
- Parameterized common metadata with vocabulary placeholders — rejected as templates-within-templates complexity

### Pure Ruby registry DSL replacing YAML config

**Decision:** Single `lib/diataxis/document_types.rb` with `DocumentRegistry.configure` block. All types registered via `register :name, ...`. Custom types pass `handler: ClassName`.

**Rationale:** One registration path instead of two (YAML for simple, class files for custom). Pure Ruby means type-checked at load time, no YAML parsing dependency, syntax errors surface immediately. Simpler than the YAML approach user challenged.

**Alternatives Considered:**
- YAML config file (`document_types.yml`) — rejected because it creates two registration paths
- Keep individual class files — rejected because 7 of 9 are empty shells

### Template method pattern for custom behavior

**Decision:** `Document` base class has `customize_title`, `customize_filename`, `customize_content`, `customize_readme_entry` as default no-ops. ADR and HowTo override only what they need.

**Rationale:** Simplest pattern that works. No handler chain infrastructure for two customizations. Classic OO with sensible defaults. If custom types grow to 10+, can refactor to strategy/chain then.

**Alternatives Considered:**
- Strategy pattern with hook modules — close second, adds module lookup not needed yet
- Handler chain — too heavy for two custom types, YAGNI

### Narrow common metadata scope

**Decision:** `common.metadata` contains only the ~9 lines of universal formatting rules that are identical across all templates. Per-template specifics (Purpose, Linking Rules, Code Evidence, etc.) stay hardcoded in each template.

**Rationale:** Line-by-line diff revealed that only the first ~9 lines are truly shared. The bulk of metadata is contextual to the document type (concept vs change, reader vs reviewer). Extracting more would require parameterization complexity.

## Error Handling Strategy

Fail-fast at the earliest possible point:
- Missing `common.metadata` file: clear error at template render time with expected path
- Invalid registry config (missing required keys): fail at load time naming the type and missing key
- Handler class not found: fail at registration time, not at document creation time
- Template file missing for registered type: fail at render time with expected path
- Unresolved `{{common.metadata}}` placeholder: passes through unresolved (same as current unknown placeholder behavior)

No silent fallbacks, no retries. CLI tool error handling — surface the problem and exit.

## Risks and Unknowns

- Registry DSL replacing shell classes while preserving CLI routing through `CommandRouter` and `DocumentRegistry` — mitigated by S02 being highest risk slice
- ADR's custom logic (auto-numbering, special filenames, custom README formatting) is the most complex custom behavior to preserve

## Existing Codebase / Prior Art

- `lib/diataxis/template_loader.rb` — current placeholder substitution and YAML front matter injection
- `lib/diataxis/document_registry.rb` — current type registration and creation dispatch
- `lib/diataxis/document.rb` — base class, currently handles `register_type` and `create_document`
- `lib/diataxis/document/adr.rb` — custom auto-numbering, filename, README entry logic
- `lib/diataxis/document/howto.rb` — custom title normalization
- `lib/diataxis/cli/command_router.rb` — dynamic command routing using registry
- `templates/` — all template files with current metadata blocks

## Relevant Requirements

- R001-R012 — all active requirements are owned by slices in this milestone
- R013 — deferred auto-discovery, potential future milestone

## Technical Constraints

- Must maintain backward compatibility with existing `.diataxis` config files
- Must not break `bin/dia` entry point or CLI argument parsing
- Ruby gem structure must remain valid (gemspec, lib structure)

## Integration Points

- None — purely internal gem refactoring with no external service dependencies

## Testing Requirements

- Existing RSpec specs and Cucumber features must pass
- Add targeted specs for: metadata injection, registry DSL loading, template method dispatch
- Simplify test structure where possible without losing functional coverage
- Final verification: collaborative review of generated sample documents

## Acceptance Criteria

- **S01:** `TemplateLoader` resolves `{{common.metadata}}` from `templates/common.metadata`. Templates include/exclude it explicitly. Rendered output unchanged.
- **S02:** All types registered via DSL. Shell classes removed. `dia new adr` still auto-numbers. `dia new howto` still normalizes titles. A new type needs only register call + .md file.
- **S03:** All tests pass. Dead shell classes removed. Test suite simplified. No SOLID violations in document creation path.
- **S04:** Generated sample documents reviewed collaboratively. Consistent formatting across types. Metadata iterated until approved.
- **S05:** All help documentation updated to reflect new architecture. `how_to_add_a_new_document_template.md` rewritten for register call + .md file process. `how_to_manually_test_all_diataxis_features.md` test procedures updated. `README.md` usage section reflects current behavior. ADRs reviewed for successor ADR if warranted.

## Relevant Documentation Files

These files must be reviewed and updated in S05 to match the refactored architecture:

- `docs/how_to_add_a_new_document_template.md` — **complete rewrite needed**. Currently describes the old process: create a class file, implement DocumentInterface, update CLI handlers, update diataxis.rb. New process is: add register call + .md template file.
- `docs/how_to_manually_test_all_diataxis_features.md` — **update test procedures**. Manual test scenarios reference current behavior; verify they still work against refactored code and update any steps that changed.
- `README.md` — **update usage section**. Feature descriptions and usage examples should reflect current document types and any new capabilities.
- `docs/understanding_the_design_of_the_logging_system.md` — likely no changes needed (logging untouched), but review for stale cross-references.
- `docs/how_to_add_or_amend_log_statements.md` — likely no changes needed, review for stale references.
- `docs/adr/` — review whether the architectural change (registry DSL replacing class files, template method pattern) warrants a new ADR (0015). ADR-0008 and ADR-0012 are most related.

## Open Questions

- None — all design decisions resolved during discussion.
