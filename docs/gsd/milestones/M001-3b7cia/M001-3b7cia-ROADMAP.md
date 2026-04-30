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

- [x] **S01: S01** `risk:medium` `depends:[]`
  > After this: dia new explanation renders with metadata sourced from common.metadata file instead of hardcoded block in the template

- [x] **S02: S02** `risk:high` `depends:[]`
  > After this: Shell class files eliminated; dia new adr still auto-numbers; dia new howto still normalizes titles; adding a type requires only register call + .md file

- [x] **S04: S04** `risk:low` `depends:[]`
  > After this: After this: dead code removed, all document types have test coverage, no SOLID violations, all tests green

- [ ] **S05: S05** `risk:low` `depends:[]`
  > After this: After this: Generated sample documents reviewed and approved; consistent code evidence style, link formatting, and structural patterns across all types

- [x] **S03: S03** `risk:medium` `depends:[]`
  > After this: dia update . on a directory with files like project_fixing_foo.md no longer renames them to project_project_fixing_foo.md; regression tests cover all 9 document types

## Boundary Map

### S01 → S02\n\nProduces:\n- `templates/common.metadata` — universal formatting rules file (~9 lines)\n- `TemplateLoader#resolve_placeholder` — extended to handle `{{common.metadata}}` by reading and injecting the common metadata file content\n- Templates updated with `{{common.metadata}}` placeholder replacing hardcoded common blocks\n\nConsumes: nothing (first slice)\n\n### S02 → S03\n\nProduces:\n- `lib/diataxis/document_types.rb` — registry DSL with `DocumentRegistry.configure` block registering all types\n- `Document#customize_title(title)` — no-op hook, overridden by HowTo\n- `Document#customize_filename(title, dir)` — no-op hook, overridden by ADR\n- `Document#customize_content(content)` — no-op hook for future use\n- `Document#customize_readme_entry(title, path, filepath)` — no-op hook, overridden by ADR\n- `handler:` option in register calls pointing to custom classes\n\nConsumes from S01:\n- `TemplateLoader` metadata injection (templates already updated)\n\n### S03 → S04\n\nProduces:\n- Clean codebase with shell classes removed\n- Simplified test suite with full functional coverage\n- SOLID-compliant document creation path\n\nConsumes from S02:\n- Registry DSL (all types registered)\n- Template method hooks (custom behavior working)\n\n### S04 → S05\n\nProduces:\n- User-approved metadata content across all templates\n- Potentially refined common.metadata and per-template metadata based on review feedback\n- Finalized architecture that documentation should describe\n\nConsumes from S03:\n- Clean, tested codebase ready for output review\n\n### S05 (terminal)\n\nProduces:\n- Updated `docs/how_to_add_a_new_document_template.md` — rewritten for register call + .md file process\n- Updated `docs/how_to_manually_test_all_diataxis_features.md` — test procedures for new architecture\n- Updated `README.md` — usage section reflects current behavior\n- Optional successor ADR if architectural changes warrant it\n\nConsumes from S04:\n- Finalized, user-approved architecture and metadata system
