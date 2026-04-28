---
estimated_steps: 42
estimated_files: 3
skills_used: []
---

# T01: Create common.metadata file, extend TemplateLoader, and fix gemspec

## Description

Create the `templates/common.metadata` file with the 6 universal formatting rule bullets, extend `TemplateLoader.load_template()` to resolve the `{{common.metadata}}` placeholder, and ensure the gemspec includes the new file.

**Design (per user feedback):** `common.metadata` contains only raw guideline content — no HTML comment delimiters (`<!--`/`-->`), no section headers. The templates own the full comment wrapper structure. The user's preferred template structure is:
```
<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines
...type-specific metadata...
-->
```

## Steps

1. Create `templates/common.metadata` with these exact 6 bullets (the lines identical across ALL 5 templates that carry metadata):
   ```
   **Style Guidelines (Strict):**

   - Treat this document as a template to be filled, not redesigned.
   - Replace placeholder text completely; do not leave generic filler.
   - Keep wording concise, specific, and scoped to this document's topic.
   - Use bulleted lists with `-` instead of numbered lists for easy reordering.
   - Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`).
   - Keep headings descriptive so steps can be rearranged without renumbering.
   ```
   No trailing newline after the last bullet. No `<!--` or `-->`. No `# Common Guidelines` header — that lives in the template.

2. Extend `TemplateLoader.load_template()` in `lib/diataxis/template_loader.rb`:
   - After reading the template content (line 10) and BEFORE the `{{title}}`/`{{date}}` gsub calls (line 12), add placeholder resolution:
   - If `content` contains `{{common.metadata}}`, locate `templates/common.metadata` relative to `gem_root` (same pattern as `find_template_file` line 27: `File.expand_path('../..', __dir__)`).
   - Read the file content with `.chomp` to strip trailing newline.
   - `gsub('{{common.metadata}}', common_content)`.
   - If the file doesn't exist, raise `TemplateError` with message "Common metadata file not found: templates/common.metadata" and search_paths.
   - If `content` does NOT contain `{{common.metadata}}`, skip (no error — templates like adr/note simply don't use it).

3. Fix `diataxis.gemspec` line 30: the current glob `Dir['templates/*.md']` only matches `.md` files in the templates root directory. Change it to `Dir['templates/**/*']` to include all files in subdirectories AND the new `common.metadata` file. Alternatively, add a separate line: `spec.files += ['templates/common.metadata']`. The `Dir['templates/**/*']` approach is better because `git ls-files` on line 23 already picks up tracked template files in subdirectories — but line 30 was added as a safety net, so broadening the glob is the right fix.

## Must-Haves

- [ ] `templates/common.metadata` exists with exactly the 6 universal bullets plus the `**Style Guidelines (Strict):**` header
- [ ] `TemplateLoader.load_template()` resolves `{{common.metadata}}` before `{{title}}`/`{{date}}`
- [ ] Missing common.metadata raises `TemplateError` with a descriptive message
- [ ] Templates without `{{common.metadata}}` are unaffected (no error)
- [ ] `diataxis.gemspec` `spec.files` includes `templates/common.metadata`

## Verification

- `ruby -e "require_relative 'lib/diataxis'; puts Diataxis::TemplateLoader.methods"` confirms module loads without error
- `bundle exec rspec` — existing specs still pass (no templates changed yet, just loader extended)
- `grep -q 'common.metadata' diataxis.gemspec` — gemspec includes the file
- `test -f templates/common.metadata` — file exists

## Inputs

- `lib/diataxis/template_loader.rb`
- `diataxis.gemspec`
- `lib/diataxis/errors.rb`

## Expected Output

- `templates/common.metadata`
- `lib/diataxis/template_loader.rb`
- `diataxis.gemspec`

## Verification

bundle exec rspec && test -f templates/common.metadata && grep -q 'common.metadata' diataxis.gemspec
