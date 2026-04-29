<!--
GTD Philosophy Overview

Getting Things Done (GTD) is a productivity methodology by David Allen designed to reduce
stress and improve clarity by organizing tasks and commitments into actionable lists.

Core Principles:

1. Capture Everything
   Collect all tasks, ideas, and commitments into a trusted system so nothing stays in your head.

2. Clarify & Organize
   Decide what each item means and where it belongs:
   - Is it actionable?
   - If yes, what's the Next Action?
   - If no, trash it, incubate it, or file it as reference.

3. Next Action Thinking
   Break projects into the very next physical, visible step you can take to move it forward.
   Example: Instead of "Plan website redesign," write "Email designer to schedule kickoff."

4. Project Definition
   A project in GTD is any outcome requiring more than one action. Define:
   - Purpose (Why this matters)
   - Desired Outcome (What "done" looks like)
   - Next Actions (What to do now)

5. Contextual Lists
   Organize actions by context or state:
   - @waiting – tasks dependent on others
   - @backlog – deferred tasks
   - @someday – ideas for the future

6. Review Regularly
   Weekly review ensures clarity and trust in your system.
-->

# Project: Fixing the dia update filename-doubling bug when titles already contain the document-type prefix

**@urgent** tasks:

- [ ] Add prefix-stripping logic to `generate_filename_from_file` in `lib/diataxis/document.rb` (line 46)
- [ ] Add matching logic to `generate_filename` in `lib/diataxis/document.rb` (line 134)
- [ ] Add regression tests for all document types with prefix-containing titles
- [ ] Verify fix with `dia update .` on a directory containing existing correctly-named files

## Context

Running `dia update .` doubles the document-type prefix on filenames that already contain their type word in the title. For example, a file titled "Project: Fixing foo" with type `project` gets renamed from `project_fixing_foo.md` to `project_project_fixing_foo.md`.

This is a live, easily reproducible bug — it triggered during a routine `dia update .` on the `diataxis` repo's own `docs/_gtd/` directory, doubling every `project_` prefix.

**Related GitHub issue**: https://github.com/gavindidrichsen/diataxis/issues/31

## Bug Location

The root cause is in [`lib/diataxis/document.rb`](../../lib/diataxis/document.rb), specifically in two methods:

### Method 1: `generate_filename_from_file` (lines 36-48)

```ruby
def generate_filename_from_file(filepath)
  title = MarkdownUtils.extract_title(filepath)
  return nil if title.nil?

  clean_title = if type_config[:title_prefix]
                  title.sub(/^#{Regexp.escape(type_config[:title_prefix])}\s+/i, '')
                else
                  title  # <-- BUG: title still contains the type word (e.g., "Project")
                end
  sep = type_config[:slug_separator]
  slug = clean_title.downcase.gsub(/[^a-z0-9]+/, sep).gsub(/^#{Regexp.escape(sep)}|#{Regexp.escape(sep)}$/, '')
  "#{type_config[:prefix]}#{sep}#{slug}.md"  # <-- BUG: prepends prefix again
end
```

### Method 2: `generate_filename` (lines 126-136)

Same pattern — the title prefix is conditionally stripped, but if `type_config[:title_prefix]` is nil (as it is for `project`, `note`, `handover`, and others), the type word remains in the slug and then gets prepended again.

### Why it happens

1. The markdown title is `"Project: Fixing the dia update..."` (extracted by `MarkdownUtils.extract_title`)
2. For the `project` document type, `type_config[:title_prefix]` is `"Project:"` — so the `sub` on line 41 strips it
3. But after slugification, the slug is `"fixing_the_dia_update..."`
4. Line 47 builds: `"project" + "_" + "fixing_the_dia_update..."` = correct
5. **However**, if the title doesn't have the exact `title_prefix` format (e.g., `"Fixing the project..."` where "project" appears mid-title), or if `title_prefix` is nil for that type, the slug retains the type word and gets it prepended again

The real-world trigger: when `dia project new "Fixing the dia update..."` creates a file and then `dia update .` runs, the title `"Project: Fixing the dia update..."` gets the `"Project: "` stripped, slugified to `"fixing_the_dia_update..."`, and prefixed to `"project_fixing_the_dia_update..."`. But for titles like `"Project: Create common style guidelines..."`, the result becomes `"project_create_common_style_guidelines..."` which is correct. The doubling happens when the slug already starts with the prefix word — which occurs when `title_prefix` stripping fails or doesn't apply.

**Concrete reproduction**: the existing files `project_create_common_style_guidelines_for_each_template.md` etc. all got renamed to `project_project_create_common_style_guidelines_for_each_template.md` when `dia update .` ran.

## Proposed Fix

In `generate_filename_from_file` (and `generate_filename`), after building the slug, strip a leading prefix if it matches `type_config[:prefix]`:

```ruby
slug = clean_title.downcase.gsub(/[^a-z0-9]+/, sep).gsub(/^#{Regexp.escape(sep)}|#{Regexp.escape(sep)}$/, '')
# Strip leading prefix to avoid doubling (e.g., "project_fixing..." -> "fixing...")
prefix = type_config[:prefix]
slug = slug.sub(/^#{Regexp.escape(prefix)}#{Regexp.escape(sep)}/, '') if slug.start_with?("#{prefix}#{sep}")
"#{prefix}#{sep}#{slug}.md"
```

## Next Steps

1. Write a failing test that reproduces the doubling for `project`, `note`, and `handover` types
2. Apply the fix to both methods in `document.rb`
3. Run the full test suite
4. Verify manually with `dia update .` on `docs/_gtd/`

## Other Lists

**@backlog** tasks for later:

- [ ] Audit all document types for similar prefix issues
- [ ] Consider whether `title_prefix` should be required for all types to avoid this class of bug
