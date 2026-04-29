# S02 — Registry DSL and Template Method Pattern — Research

**Date:** 2026-04-29
**Owned Requirements:** R003, R004, R005, R009

## Summary

This slice replaces 7 empty shell class files with a pure Ruby registry DSL in a new `lib/diataxis/document_types.rb`, adds template method hooks to the `Document` base class for ADR and HowTo custom behavior, and rewires the loading/require chain so the 7 shell files can be deleted. The work is well-scoped — the codebase is small, the patterns are standard Ruby OOP, and the two custom types (ADR, HowTo) have clearly bounded overrides.

The primary risk is the template name resolution in `TemplateLoader.find_template_file`, which derives the template filename from the Ruby class name (`document_class.name.split('::').last.downcase`). When shell classes are removed and simple types are registered as `Document` (not as named subclasses), the class name will be `document` for all of them — breaking template lookup. This must be solved by adding a `template:` key to the registry config and updating `TemplateLoader` to prefer it over class name derivation.

A secondary finding: ADR's `pattern` class method override (adr.rb:17-19) still uses `Config.path_for('default')` instead of loading config from `config_root` — the same bug pattern that S01 fixed in the base class. This should be addressed as part of this slice.

## Recommendation

Build in this order: (1) Add template method hooks to `Document` base class as no-op defaults. (2) Create the registry DSL in `document_types.rb` with a `template:` key for explicit template name mapping. (3) Extend `TemplateLoader` to accept the template name from registry config. (4) Migrate ADR and HowTo custom behavior into overrides using the template method hooks. (5) Wire everything together in `diataxis.rb`, remove the 7 shell class files, and verify behavioral equivalence.

This order lets you prove the registry DSL and template method hooks independently before removing any class files — the riskiest moment (deletion + rewiring) comes last.

## Implementation Landscape

### Key Files

- `lib/diataxis/document_registry.rb` — Current registry. Has `register(command_name, document_class)`, `lookup`, `all`, `command_names`, `each`. Must be extended with `configure` DSL block and `register` that accepts config hashes (not just class references). Must still return objects that respond to the same interface (`find_files`, `pattern`, `format_readme_entry`, `readme_section_title`, `config_key`, `type_config`, `new`, `matches_filename_pattern?`, `generate_filename_from_file`, `generate_filename_from_existing`).
- `lib/diataxis/document.rb` — Base class. Currently has `register_type` class method and instance methods. Needs 4 template method hooks added as no-op defaults: `customize_title(title)`, `customize_filename(title, dir)`, `customize_content(content)`, `customize_readme_entry(title, path, filepath)`. The existing `apply_title_prefix` and `generate_filename` are effectively the things that `customize_title` and `customize_filename` will replace.
- `lib/diataxis/document_types.rb` — **New file**. Contains `DocumentRegistry.configure` block with `register` calls for all 9 types. Simple types point to `Document` (or an anonymous subclass). Custom types specify `handler: Diataxis::ADR` or `handler: Diataxis::HowTo`.
- `lib/diataxis/template_loader.rb` — `find_template_file` must be updated to accept a `template_name` override from registry config instead of always deriving from `document_class.name`. Current logic: `class_name = document_class.name.split('::').last` then `"#{class_name.downcase}.md"`. When simple types are `Document` (not named subclasses), this would resolve to `document.md` for all of them.
- `lib/diataxis/document/adr.rb` — Kept. Custom overrides: `pattern`, `generate_filename_from_file`, `matches_filename_pattern?`, `format_readme_entry`, `generate_filename` (auto-numbering), `content` (passes adr_number/status variables). These are **not** just template method hooks — they override class-level methods too.
- `lib/diataxis/document/howto.rb` — Kept. Custom override: title validation/normalization in `initialize`. Maps to `customize_title`.
- `lib/diataxis/diataxis.rb` — Must replace 7 `require_relative 'document/xxx'` lines with single `require_relative 'document_types'`. Keep requires for `adr.rb` and `howto.rb`.
- **7 shell classes to delete:** `explanation.rb`, `tutorial.rb`, `handover.rb`, `five_why_analysis.rb`, `note.rb`, `project.rb`, `pr.rb` — each contains only a `register_type` call and no custom behavior.

### Critical Design Constraint: Template Name Resolution

`TemplateLoader.find_template_file` currently resolves template names from the Ruby class name:
```ruby
class_name = document_class.name.split('::').last  # e.g. "Explanation"
template_filename = "#{class_name.downcase}.md"     # e.g. "explanation.md"
category = document_class.type_config[:category]    # e.g. "explanations"
```

When shell classes are removed, simple types will be registered as `Document` or anonymous subclasses. The solution is to add a `template:` key to `type_config` and update `TemplateLoader`:

```ruby
# In TemplateLoader.find_template_file:
template_name = document_class.type_config[:template] ||
                document_class.name.split('::').last.downcase
template_filename = "#{template_name}.md"
```

Registry entries would include: `register :explanation, template: 'explanation', category: 'explanations', ...`

### ReadmeManager Consumption Pattern

`ReadmeManager` iterates `DocumentRegistry.all` and calls on each class:
- `readme_section_title` → from `type_config[:readme_section]`
- `config_key` → from `type_config[:config_key]`
- `find_files(directory)` → calls `pattern(config_root)` + `Dir.glob`
- `format_readme_entry(title, relative_path, filepath)` → base class returns `* [title](path)`, ADR overrides
- `name` → `doc_type.name.split('::').last` used for section tag (`<!-- explanationlog -->`)
- `matches_filename_pattern?` and `generate_filename_from_file` — used by `FileManager`

