---
estimated_steps: 42
estimated_files: 1
skills_used: []
---

# T01: Add template method hooks to Document base class

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

## Inputs

- ``lib/diataxis/document.rb` — base Document class, current implementation to extend`

## Expected Output

- ``lib/diataxis/document.rb` — modified with 4 template method hooks (customize_title, customize_filename, customize_content, customize_readme_entry) wired into existing methods`

## Verification

bundle exec rspec && bundle exec cucumber && test $(grep -c 'def customize_' lib/diataxis/document.rb) -eq 4
