# 0016. Replace per-type class files with registry DSL and template method hooks

Date: 2026-05-02

## Status

Accepted

## Context

[ADR-0008](./0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md) established per-type class files under `lib/diataxis/document/` to improve maintainability over the original monolithic approach. [ADR-0012](./0012-move-to-external-template-system-with-direct-templateloader-usage.md) then moved templates to external `.md` files loaded by `TemplateLoader`. After both changes, the per-type class files remained but had become pure boilerplate — each one simply subclassed `Document` and called `register_type` with configuration hashes. Adding a new document type still required 5+ file changes across class files, require statements, CLI routing, and help text.

```ruby
# Before: each type needed its own class file (e.g., lib/diataxis/document/explanation.rb)
module Diataxis
  class Explanation < Document
    register_type command: 'explanation', prefix: 'explanation', ...
  end
end
```

- Seven of nine document types had no custom behavior at all — just configuration
- Only ADR (auto-numbering) and HowTo (title normalization) needed custom logic
- The boilerplate class files added friction without providing value

## Decision

Replace per-type class files with a pure Ruby registry DSL (`DocumentRegistry.configure` block) in `lib/diataxis/document_types.rb`. Custom behavior uses template method hooks in the `Document` base class. Only types with genuinely unique behavior retain custom handler classes.

### Registry DSL

All document type registrations live in a single `DocumentRegistry.configure` block. Each `register` call declares configuration — no subclass needed:

```ruby
# lib/diataxis/document_types.rb
DocumentRegistry.configure do |r|
  r.register(
    command: 'explanation',
    prefix: 'explanation',
    category: 'explanation',
    config_key: 'explanations',
    readme_section: 'Explanations',
    template: 'explanation',
    section_tag: 'explanation'
  )
  # ... 7 generic types registered this way

  r.register(
    handler: Diataxis::ADR,       # custom handler — only when needed
    command: 'adr',
    prefix: '[0-9][0-9][0-9][0-9]',
    # ...
  )
end
```

- Types without a `handler:` key get an anonymous `Class.new(Document)` at registration time
- Types with a `handler:` key use their existing custom class (ADR, HowTo)

### Template method hooks

The `Document` base class provides three no-op hooks that custom handler classes can override:

```ruby
# lib/diataxis/document.rb
class Document
  def customize_title(title)    = title
  def customize_filename(_, _)  = nil
  def customize_content(content) = content
end
```

- `customize_title` — HowTo uses this to normalize "how to X" prefixes
- `customize_filename` — ADR uses this for auto-numbered filenames (`0016-slug.md`)
- `customize_content` — available for future types that need post-processing

## Consequences

**What becomes easier:**

- Adding a new simple document type requires only two changes: a `register` call in `document_types.rb` and a `.md` template file in `templates/`
- CLI routing, help text generation, and README integration are automatic from the registration metadata
- The full type inventory is visible in one file instead of scattered across 9+ class files

**What becomes more difficult:**

- Types with custom behavior must understand the template method pattern to override hooks
- The anonymous `Class.new(Document)` technique means generic types don't have named classes for debugging stack traces
- Developers unfamiliar with Ruby DSLs may find the `DocumentRegistry.configure` block less obvious than explicit class files

**Trade-off:** The registry DSL optimizes for the common case (adding simple types) at the cost of slightly higher conceptual overhead for custom types. This is appropriate because 7 of 9 types are simple, and the custom type pattern is documented in [How to add a new document template](../how_to_add_a_new_document_template.md).

## References

- [ADR-0008: Refactor document templates into separate class files](./0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md) — the decision this supersedes
- [ADR-0012: Move to external template system](./0012-move-to-external-template-system-with-direct-templateloader-usage.md) — the prior template externalization that made class files redundant
- [How to add a new document template](../how_to_add_a_new_document_template.md) — step-by-step guide updated to reflect the registry DSL
- `lib/diataxis/document_types.rb` — the registry DSL (source of truth)
- `lib/diataxis/document.rb` — the base class with template method hooks
