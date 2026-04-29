---
estimated_steps: 114
estimated_files: 4
skills_used: []
---

# T02: Create registry DSL in document_types.rb with config-based template and section tag resolution

---
estimated_steps: 7
estimated_files: 4
skills_used:
  - verify-before-complete
---

# T02: Create registry DSL in document_types.rb with config-based template and section tag resolution

**Slice:** S02 — Registry DSL and template method pattern
**Milestone:** M001-3b7cia

## Description

Create the pure Ruby registry DSL in a new `lib/diataxis/document_types.rb` file. This is the core of the refactor: a `DocumentRegistry.configure` block where each type is registered with a config hash. Simple types (explanation, tutorial, etc.) create anonymous subclasses of `Document` with the correct `type_config`. Custom types (ADR, HowTo) reference their existing handler classes.

Critically, this task also fixes 3 places that derive identifiers from `class.name.split('::').last` — which breaks for anonymous subclasses whose `.name` returns `nil`:

1. **`TemplateLoader.find_template_file`** (line 33): Uses `document_class.name.split('::').last` to derive template filename. Fix: read `type_config[:template]` first, fall back to class name.
2. **`ReadmeManager#update_existing_readme`** (line 102): Uses `doc_type.name.split('::').last` to derive section comment tag (`<!-- explanationlog -->`). Fix: read `type_config[:section_tag]` first, fall back to class name.
3. **`ReadmeManager#create_new_readme`** (line 154): Same pattern as #2. Fix: same approach.
4. **`Document#type`** (line 93-95): Uses `self.class.name.split('::').last.downcase` for logging. Fix: read `type_config[:command]` which is always present.

The `DocumentRegistry.configure` method accepts a block, clears existing registrations, and calls `register` for each type. Each `register` call creates an anonymous `Class.new(Document)` (for simple types) or uses the provided `handler:` class, then calls `register_type` on it.

**IMPORTANT**: This task adds the new `document_types.rb` and updates `TemplateLoader`/`ReadmeManager`/`Document` to use config keys. It does NOT yet change `diataxis.rb` requires or delete shell classes — the old shell class files still load and still call `register_type`. The new `document_types.rb` is NOT required yet. This keeps T02 independently testable.

**IMPORTANT design constraint for README section tags**: The current shell classes produce section tags like `<!-- explanationlog -->` (from class name `Explanation`), `<!-- prlog -->` (from `PR`), `<!-- fivewhyanalysislog -->` (from `FiveWhyAnalysis`). The `section_tag` values in `type_config` MUST match these exact strings to avoid breaking existing README files. Derive them from the current class names: explanation, tutorial, handover, fivewhyanalysis, note, project, pr, adr, howto.

## Steps

1. Add `section_tag:` and `template:` keys to the `register_type` method in `Document` (line 15-26). Add them to the `@type_config` hash. `template:` defaults to nil (meaning 'derive from class name'). `section_tag:` defaults to nil (meaning 'derive from class name').

2. Update `TemplateLoader.find_template_file` (line 32-45) to prefer `type_config[:template]` over class name derivation:
   ```ruby
   def self.find_template_file(document_class)
     template_name = document_class.type_config[:template] ||
                     document_class.name&.split('::')&.last&.downcase
     raise TemplateError.new("Cannot determine template name for #{document_class}") unless template_name
     template_filename = "#{template_name}.md"
     category = document_class.type_config[:category]
     gem_root = File.expand_path('../..', __dir__)
     gem_template = File.join(gem_root, 'templates', category, template_filename)
     return gem_template if File.exist?(gem_template)
     raise TemplateError.new("Gem template not found: #{template_filename}",
                             template_name: template_filename,
                             search_paths: [gem_template])
   end
   ```

3. Update `ReadmeManager#update_existing_readme` (line 99-121) — change line 102-104 from:
   ```ruby
   section_name = doc_type.name.split('::').last
   section_title = document_type_section(doc_type)
   section_type = section_name.downcase
   ```
   to:
   ```ruby
   section_title = document_type_section(doc_type)
   section_type = doc_type.type_config[:section_tag] || doc_type.name&.split('::')&.last&.downcase
   ```

4. Update `ReadmeManager#create_new_readme` (line 148-185) — change line 154 similarly:
   ```ruby
   section_type = doc_type.type_config[:section_tag] || doc_type.name&.split('::')&.last&.downcase
   ```

5. Update `Document#type` protected method (line 93-95) from:
   ```ruby
   def type
     self.class.name.split('::').last.downcase
   end
   ```
   to:
   ```ruby
   def type
     self.class.type_config[:command]
   end
   ```

6. Update `Document.find_files` (line 72-77) — line 75 uses `name.split('::').last` for logging. Change to use `type_config[:command]` or `type_config[:section_tag]`:
   ```ruby
   Diataxis.logger.info "Found #{files.length} #{type_config[:section_tag] || name&.split('::')&.last || 'unknown'} files matching #{search_pattern}"
   ```

