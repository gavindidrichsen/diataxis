# Requirements

This file is the explicit capability and coverage contract for the project.

## Active

### R001 — Common metadata template injection — universal formatting rules in templates/common.metadata resolved via {{common.metadata}} placeholder
- Class: core-capability
- Status: active
- Description: Common metadata template injection — universal formatting rules in templates/common.metadata resolved via {{common.metadata}} placeholder
- Why it matters: Eliminates duplicated metadata blocks across templates, provides single source of truth for universal formatting rules
- Source: user
- Primary owning slice: M001-3b7cia/S01
- Validation: unmapped
- Notes: TemplateLoader resolves {{common.metadata}} from templates/common.metadata at render time

### R002 — Per-template specific metadata hardcoded in template — each template carries its own context-specific instructions inline
- Class: core-capability
- Status: active
- Description: Per-template specific metadata hardcoded in template — each template carries its own context-specific instructions inline
- Why it matters: Document types have intentionally different metadata (concept vs change, reader vs reviewer) that should not be forced into a common mold
- Source: user
- Primary owning slice: M001-3b7cia/S01
- Validation: unmapped

### R003 — Pure Ruby registry DSL replaces shell class files — single document_types.rb with DocumentRegistry.configure block
- Class: core-capability
- Status: active
- Description: Pure Ruby registry DSL replaces shell class files — single document_types.rb with DocumentRegistry.configure block
- Why it matters: One registration path instead of two, eliminates 7 empty shell classes, pure Ruby means type-checked at load time
- Source: user
- Primary owning slice: M001-3b7cia/S02
- Validation: unmapped

### R004 — Template method hooks for custom document behavior — customize_title, customize_filename, customize_content, customize_readme_entry as default no-ops
- Class: core-capability
- Status: active
- Description: Template method hooks for custom document behavior — customize_title, customize_filename, customize_content, customize_readme_entry as default no-ops
- Why it matters: ADR and HowTo need custom behavior without requiring every type to have a class file; template method is simplest pattern for two custom types
- Source: user
- Primary owning slice: M001-3b7cia/S02
- Validation: unmapped

### R005 — Adding a new simple template requires only a register call + .md file — zero new Ruby class files
- Class: primary-user-loop
- Status: active
- Description: Adding a new simple template requires only a register call + .md file — zero new Ruby class files
- Why it matters: Core motivation for the refactor; current process requires 3+ files with boilerplate
- Source: user
- Primary owning slice: M001-3b7cia/S02
- Validation: unmapped

### R006 — Behavioral equivalence — all existing dia new commands produce same output after refactoring
- Class: quality-attribute
- Status: active
- Description: Behavioral equivalence — all existing dia new commands produce same output after refactoring
- Why it matters: Refactoring must not change user-visible behavior; existing documents and workflows must continue working identically
- Source: user
- Primary owning slice: M001-3b7cia/S03
- Validation: unmapped

### R007 — Consistent rendered output across all document types — code evidence style, link formatting, structural patterns uniform
- Class: quality-attribute
- Status: active
- Description: Consistent rendered output across all document types — code evidence style, link formatting, structural patterns uniform
- Why it matters: AI tools reading generated documents must get consistent instructions regardless of document type
- Source: user
- Primary owning slice: M001-3b7cia/S04
- Validation: unmapped

### R008 — Metadata serves as clear AI instruction set for document generation — templates instruct AI tools to produce consistently formatted content
- Class: core-capability
- Status: active
- Description: Metadata serves as clear AI instruction set for document generation — templates instruct AI tools to produce consistently formatted content
- Why it matters: Primary use case of the gem: AI tools use dia CLI to generate templates, then follow the embedded metadata to populate content correctly
- Source: user
- Primary owning slice: M001-3b7cia/S04
- Validation: unmapped

### R009 — Fail-fast error handling for missing templates, bad config, missing handler classes
- Class: failure-visibility
- Status: active
- Description: Fail-fast error handling for missing templates, bad config, missing handler classes
- Why it matters: CLI tool must surface problems immediately with clear messages, not silently produce broken output
- Source: inferred
- Primary owning slice: M001-3b7cia/S02
- Validation: unmapped

