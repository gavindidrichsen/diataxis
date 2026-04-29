# M001-3b7cia: Template Metadata and Registration Refactor

**Vision:** Refactor the diataxis Ruby gem to eliminate duplicated template metadata with a layered common/specific system, replace per-type shell class files with a pure Ruby registry DSL, and add template method hooks for custom behavior. The result: adding a new template type requires only a register call and a .md file, and every generated document carries clear, consistent AI instructions.

## Success Criteria

- Every dia new <type> command produces behaviorally equivalent output to pre-refactor
- Adding a new simple template requires only a register call and a .md template file — zero new Ruby class files
- No duplicated metadata blocks across templates — common.metadata provides universal formatting rules
- ADR auto-numbering and HowTo title normalization work through template method overrides
- Rendered documents show consistent code evidence style, link formatting, and structural patterns across all types
- User has reviewed generated sample documents and approved the output quality
- All existing help documentation (how-tos, README) reflects the new simplified process

## Slices

- [x] **S01: Common metadata template injection** `risk:medium` `depends:[]`
  > After this: dia new explanation renders with metadata sourced from common.metadata file instead of hardcoded block in the template

- [x] **S02: Registry DSL and template method pattern** `risk:high` `depends:[S01]`
  > After this: Shell class files eliminated; dia new adr still auto-numbers; dia new howto still normalizes titles; adding a type requires only register call + .md file

- [ ] **S03: Fix dia update filename-doubling bug when slug starts with prefix** `risk:medium` `depends:[S02]`
  > After this: dia update . on a directory with files like project_fixing_foo.md no longer renames them to project_project_fixing_foo.md; regression tests cover all 9 document types

- [ ] **S04: Cleanup, tests, and SOLID audit** `risk:low` `depends:[S03]`
  > After this: All existing tests pass, test suite simplified, dead code removed, no SOLID violations

- [ ] **S05: Output consistency polish and collaborative review** `risk:low` `depends:[S04]`
  > After this: Generated sample documents reviewed and approved; consistent code evidence style, link formatting, and structural patterns across all types

## Boundary Map

### S01 → S02

Produces:
- `templates/common.metadata` — universal formatting rules file (~9 lines)
- `TemplateLoader#resolve_placeholder` — extended to handle `{{common.metadata}}` by reading and injecting the common metadata file content
- Templates updated with `{{common.metadata}}` placeholder replacing hardcoded common blocks

Consumes: nothing (first slice)

### S02 → S03

Produces:
- `lib/diataxis/document_types.rb` — registry DSL with `DocumentRegistry.configure` block registering all types
- `Document#customize_title(title)` — no-op hook, overridden by HowTo
- `Document#customize_filename(title, dir)` — no-op hook, overridden by ADR
- `Document#customize_content(content)` — no-op hook for future use
- `Document#customize_readme_entry(title, path, filepath)` — no-op hook, overridden by ADR
- `handler:` option in register calls pointing to custom classes

Consumes from S01:
- `TemplateLoader` metadata injection (templates already updated)

### S03 → S04

Produces:
- Prefix-stripping logic in `generate_filename` that prevents filename-doubling
- Regression tests covering all 9 document types

Consumes from S02:
- Registry DSL (all types registered)
- Template method hooks (custom behavior working)

### S04 → S05

Produces:
- User-approved metadata content across all templates
- Potentially refined common.metadata and per-template metadata based on review feedback
- Finalized architecture that documentation should describe

Consumes from S03:
- Clean, tested codebase ready for output review

### S05 (terminal)

Produces:
- Updated `docs/how_to_add_a_new_document_template.md` — rewritten for register call + .md file process
- Updated `docs/how_to_manually_test_all_diataxis_features.md` — test procedures for new architecture
- Updated `README.md` — usage section reflects current behavior
- Optional successor ADR if architectural changes warrant it

Consumes from S04:
- Finalized, user-approved architecture and metadata system