7. Create `lib/diataxis/document_types.rb` with the `DocumentRegistry.configure` block. For each of the 9 types, register with all config keys. Simple types use `handler: nil` (which creates anonymous subclass). Custom types use `handler: ADR` or `handler: HowTo`. The `configure` method:
   - Accepts a block
   - The block receives a builder object that collects registration calls
   - After the block, each registration creates the appropriate class and calls `register_type`
   
   Actually, simpler approach: `DocumentRegistry.configure` is a DSL block that calls `DocumentRegistry.register_type_config(config_hash)` for each type. Each call creates a `Class.new(Document)` or uses the `handler:` class, sets `type_config`, and calls `DocumentRegistry.register(command, klass)`.

   The 9 registrations (with exact section_tag values matching current class names):
   - explanation: template:'explanation', section_tag:'explanation', prefix:'understanding', category:'explanations', config_key:'explanations', readme_section:'Explanations', title_prefix:'Understanding'
   - tutorial: template:'tutorial', section_tag:'tutorial', prefix:'tutorial', category:'tutorials', config_key:'tutorials', readme_section:'Tutorials'
   - handover: template:'handover', section_tag:'handover', prefix:'handover', category:'references', config_key:'handovers', readme_section:'Handover Notes'
   - fivewhyanalysis: template:'fivewhyanalysis', section_tag:'fivewhyanalysis', prefix:'5why', category:'references', config_key:'five_why_analyses', readme_section:'5-Why Analyses'
   - note: template:'note', section_tag:'note', prefix:'note', category:'references', config_key:'notes', readme_section:'Notes'
   - project: template:'project', section_tag:'project', prefix:'project', category:'references', config_key:'projects', readme_section:'Projects'
   - pr: template:'pr', section_tag:'pr', prefix:'pr', category:'explanations', config_key:'explanations', readme_section:'Pull Requests'
   - adr: handler:Diataxis::ADR (keeps existing class with section_tag:'adr', template:'adr')
   - howto: handler:Diataxis::HowTo (keeps existing class with section_tag:'howto', template:'howto')

   **NOTE**: Do NOT require document_types.rb from diataxis.rb yet. That happens in T04. The file is created but not loaded. This lets us test T02 changes in isolation — the existing shell classes still load and still work, and the config-key fallback paths handle them.

## Must-Haves

- [ ] `register_type` accepts optional `template:` and `section_tag:` keyword args
- [ ] `TemplateLoader.find_template_file` reads `type_config[:template]` before falling back to class name
- [ ] `ReadmeManager` reads `type_config[:section_tag]` before falling back to class name — in both `update_existing_readme` and `create_new_readme`
- [ ] `Document#type` uses `type_config[:command]` instead of class name derivation
- [ ] `Document.find_files` logging uses config-based name instead of class name
- [ ] `lib/diataxis/document_types.rb` exists with all 9 type registrations
- [ ] All existing tests pass — shell classes still load, config fallbacks work

## Negative Tests

- **Anonymous class `.name` returns nil**: All 4 `.name.split('::').last` call sites now use safe navigation (`&.`) or config-key fallback. No NilError possible.
- **Missing template config key**: Falls back to class name derivation (existing behavior).
- **Missing section_tag config key**: Falls back to class name derivation (existing behavior).

## Verification

- `bundle exec rspec` — all examples pass
- `bundle exec cucumber` — all scenarios pass
- `test -f lib/diataxis/document_types.rb` — file exists
- `grep -c 'register_type_config\|register(' lib/diataxis/document_types.rb` — returns >= 9 (all types registered)
- `ruby -e "require_relative 'lib/diataxis/document_types'"` — loads without error (syntax check)

## Inputs

- `lib/diataxis/document.rb` — T01 output with template method hooks added
- `lib/diataxis/template_loader.rb` — current TemplateLoader with find_template_file to update
- `lib/diataxis/readme_manager.rb` — current ReadmeManager with name-based section tags to update
- `lib/diataxis/document/adr.rb` — existing ADR class (referenced as handler)
- `lib/diataxis/document/howto.rb` — existing HowTo class (referenced as handler)

## Expected Output

- `lib/diataxis/document.rb` — modified: register_type accepts template:/section_tag:, type method uses config, find_files logging uses config
- `lib/diataxis/template_loader.rb` — modified: find_template_file prefers type_config[:template]
- `lib/diataxis/readme_manager.rb` — modified: section tag derivation prefers type_config[:section_tag]
- `lib/diataxis/document_types.rb` — new file: DocumentRegistry.configure block with all 9 type registrations

## Inputs

- ``lib/diataxis/document.rb` — T01 output with template method hooks`
- ``lib/diataxis/template_loader.rb` — current TemplateLoader to update`
- ``lib/diataxis/readme_manager.rb` — current ReadmeManager to update`
- ``lib/diataxis/document/adr.rb` — existing ADR class referenced as handler`
- ``lib/diataxis/document/howto.rb` — existing HowTo class referenced as handler`

## Expected Output

- ``lib/diataxis/document.rb` — register_type accepts template:/section_tag:, type method and find_files use config keys`
- ``lib/diataxis/template_loader.rb` — find_template_file prefers type_config[:template] over class name`
- ``lib/diataxis/readme_manager.rb` — section tag derivation prefers type_config[:section_tag] over class name`
- ``lib/diataxis/document_types.rb` — new file with DocumentRegistry.configure block and all 9 type registrations`

## Verification

bundle exec rspec && bundle exec cucumber && test -f lib/diataxis/document_types.rb && ruby -e "require_relative 'lib/diataxis/document_types'"