### R010 — Existing test suite passes after refactoring — RSpec specs and Cucumber features all green
- Class: quality-attribute
- Status: active
- Description: Existing test suite passes after refactoring — RSpec specs and Cucumber features all green
- Why it matters: Behavioral equivalence must be provable through existing test coverage
- Source: inferred
- Primary owning slice: M001-3b7cia/S03
- Validation: unmapped

### R011 — Test simplification without losing functional coverage — streamline test structure while retaining verification
- Class: quality-attribute
- Status: active
- Description: Test simplification without losing functional coverage — streamline test structure while retaining verification
- Why it matters: Current test suite may have redundancy that mirrors the duplicated code being refactored
- Source: user
- Primary owning slice: M001-3b7cia/S03
- Validation: unmapped

### R012 — Collaborative output review — generate sample docs across all types, review with user, iterate metadata until approved
- Class: launchability
- Status: active
- Description: Collaborative output review — generate sample docs across all types, review with user, iterate metadata until approved
- Why it matters: Metadata quality is only proven when the user reviews actual rendered output and approves the formatting
- Source: user
- Primary owning slice: M001-3b7cia/S04
- Validation: unmapped

### R015 — All help documentation (how_to_add_a_new_document_template.md, how_to_manually_test_all_diataxis_features.md, README.md) updated to reflect the new registration and metadata architecture
- Class: continuity
- Status: active
- Description: All help documentation (how_to_add_a_new_document_template.md, how_to_manually_test_all_diataxis_features.md, README.md) updated to reflect the new registration and metadata architecture
- Why it matters: A new contributor following stale docs would try the old process (create a class file, update CLI handlers) which no longer works. Documentation must match the actual codebase to be useful.
- Source: user
- Primary owning slice: M001-3b7cia/S05
- Supporting slices: none
- Validation: unmapped
- Notes: Covers: how_to_add_a_new_document_template.md (complete rewrite), how_to_manually_test_all_diataxis_features.md (update test procedures), README.md (update usage section). Review ADRs for potential successor ADR documenting the new approach.

## Deferred

### R013 — Auto-discovery of templates — zero-config registration, just drop a template file
- Class: core-capability
- Status: deferred
- Description: Auto-discovery of templates — zero-config registration, just drop a template file
- Why it matters: Further simplification beyond the registry DSL approach; not needed yet
- Source: user
- Primary owning slice: none
- Validation: unmapped
- Notes: Deferred — current DSL approach is sufficient; auto-discovery adds complexity not justified by current type count

## Out of Scope

### R014 — Section-based metadata override/merge logic — rejected in favor of simple template injection
- Class: anti-feature
- Status: out-of-scope
- Description: Section-based metadata override/merge logic — rejected in favor of simple template injection
- Why it matters: Prevents scope confusion; explicit inclusion via placeholder is simpler than magic merge behavior
- Source: user
- Primary owning slice: none
- Validation: n/a
- Notes: Explicitly rejected during discussion — template injection chosen over section-based override

## Traceability

| ID | Class | Status | Primary owner | Supporting | Proof |
|---|---|---|---|---|---|
| R001 | core-capability | active | M001-3b7cia/S01 | none | unmapped |
| R002 | core-capability | active | M001-3b7cia/S01 | none | unmapped |
| R003 | core-capability | active | M001-3b7cia/S02 | none | unmapped |
| R004 | core-capability | active | M001-3b7cia/S02 | none | unmapped |
| R005 | primary-user-loop | active | M001-3b7cia/S02 | none | unmapped |
| R006 | quality-attribute | active | M001-3b7cia/S03 | none | unmapped |
| R007 | quality-attribute | active | M001-3b7cia/S04 | none | unmapped |
| R008 | core-capability | active | M001-3b7cia/S04 | none | unmapped |
| R009 | failure-visibility | active | M001-3b7cia/S02 | none | unmapped |
| R010 | quality-attribute | active | M001-3b7cia/S03 | none | unmapped |
| R011 | quality-attribute | active | M001-3b7cia/S03 | none | unmapped |
| R012 | launchability | active | M001-3b7cia/S04 | none | unmapped |
| R013 | core-capability | deferred | none | none | unmapped |
| R014 | anti-feature | out-of-scope | none | none | n/a |
| R015 | continuity | active | M001-3b7cia/S05 | none | unmapped |

## Coverage Summary

- Active requirements: 13
- Mapped to slices: 13
- Validated: 0
- Unmapped active requirements: 0
