# Decisions Register

<!-- Append-only. Never edit or remove existing rows.
     To reverse a decision, add a new row that supersedes it.
     Read this file at the start of any planning or research phase. -->

| # | When | Scope | Decision | Choice | Rationale | Revisable? | Made By |
|---|------|-------|----------|--------|-----------|------------|---------|
| D001 | M001-3b7cia | arch | Metadata injection mechanism | {{common.metadata}} placeholder in templates resolved by TemplateLoader from templates/common.metadata | Simpler than file-based composition or section-based override. Explicit inclusion beats magic merging. Narrow common metadata (~9 lines) is the only truly shared content. | No | collaborative |
| D002 | M001-3b7cia | arch | Template type registration mechanism | Pure Ruby registry DSL in lib/diataxis/document_types.rb with DocumentRegistry.configure block | One registration path instead of two (YAML for simple + class files for custom). Pure Ruby means type-checked at load time, no YAML parsing dependency. User challenged YAML approach and preferred pure Ruby. | No | collaborative |
| D003 | M001-3b7cia | pattern | Custom document behavior pattern | Template method with default no-ops (customize_title, customize_filename, customize_content, customize_readme_entry) | Simplest pattern for two custom types (ADR, HowTo). No handler chain infrastructure needed. Classic OO with sensible defaults. YAGNI for strategy/chain patterns. | Yes — if custom types grow beyond 5 | collaborative |
| D004 | M001-3b7cia | arch | Scope of common metadata | Narrow — only ~9 lines of universal formatting rules shared; per-template specifics stay hardcoded in each template | Line-by-line diff revealed only first ~9 lines are truly identical across templates. Bulk of metadata is contextual to document type (concept vs change, reader vs reviewer). Extracting more would require parameterization complexity. | No | collaborative |
