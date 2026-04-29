# S02: Registry DSL and template method pattern

**Goal:** Shell class files eliminated; dia new adr still auto-numbers; dia new howto still normalizes titles; adding a type requires only register call + .md file
**Demo:** Shell class files eliminated; dia new adr still auto-numbers; dia new howto still normalizes titles; adding a type requires only register call + .md file

## Must-Haves

- `bundle exec rspec` — all examples pass (0 failures)
- `bundle exec cucumber` — all 6 scenarios, 39 steps pass
- `ls lib/diataxis/document/` contains only `adr.rb` and `howto.rb`
- `ruby -e "require_relative 'lib/diataxis'; puts Diataxis::DocumentRegistry.command_names.sort"` prints all 9 command names
- Registry entries for simple types produce behaviorally equivalent output to pre-refactor shell classes
- ADR auto-numbering and HowTo title normalization work identically to pre-refactor
- README section comment tags (`<!-- explanationlog -->` etc.) are preserved exactly

## Proof Level

- This slice proves: - This slice proves: integration
- Real runtime required: yes
- Human/UAT required: no

## Integration Closure

- Upstream surfaces consumed: `templates/common.metadata` and `TemplateLoader#resolve_placeholder` from S01; all 5 updated template files with `{{common.metadata}}` placeholders
- New wiring introduced in this slice: `lib/diataxis/document_types.rb` registry DSL replaces 7 individual `require_relative` + `register_type` calls; `TemplateLoader.find_template_file` uses config-based template name instead of class name derivation; `ReadmeManager` uses config-based section tags instead of class name derivation
- What remains before the milestone is truly usable end-to-end: S03 (cleanup/tests/SOLID audit), S04 (output consistency polish), S05 (documentation update)

## Verification

- Not provided.

## Tasks

- [x] **T01: Add template method hooks to Document base class** `est:30m`
  ---
estimated_steps: 4
estimated_files: 2
skills_used:
  - verify-before-complete
---

# T01: Add template method hooks to Document base class

**Slice:** S02 — Registry DSL and template method pattern
**Milestone:** M001-3b7cia

## Description

Add 4 template method hooks to `Document` base class as no-op defaults that subclasses can override. These hooks provide extension points for ADR and HowTo custom behavior without requiring every type to have its own class file.

The 4 hooks:
- `customize_title(title)` — returns title unchanged (HowTo will override for title normalization)
- `customize_filename(title, dir)` — returns nil (ADR will override for auto-numbering)
- `customize_content(content)` — returns content unchanged (ADR will override to inject adr_number/status)
- `customize_readme_entry(title, path, filepath)` — returns nil (ADR will override for custom README formatting)

This task is purely additive — no existing behavior changes because all hooks return no-op defaults. The hooks are called from existing methods but fall through to current logic when the hook returns nil or unchanged values.

## Steps

1. Open `lib/diataxis/document.rb` and add 4 protected methods after the existing `apply_title_prefix` method (around line 104):
   - `def customize_title(title)` — returns `title` unchanged
   - `def customize_filename(title, dir)` — returns `nil` (nil means 'use default logic')
   - `def customize_content(content)` — returns `content` unchanged
   - `def customize_readme_entry(title, path, filepath)` — returns `nil` (nil means 'use default logic')

2. Wire `customize_title` into `initialize`: change line 81 from `@title = apply_title_prefix(title)` to `@title = customize_title(apply_title_prefix(title))`. Since the default returns the title unchanged, behavior is identical.

3. Wire `customize_filename` into `initialize`: after `@filename = File.join(@directory, generate_filename)` (line 83), add: `custom = customize_filename(@title, @directory); @filename = custom if custom`. Since default returns nil, the existing filename is preserved.

4. Wire `customize_content` into instance method `content` (line 118-120): change to call `customize_content(TemplateLoader.load_template(self.class, @title))`. Since default returns content unchanged, behavior is identical.

5. Add class-level `format_readme_entry` hook delegation: In the existing `Document.format_readme_entry` class method (line 68-70), this stays as-is — the instance-level `customize_readme_entry` will be used by ADR's class-level override in T03. No change needed here in T01.

