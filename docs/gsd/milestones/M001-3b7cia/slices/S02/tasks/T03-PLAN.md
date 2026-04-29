---
estimated_steps: 80
estimated_files: 9
skills_used: []
---

# T03: Migrate ADR and HowTo custom behavior to template method hooks and fix ADR pattern bug

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

## Inputs

- ``lib/diataxis/document/adr.rb` — ADR class with pattern bug to fix`
- ``lib/diataxis/document/howto.rb` — HowTo class to update`
- ``lib/diataxis/document/explanation.rb` — shell class to update`
- ``lib/diataxis/document/tutorial.rb` — shell class to update`
- ``lib/diataxis/document/handover.rb` — shell class to update`
- ``lib/diataxis/document/five_why_analysis.rb` — shell class to update`
- ``lib/diataxis/document/note.rb` — shell class to update`
- ``lib/diataxis/document/project.rb` — shell class to update`
- ``lib/diataxis/document/pr.rb` — shell class to update`

## Expected Output

- ``lib/diataxis/document/adr.rb` — pattern bug fixed, template:/section_tag: added`
- ``lib/diataxis/document/howto.rb` — template:/section_tag: added`
- ``lib/diataxis/document/explanation.rb` — template:/section_tag: added`
- ``lib/diataxis/document/tutorial.rb` — template:/section_tag: added`
- ``lib/diataxis/document/handover.rb` — template:/section_tag: added`
- ``lib/diataxis/document/five_why_analysis.rb` — template:/section_tag: added`
- ``lib/diataxis/document/note.rb` — template:/section_tag: added`
- ``lib/diataxis/document/project.rb` — template:/section_tag: added`
- ``lib/diataxis/document/pr.rb` — template:/section_tag: added`

## Verification

bundle exec rspec && bundle exec cucumber && test $(grep -l 'template:' lib/diataxis/document/*.rb | wc -l | tr -d ' ') -eq 9 && ! grep -q 'Config.path_for' lib/diataxis/document/adr.rb
