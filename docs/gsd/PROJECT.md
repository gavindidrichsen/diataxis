# What This Is

Diataxis is a Ruby gem providing a CLI tool (`dia`) for generating documentation files following the Diataxis framework. It supports multiple document types (explanations, how-tos, tutorials, references) with templates that include AI-readable metadata (Style Guidelines) to instruct AI tools on how to populate the generated documents consistently.

## Core Value

Adding a new document template type should be trivially simple — a registration entry and a template file — while every generated document carries clear, consistent AI instructions for content generation.

## Current State

The gem is functional with 9 document types: explanation, pr, howto, tutorial, adr, fivewhyanalysis, handover, note, project. The CLI routes commands dynamically through `DocumentRegistry` and `CommandRouter`. Each document type has its own Ruby class file (most are empty shells calling `register_type`), and templates use a layered metadata system. ADR has custom auto-numbering logic; HowTo has title normalization.

**S01 complete:** Common metadata injection is live. Universal formatting rules are in `templates/common.metadata`, resolved via `{{common.metadata}}` placeholder in TemplateLoader before title/date substitutions. All 5 metadata-bearing templates (explanation, tutorial, howto, pr, handover) use the section-header structure (`# Common Guidelines` / `# Template-Specific Guidelines`). A pre-existing bug in `Document#pattern` (hardcoded 'default' config key ignoring type-specific directories) was fixed — all 37 RSpec and 6 Cucumber tests pass.

## Architecture / Key Patterns

- **Language:** Ruby
- **CLI framework:** Custom argument parsing in `Diataxis::CLI`
- **Document registration:** `DocumentRegistry` with `register_type` / `create_document` pattern
- **Template rendering:** `TemplateLoader` with `{{placeholder}}` substitution — resolves `{{common.metadata}}` → `{{title}}` → `{{date}}` in order; YAML front matter injection
- **Layered metadata:** `templates/common.metadata` (raw content, no HTML wrappers) injected into templates that own the `<!-- # Common Guidelines ... # Template-Specific Guidelines ... -->` wrapper structure
- **Configuration:** `.diataxis` JSON file for directory paths; `Document#pattern` uses type-specific `config_key` for directory lookups
- **Key modules:** `lib/diataxis/cli/` (command routing), `lib/diataxis/document/` (type classes), `templates/` (markdown templates)

## Capability Contract

See `.gsd/REQUIREMENTS.md` for the explicit capability contract, requirement status, and coverage mapping.

## Milestone Sequence

- [ ] M001-3b7cia: Template metadata and registration refactor — Simplify template management with common metadata injection, pure Ruby registry DSL, and template method hooks for custom behavior
  - [x] S01: Common metadata template injection (complete)
  - [ ] S02: Registry DSL and template method pattern
  - [ ] S03: Cleanup, tests, and SOLID audit
  - [ ] S04: Output consistency polish and collaborative review
  - [ ] S05: Documentation update