6. Run `bundle exec rspec` and `bundle exec cucumber` to verify zero behavior change.

## Must-Haves

- [ ] 4 protected template method hooks exist on Document class with no-op defaults
- [ ] `customize_title` is called in Document#initialize after apply_title_prefix
- [ ] `customize_filename` is called in Document#initialize, used only when non-nil
- [ ] `customize_content` is called in Document#content
- [ ] All existing tests pass with zero changes — behavior is identical

## Verification

- `bundle exec rspec` — 37 examples, 0 failures
- `bundle exec cucumber` — 6 scenarios, 39 steps all passing
- `grep -c 'def customize_' lib/diataxis/document.rb` returns 4

## Inputs

- `lib/diataxis/document.rb` — base Document class to extend with hooks

## Expected Output

- `lib/diataxis/document.rb` — modified with 4 template method hooks wired into existing methods
  - Files: `lib/diataxis/document.rb`
  - Verify: bundle exec rspec && bundle exec cucumber && test $(grep -c 'def customize_' lib/diataxis/document.rb) -eq 4

- [x] **T02: Create registry DSL in document_types.rb with config-based template and section tag resolution** `est:1h`
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
  - Files: `lib/diataxis/document.rb`, `lib/diataxis/template_loader.rb`, `lib/diataxis/readme_manager.rb`, `lib/diataxis/document_types.rb`
  - Verify: bundle exec rspec && bundle exec cucumber && test -f lib/diataxis/document_types.rb && ruby -e "require_relative 'lib/diataxis/document_types'"

- [x] **T03: Migrate ADR and HowTo custom behavior to template method hooks and fix ADR pattern bug** `est:45m`
  ---
estimated_steps: 5
estimated_files: 3
skills_used:
  - verify-before-complete
---

# T03: Migrate ADR and HowTo custom behavior to template method hooks and fix ADR pattern bug

**Slice:** S02 — Registry DSL and template method pattern
**Milestone:** M001-3b7cia

## Description

Migrate ADR and HowTo custom behavior to use the template method hooks added in T01, and fix the pre-existing bug in ADR's `pattern` method that uses `Config.path_for('default')` instead of the config_root parameter.

### HowTo migration
HowTo currently overrides `initialize` to call `validate_title` before `super`. This maps to `customize_title`: move the title validation/normalization logic into `customize_title(title)` and remove the `initialize` override. The `customize_title` hook is called inside `Document#initialize` (wired in T01) after `apply_title_prefix`, so the normalization will happen at the right point.

**Wait — there's a subtlety.** HowTo's `validate_title` does MORE than `apply_title_prefix`. It raises on empty title, and it lowercases the first letter of the action verb. `apply_title_prefix` just prepends 'How to' if missing. The current flow is: HowTo#initialize calls validate_title(raw_title) which normalizes, then super(validated, directory) which calls apply_title_prefix(validated) — but apply_title_prefix is a no-op because validate_title already added 'How to'.

With the hook: Document#initialize calls apply_title_prefix(title) then customize_title(result). So HowTo's customize_title receives the already-prefixed title. HowTo's customize_title should: validate non-empty, and ensure proper casing ('How to' + lowercased action). Since apply_title_prefix already added 'How to', customize_title just needs to validate and fix casing.

Actually the simplest migration: keep HowTo's initialize override but have it call customize_title internally, OR just keep the current pattern since it works. The template method hooks are primarily for the registry DSL where anonymous subclasses need override points. HowTo is a named subclass that will stay as a handler class.

**Decision: Keep HowTo's initialize override as-is.** It works correctly, HowTo remains a named subclass referenced by `handler:` in the registry, and forcing it through customize_title adds complexity for no benefit. The template method hooks exist for future extensibility, not for mandatory migration of working code.

### ADR migrations
1. **Fix `pattern` bug** (line 17-19): `Config.path_for('default')` should be `Config.load(config_root)[type_config[:config_key]] || Config.load(config_root)['default']`. This is the same bug S01 fixed in the base class. The ADR override bypasses the base class fix.