The `name` usage is significant: `doc_type.name.split('::').last` produces the HTML comment tag for README sections (e.g. `<!-- explanationlog -->`). If all simple types are bare `Document`, they'd all produce `<!-- documentlog -->`. This means each registered type needs either a named subclass or a way to override the `name`-based section tag. The simplest approach: create anonymous subclasses with `Class.new(Document)` and set a class-level name/tag attribute, or add a `section_tag:` config key.

### ADR Complexity Inventory

ADR overrides far more than the other types — this is the riskiest custom type:

| Method | What it does | Template method hook? |
|--------|-------------|----------------------|
| `self.pattern(config_root)` | Custom glob: `[0-9][0-9][0-9][0-9]-*.md` | No — class-level override |
| `self.generate_filename_from_file(filepath)` | Extracts ADR number from filename, rebuilds slug | No — class-level override |
| `self.matches_filename_pattern?(filename)` | `\d{4}-.*\.md` | No — class-level override |
| `self.format_readme_entry(title, relative_path, filepath)` | `[ADR-NNNN](path) - title` | Could be `customize_readme_entry` |
| `generate_filename` (instance) | Auto-numbers by scanning existing files | Could be `customize_filename` |
| `content` (instance) | Passes `adr_number:` and `status:` to TemplateLoader | Could be `customize_content` |

**Key insight:** ADR's custom behavior spans both class-level and instance-level methods. The template method hooks (`customize_*`) cover instance methods. Class-level overrides (pattern, filename generation, README formatting) stay as regular class method overrides on the `ADR` subclass — they don't need template method hooks because ADR will remain a named subclass.

### HowTo Complexity Inventory

| Method | What it does | Template method hook? |
|--------|-------------|----------------------|
| `initialize(title, directory)` | Validates and normalizes title (adds "How to" prefix) | Maps to `customize_title` |

HowTo's custom behavior is minimal — just title normalization. It stays as a named subclass with a `customize_title` override.

### Build Order

1. **Add template method hooks to `Document` base class** — `customize_title`, `customize_filename`, `customize_content`, `customize_readme_entry` as no-op defaults. Refactor existing `apply_title_prefix` and `generate_filename` to call through these hooks. This is the safest first step — it changes behavior by zero since defaults are no-ops.

2. **Create registry DSL in `document_types.rb`** — `DocumentRegistry.configure` block with `register` for all 9 types. Each registration includes `template:` key for template name resolution. Simple types create anonymous subclasses of `Document`. Custom types use `handler: ClassName`. The `configure` block replaces the current pattern of each class file calling `register_type`.

3. **Update `TemplateLoader.find_template_file`** — Use `type_config[:template]` when present, fall back to class name derivation. Also update `ReadmeManager` section tag derivation to use a config key instead of `name.split('::').last`.

4. **Migrate ADR/HowTo to use template method hooks** — ADR: move auto-numbering to `customize_filename`, content customization to `customize_content`, README formatting to `customize_readme_entry`. HowTo: move title normalization to `customize_title`. Keep both as named subclasses.

5. **Wire up `diataxis.rb`, delete shell classes, verify** — Replace 7 requires with single `require_relative 'document_types'`. Delete 7 shell class files. Run full test suite.

### Verification Approach

1. `bundle exec rspec` — 37 examples, 0 failures (existing tests cover document creation, README updates, title changes, ADR numbering)
2. `bundle exec cucumber` — 6 scenarios, 39 steps all passing (covers configuration management, YAML front matter)
3. `ls lib/diataxis/document/` — should contain only `adr.rb` and `howto.rb`
4. `ruby -e "require_relative 'lib/diataxis'; puts Diataxis::DocumentRegistry.command_names.sort"` — should print all 9 command names
5. `ruby -e "require_relative 'lib/diataxis'; Diataxis::DocumentRegistry.all.each { |c| puts \"#{c.type_config[:command]}: #{c.type_config[:template]}\" }"` — verify template mapping
6. Smoke test: Create one of each simple type in a temp directory and verify output matches pre-refactor output

## Constraints

- `ReadmeManager` uses `doc_type.name.split('::').last` to derive README section comment tags (`<!-- explanationlog -->`). Anonymous subclasses have `nil` names. Must add a `section_tag` or `command` based tag derivation.
- `TemplateLoader.find_template_file` uses `document_class.name.split('::').last` for template filename. Must add `template:` config key fallback.
- ADR's `pattern` override (line 17-19) uses `Config.path_for('default')` instead of `config_root` — same bug pattern S01 fixed in the base class. Should be fixed in this slice.
- Existing tests reference specific class names in expectations (e.g. `Diataxis::CLI.run(['explanation', 'new', ...])` but test by file existence and content, not by class name — so they should survive the refactor.

## Common Pitfalls

- **Anonymous subclass naming** — `Class.new(Document).name` returns `nil`. Any code path that calls `.name` on a document class (TemplateLoader, ReadmeManager section tags, test output) will break. The registry must either set a name on anonymous classes or provide config keys that bypass `.name` calls.
- **Require order** — `document_types.rb` must be required after `document.rb`, `adr.rb`, and `howto.rb` because it references those classes. If loaded too early, the handler classes won't exist.
- **Double registration** — If both the old `register_type` calls in class files and the new `document_types.rb` `configure` block run, types get registered twice. The migration must be atomic: old registrations removed in the same step new ones are added.

## Open Risks

- The `ReadmeManager` section tag derivation from class name is used in existing README files (e.g. `<!-- explanationlog -->`). If the tag changes, existing README sections won't be found and updated — they'll get duplicated. The tag derivation must produce the same strings as before.
