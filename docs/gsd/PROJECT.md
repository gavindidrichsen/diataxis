# What This Is

Diataxis is a Ruby gem providing a CLI tool (`dia`) for generating documentation files following the Diataxis framework. It supports multiple document types (explanations, how-tos, tutorials, references) with templates that include AI-readable metadata (Style Guidelines) to instruct AI tools on how to populate the generated documents consistently.

## Core Value

Adding a new document template type should be trivially simple — a registration entry and a template file — while every generated document carries clear, consistent AI instructions for content generation.

## Current State

The gem is functional with 9 document types: explanation, pr, howto, tutorial, adr, fivewhyanalysis, handover, note, project. The CLI routes commands dynamically through `DocumentRegistry` and `CommandRouter`. Each document type has its own Ruby class file (most are empty shells calling `register_type`), and templates carry duplicated metadata blocks. ADR has custom auto-numbering logic; HowTo has title normalization.

## Architecture / Key Patterns

- **Language:** Ruby
- **CLI framework:** Custom argument parsing in `Diataxis::CLI`
- **Document registration:** `DocumentRegistry` with `register_type` / `create_document` pattern
- **Template rendering:** `TemplateLoader` with `{{placeholder}}` substitution and YAML front matter injection
- **Configuration:** `.diataxis` YAML file for directory paths
- **Key modules:** `lib/diataxis/cli/` (command routing), `lib/diataxis/document/` (type classes), `templates/` (markdown templates)

## Capability Contract

See `.gsd/REQUIREMENTS.md` for the explicit capability contract, requirement status, and coverage mapping.

## Milestone Sequence

- [ ] M001-3b7cia: Template metadata and registration refactor — Simplify template management with common metadata injection, pure Ruby registry DSL, and template method hooks for custom behavior