2. **Add `template:` and `section_tag:` to ADR's register_type call** (line 8-15): Add `template: 'adr', section_tag: 'adr'` so the config-based resolution in TemplateLoader and ReadmeManager works for ADR too.

3. **Add `template:` and `section_tag:` to HowTo's register_type call** (line 9-16): Add `template: 'howto', section_tag: 'howto'`.

4. **Update all 7 shell class `register_type` calls** to include `template:` and `section_tag:` keys. This ensures that even while shell classes still exist (before T04 deletes them), the config-based resolution works. The values:
   - explanation.rb: `template: 'explanation', section_tag: 'explanation'`
   - tutorial.rb: `template: 'tutorial', section_tag: 'tutorial'`
   - handover.rb: `template: 'handover', section_tag: 'handover'`
   - five_why_analysis.rb: `template: 'fivewhyanalysis', section_tag: 'fivewhyanalysis'`
   - note.rb: `template: 'note', section_tag: 'note'`
   - project.rb: `template: 'project', section_tag: 'project'`
   - pr.rb: `template: 'pr', section_tag: 'pr'`

## Steps

1. Fix ADR's `pattern` class method (line 17-19 of `lib/diataxis/document/adr.rb`). Change from:
   ```ruby
   def self.pattern(config_root = '.')
     default_dir = Config.path_for('default')
     File.join(config_root, default_dir, '**', '[0-9][0-9][0-9][0-9]-*.md')
   end
   ```
   to:
   ```ruby
   def self.pattern(config_root = '.')
     config = Config.load(config_root)
     adr_dir = config[type_config[:config_key]] || config['default']
     File.join(config_root, adr_dir, '**', '[0-9][0-9][0-9][0-9]-*.md')
   end
   ```

2. Add `template: 'adr', section_tag: 'adr'` to ADR's `register_type` call in `lib/diataxis/document/adr.rb` (line 8-15).

3. Add `template: 'howto', section_tag: 'howto'` to HowTo's `register_type` call in `lib/diataxis/document/howto.rb` (line 9-16).

4. Add `template:` and `section_tag:` to all 7 shell class `register_type` calls. Read each file, add the two keys with the correct values.

5. Run `bundle exec rspec` and `bundle exec cucumber` to verify all tests pass. The ADR pattern fix may change behavior in tests that use custom ADR config directories — verify carefully.

## Must-Haves

- [ ] ADR's `pattern` method uses `Config.load(config_root)` instead of `Config.path_for('default')`
- [ ] ADR's `register_type` includes `template: 'adr', section_tag: 'adr'`
- [ ] HowTo's `register_type` includes `template: 'howto', section_tag: 'howto'`
- [ ] All 7 shell classes have `template:` and `section_tag:` in their `register_type` calls
- [ ] All tests pass

## Verification

- `bundle exec rspec` — all examples pass
- `bundle exec cucumber` — all scenarios pass
- `grep -l 'template:' lib/diataxis/document/*.rb | wc -l` returns 9 (all document subclass files have template: key)
- `grep 'Config.path_for' lib/diataxis/document/adr.rb` returns no output (bug fixed)

## Inputs

- `lib/diataxis/document/adr.rb` — ADR class to fix and update
- `lib/diataxis/document/howto.rb` — HowTo class to update
- `lib/diataxis/document/explanation.rb` — shell class to update
- `lib/diataxis/document/tutorial.rb` — shell class to update
- `lib/diataxis/document/handover.rb` — shell class to update
- `lib/diataxis/document/five_why_analysis.rb` — shell class to update
- `lib/diataxis/document/note.rb` — shell class to update
- `lib/diataxis/document/project.rb` — shell class to update
- `lib/diataxis/document/pr.rb` — shell class to update

## Expected Output

