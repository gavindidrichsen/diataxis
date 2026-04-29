---
id: T02
parent: S02
milestone: M001-3b7cia
key_files:
  - lib/diataxis/document.rb
  - lib/diataxis/template_loader.rb
  - lib/diataxis/readme_manager.rb
  - lib/diataxis/document_types.rb
key_decisions:
  - Used RegistryBuilder pattern for DocumentRegistry.configure — block collects registrations, then applies them after block completes, keeping registration order deterministic
  - Safe navigation (&.) used consistently at all 4 class-name derivation sites so anonymous subclasses (name=nil) never raise NoMethodError
  - Section tags in document_types.rb match exact current class-name-derived values (e.g. 'fivewhyanalysis' not 'five_why_analysis') to preserve README compatibility
  - document_types.rb is NOT required from diataxis.rb yet — file is independently loadable for testing, integration deferred to T04
duration: 
verification_result: passed
completed_at: 2026-04-29T17:31:20.787Z
blocker_discovered: false
---

# T02: Create registry DSL in document_types.rb and make TemplateLoader, ReadmeManager, and Document resilient to anonymous subclasses via config-key fallbacks

**Create registry DSL in document_types.rb and make TemplateLoader, ReadmeManager, and Document resilient to anonymous subclasses via config-key fallbacks**

## What Happened

Implemented all 7 steps from the task plan:

1. **Added `template:` and `section_tag:` keyword args to `Document.register_type`** — both default to `nil`, meaning existing shell classes that don't pass them continue to work via class-name-derived fallbacks.

2. **Updated `TemplateLoader.find_template_file`** — now reads `type_config[:template]` first, falls back to `document_class.name&.split('::')&.last&.downcase` with safe navigation (`&.`) so anonymous subclasses (whose `.name` is `nil`) don't raise `NoMethodError`. Raises `TemplateError` if neither source yields a name.

3. **Updated `ReadmeManager#update_existing_readme`** (line 102) — replaced `doc_type.name.split('::').last` / `section_name.downcase` with `doc_type.type_config[:section_tag] || doc_type.name&.split('::')&.last&.downcase`. Removed the now-unused `section_name` variable.

4. **Updated `ReadmeManager#create_new_readme`** (line 154) — same pattern as step 3.

5. **Updated `Document#type`** — now returns `self.class.type_config[:command]` directly instead of deriving from class name. The `:command` key is always present (it's required by `register_type`).

6. **Updated `Document.find_files` logging** — uses `type_config[:section_tag] || name&.split('::')&.last || 'unknown'` so anonymous subclasses log a meaningful identifier.

7. **Created `lib/diataxis/document_types.rb`** with a `DocumentRegistry.configure` DSL block that registers all 9 document types. Simple types (explanation, tutorial, handover, fivewhyanalysis, note, project, pr) create anonymous `Class.new(Document)` subclasses. Custom types (ADR, HowTo) pass `handler: Diataxis::ADR` / `handler: Diataxis::HowTo` to reuse existing classes. Section tags match the exact strings derived from current class names to avoid breaking existing README files.

**Key design decision**: The `configure` method uses a `RegistryBuilder` object that collects registration hashes, then applies them after the block completes. Each `apply_registration` call creates the appropriate class (anonymous or handler) and calls `register_type` on it. The `handler` key is deleted from the config hash before passing to `register_type` since it's not a valid keyword arg there.

**Important**: `document_types.rb` is NOT required from `diataxis.rb` yet — that happens in T04. The file loads independently and the existing shell classes still work unchanged.

## Verification

Ran the full verification suite:
- `bundle exec rspec`: 37 examples, 0 failures (0.19s)
- `bundle exec cucumber`: 6 scenarios, 39 steps all passing (1.69s)
- `test -f lib/diataxis/document_types.rb`: file exists
- `grep -c 'r\.register(' lib/diataxis/document_types.rb`: returns 9 (all types registered)
- `ruby -e "require_relative 'lib/diataxis/document_types'"`: loads without error

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bundle exec rspec` | 0 | ✅ pass — 37 examples, 0 failures | 192ms |
| 2 | `bundle exec cucumber` | 0 | ✅ pass — 6 scenarios, 39 steps all passing | 1691ms |
| 3 | `test -f lib/diataxis/document_types.rb` | 0 | ✅ pass — file exists | 10ms |
| 4 | `grep -c 'r\.register(' lib/diataxis/document_types.rb` | 0 | ✅ pass — returns 9 | 15ms |
| 5 | `ruby -e "require_relative 'lib/diataxis/document_types'"` | 0 | ✅ pass — loads without error | 200ms |

## Deviations

The task plan's step 7 listed some incorrect readme_section values (e.g. 'Handover Notes' instead of 'Handovers', '5-Why Analyses' instead of 'Five Why Analyses'). Used the actual values from the existing shell classes to maintain compatibility.

## Known Issues

None.

## Files Created/Modified

- `lib/diataxis/document.rb`
- `lib/diataxis/template_loader.rb`
- `lib/diataxis/readme_manager.rb`
- `lib/diataxis/document_types.rb`