- `lib/diataxis/document/adr.rb` — pattern bug fixed, template:/section_tag: added to register_type
- `lib/diataxis/document/howto.rb` — template:/section_tag: added to register_type
- `lib/diataxis/document/explanation.rb` — template:/section_tag: added
- `lib/diataxis/document/tutorial.rb` — template:/section_tag: added
- `lib/diataxis/document/handover.rb` — template:/section_tag: added
- `lib/diataxis/document/five_why_analysis.rb` — template:/section_tag: added
- `lib/diataxis/document/note.rb` — template:/section_tag: added
- `lib/diataxis/document/project.rb` — template:/section_tag: added
- `lib/diataxis/document/pr.rb` — template:/section_tag: added
  - Files: `lib/diataxis/document/adr.rb`, `lib/diataxis/document/howto.rb`, `lib/diataxis/document/explanation.rb`, `lib/diataxis/document/tutorial.rb`, `lib/diataxis/document/handover.rb`, `lib/diataxis/document/five_why_analysis.rb`, `lib/diataxis/document/note.rb`, `lib/diataxis/document/project.rb`, `lib/diataxis/document/pr.rb`
  - Verify: bundle exec rspec && bundle exec cucumber && test $(grep -l 'template:' lib/diataxis/document/*.rb | wc -l | tr -d ' ') -eq 9 && ! grep -q 'Config.path_for' lib/diataxis/document/adr.rb

- [x] **T04: Wire document_types.rb, delete 7 shell classes, update tests, and verify behavioral equivalence** `est:1h`
  ---
estimated_steps: 8
estimated_files: 11
skills_used:
  - verify-before-complete
  - test
---

# T04: Wire document_types.rb, delete 7 shell classes, update tests, and verify behavioral equivalence

**Slice:** S02 — Registry DSL and template method pattern
**Milestone:** M001-3b7cia

## Description

This is the integration task where the refactor comes together. Wire `document_types.rb` into `diataxis.rb`, delete the 7 empty shell class files, update test files that reference deleted classes, and verify full behavioral equivalence.

This is the riskiest task because it makes the atomic switch: the old registration path (shell classes calling `register_type`) is replaced by the new path (`document_types.rb` configure block). Double registration must be avoided.

### Key changes to diataxis.rb

Current requires (lines 7-15):
```ruby
require_relative 'document/howto'
require_relative 'document/explanation'
require_relative 'document/tutorial'
require_relative 'document/adr'
require_relative 'document/handover'
require_relative 'document/five_why_analysis'
require_relative 'document/note'
require_relative 'document/project'
require_relative 'document/pr'
```

New requires:
```ruby
require_relative 'document/adr'
require_relative 'document/howto'
require_relative 'document_types'
```

ADR and HowTo must be required BEFORE document_types.rb because the registry references them as handler classes.

### Shell class deletion

Delete these 7 files:
- `lib/diataxis/document/explanation.rb`
- `lib/diataxis/document/tutorial.rb`
- `lib/diataxis/document/handover.rb`
- `lib/diataxis/document/five_why_analysis.rb`
- `lib/diataxis/document/note.rb`
- `lib/diataxis/document/project.rb`
- `lib/diataxis/document/pr.rb`

### Test updates

`spec/template_loader_spec.rb` references `Diataxis::Explanation`, `Diataxis::Handover`, and `Diataxis::ADR` by class constant name. After deletion:
- `Diataxis::Explanation` no longer exists as a named constant — it's an anonymous subclass in the registry. Tests that use `Diataxis::Explanation` must switch to `Diataxis::DocumentRegistry.lookup('explanation')`.
- `Diataxis::Handover` — same treatment.
- `Diataxis::ADR` — still exists as a named class, no change needed.

Specific test lines to update:
- Line 29: `described_class.load_template(Diataxis::Explanation, 'Test Topic')` → `described_class.load_template(Diataxis::DocumentRegistry.lookup('explanation'), 'Test Topic')`
- Line 41: Same pattern for Explanation
- Line 70: Same pattern for Explanation
- Line 82: `Diataxis::CLI.run(['explanation', 'new', 'Test Topic'])` — this uses CLI which looks up by command name, so it should work unchanged. But verify.
- Line 102: `Diataxis::CLI.run(['handover', 'new', 'Server Migration'])` — same, CLI lookup, should work unchanged.

Also check `spec/diataxis_spec.rb` for any class constant references to deleted types.

### Behavioral equivalence smoke test

After wiring, create a temp directory and run:
```ruby
require_relative 'lib/diataxis'
Diataxis::DocumentRegistry.command_names.sort.each do |cmd|
  puts "#{cmd}: #{Diataxis::DocumentRegistry.lookup(cmd).type_config[:template]}"
end
```
All 9 commands should be registered with correct template names.

Then create one document of each simple type and verify the output file exists with correct content structure.

## Steps

1. Update `lib/diataxis/diataxis.rb`: Replace the 9 require_relative lines (7-15) with 3 lines:
   ```ruby
   require_relative 'document/adr'
   require_relative 'document/howto'
   require_relative 'document_types'
   ```
   Keep all other requires unchanged.

2. Verify `lib/diataxis/document_types.rb` (created in T02) properly registers all 9 types. The `configure` block must NOT call `register_type` on ADR or HowTo again if they already self-register in their class files. Check: do `adr.rb` and `howto.rb` call `register_type` in their class bodies? YES they do (lines 8-15 in both files). So `document_types.rb` must either:
   - Skip registering ADR and HowTo (they self-register when required), OR
   - Clear the registry before the configure block and re-register everything including ADR/HowTo
   
   The cleanest approach: add a `DocumentRegistry.clear` method, call it at the start of `configure`, then register all 9 types. ADR and HowTo's `register_type` calls in their class files will have already run (they're required before document_types.rb), but `configure` clears and re-registers with the full config including template:/section_tag:. This also means the `template:` and `section_tag:` added to shell class register_type calls in T03 are moot — but they were useful as an intermediate safety net.

   Actually simpler: `document_types.rb` should only register the 7 simple types. ADR and HowTo already self-register in their class files (with template:/section_tag: added in T03). No clearing needed, no double registration. The configure block creates anonymous subclasses only for the 7 simple types.

3. Delete the 7 shell class files: `rm lib/diataxis/document/explanation.rb lib/diataxis/document/tutorial.rb lib/diataxis/document/handover.rb lib/diataxis/document/five_why_analysis.rb lib/diataxis/document/note.rb lib/diataxis/document/project.rb lib/diataxis/document/pr.rb`

4. Update `spec/template_loader_spec.rb`:
   - Line 29: Replace `Diataxis::Explanation` with `Diataxis::DocumentRegistry.lookup('explanation')`
   - Line 41: Same replacement
   - Line 70: Same replacement
   - Verify lines 82 and 102 (CLI.run calls) work without changes

5. Check `spec/diataxis_spec.rb` for references to deleted class names and update if needed.

6. Run `bundle exec rspec` — all tests must pass.

7. Run `bundle exec cucumber` — all scenarios must pass.

8. Verify:
   - `ls lib/diataxis/document/` shows only `adr.rb` and `howto.rb`
   - `ruby -e "require_relative 'lib/diataxis'; puts Diataxis::DocumentRegistry.command_names.sort.join(', ')"` prints all 9 commands
   - `ruby -e "require_relative 'lib/diataxis'; Diataxis::DocumentRegistry.all.each { |c| puts c.type_config[:template] }"` prints 9 template names

## Must-Haves

- [ ] `diataxis.rb` requires only adr.rb, howto.rb, and document_types.rb (not the 7 shell classes)
- [ ] 7 shell class files deleted from lib/diataxis/document/
- [ ] `spec/template_loader_spec.rb` updated to use registry lookup instead of deleted class constants
- [ ] All 9 document types registered and functional via `DocumentRegistry`
- [ ] `bundle exec rspec` passes with 0 failures
- [ ] `bundle exec cucumber` passes with 0 failures
- [ ] README section tags preserved exactly (no existing README sections broken)

## Failure Modes

| Dependency | On error | On timeout | On malformed response |
|------------|----------|-----------|----------------------|
| document_types.rb configure block | Registration fails — check error message for missing handler class or duplicate command | N/A | N/A |
| Deleted class references in tests | NameError: uninitialized constant — update test to use registry lookup | N/A | N/A |

## Verification

- `bundle exec rspec` — all examples pass, 0 failures
- `bundle exec cucumber` — 6 scenarios, 39 steps, all passing
- `ls lib/diataxis/document/ | sort` — outputs exactly `adr.rb` and `howto.rb`
- `ruby -e "require_relative 'lib/diataxis'; names = Diataxis::DocumentRegistry.command_names.sort; puts names.length; puts names.join(',')"` — prints 9 and all command names
- `ruby -e "require_relative 'lib/diataxis'; Diataxis::DocumentRegistry.all.each { |c| t = c.type_config[:template]; raise 'nil template' unless t; puts t }"` — prints 9 template names, no nil

## Inputs

- `lib/diataxis/diataxis.rb` — main require file to rewire
- `lib/diataxis/document_types.rb` — T02 output, registry DSL file to wire in
- `lib/diataxis/document/adr.rb` — T03 output, kept as handler class
- `lib/diataxis/document/howto.rb` — T03 output, kept as handler class
- `lib/diataxis/document/explanation.rb` — T03 output, to be deleted
- `lib/diataxis/document/tutorial.rb` — T03 output, to be deleted
- `lib/diataxis/document/handover.rb` — T03 output, to be deleted
- `lib/diataxis/document/five_why_analysis.rb` — T03 output, to be deleted
- `lib/diataxis/document/note.rb` — T03 output, to be deleted
- `lib/diataxis/document/project.rb` — T03 output, to be deleted
- `lib/diataxis/document/pr.rb` — T03 output, to be deleted
- `spec/template_loader_spec.rb` — test file referencing deleted class constants
- `spec/diataxis_spec.rb` — test file to check for deleted class references

## Expected Output

- `lib/diataxis/diataxis.rb` — modified: requires only adr.rb, howto.rb, document_types.rb
- `lib/diataxis/document/explanation.rb` — deleted
- `lib/diataxis/document/tutorial.rb` — deleted
- `lib/diataxis/document/handover.rb` — deleted
- `lib/diataxis/document/five_why_analysis.rb` — deleted
- `lib/diataxis/document/note.rb` — deleted
- `lib/diataxis/document/project.rb` — deleted
- `lib/diataxis/document/pr.rb` — deleted
- `spec/template_loader_spec.rb` — modified: uses registry lookup instead of deleted class constants
  - Files: `lib/diataxis/diataxis.rb`, `lib/diataxis/document_types.rb`, `lib/diataxis/document/explanation.rb`, `lib/diataxis/document/tutorial.rb`, `lib/diataxis/document/handover.rb`, `lib/diataxis/document/five_why_analysis.rb`, `lib/diataxis/document/note.rb`, `lib/diataxis/document/project.rb`, `lib/diataxis/document/pr.rb`, `spec/template_loader_spec.rb`, `spec/diataxis_spec.rb`
  - Verify: bundle exec rspec && bundle exec cucumber && test $(ls lib/diataxis/document/ | wc -l | tr -d ' ') -eq 2 && ruby -e "require_relative 'lib/diataxis'; raise 'wrong count' unless Diataxis::DocumentRegistry.command_names.length == 9"

## Files Likely Touched

- lib/diataxis/document.rb
- lib/diataxis/template_loader.rb
- lib/diataxis/readme_manager.rb
- lib/diataxis/document_types.rb
- lib/diataxis/document/adr.rb
- lib/diataxis/document/howto.rb
- lib/diataxis/document/explanation.rb
- lib/diataxis/document/tutorial.rb
- lib/diataxis/document/handover.rb
- lib/diataxis/document/five_why_analysis.rb
- lib/diataxis/document/note.rb
- lib/diataxis/document/project.rb
- lib/diataxis/document/pr.rb
- lib/diataxis/diataxis.rb
- spec/template_loader_spec.rb
- spec/diataxis_spec.rb
