# S01: Common metadata template injection

**Goal:** Universal formatting rules extracted to templates/common.metadata and injected via {{common.metadata}} placeholder in TemplateLoader. Templates own the HTML comment structure with explicit section headers separating common from type-specific guidelines.
**Demo:** dia new explanation renders with metadata sourced from common.metadata file instead of hardcoded block in the template

## Must-Haves

- ## Must-Haves
- `templates/common.metadata` exists containing only the 6 universal formatting rule bullets (no HTML comment delimiters)
- `TemplateLoader.load_template()` resolves `{{common.metadata}}` placeholder by reading and injecting `templates/common.metadata` content
- Placeholder resolution happens BEFORE `{{title}}` and `{{date}}` substitutions
- All 5 templates with metadata (explanation, tutorial, howto, pr, handover) use `{{common.metadata}}` inside an explicit `<!-- # Common Guidelines ... # Template-Specific Guidelines ... -->` structure
- Templates without metadata (adr, note, fivewhyanalysis, project) remain unchanged
- `diataxis.gemspec` includes `templates/common.metadata` in `spec.files`
- `dia new <type>` produces behaviorally equivalent output for all document types
- Missing `templates/common.metadata` raises a clear `TemplateError`
- ## Requirement Impact
- **Requirements touched**: R001 (common metadata injection), R002 (per-template specifics stay hardcoded)
- **Re-verify**: All `dia new <type>` commands produce equivalent output
- **Decisions revisited**: none
- ## Verification
- `bundle exec rspec` — all existing specs pass
- `bundle exec rspec spec/template_loader_spec.rb` — new TemplateLoader specs pass (placeholder resolution, missing file error, templates-without-placeholder unaffected)
- `bundle exec cucumber` — all existing features pass

## Proof Level

- This slice proves: Not provided.

## Integration Closure

Not provided.

## Verification

- Not provided.

## Tasks

- [x] **T01: Create common.metadata file, extend TemplateLoader, and fix gemspec** `est:30m`
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
  - Files: `lib/diataxis/template_loader.rb`, `templates/common.metadata`, `diataxis.gemspec`
  - Verify: bundle exec rspec && test -f templates/common.metadata && grep -q 'common.metadata' diataxis.gemspec

- [ ] **T02: Update 5 templates to use {{common.metadata}} with section-header structure** `est:45m`
  ## Description

Replace the duplicated Style Guidelines block in all 5 templates that carry metadata with the `{{common.metadata}}` placeholder, using the user's preferred section-header structure inside the HTML comment.

**Target structure for each template:**
```
<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines
[type-specific lines that vary per template]
-->
```

The common block being replaced is the `**Style Guidelines (Strict):**` header and the 6 universal bullets (lines 2-9 in most templates). Lines 10+ in the current templates are type-specific and remain hardcoded after the `# Template-Specific Guidelines` header.

## Steps

1. **Save baseline outputs** — Before editing any templates, generate one document of each type that has metadata and save the output for diffing:
   ```bash
   mkdir -p tmp/baseline
   cd tmp/test_baseline && # create temp dir with .diataxis config
   dia new explanation "Baseline Test" && cp docs/understanding_baseline_test.md ../baseline/
   dia new tutorial "Baseline Test" && cp docs/tutorial_baseline_test.md ../baseline/
   dia new howto "Baseline Test" && cp docs/how_to_baseline_test.md ../baseline/
   dia new pr "Baseline Test" && cp docs/pr_baseline_test.md ../baseline/
   dia new handover "Baseline Test" && cp docs/handover_baseline_test.md ../baseline/
   ```

2. **Edit `templates/explanations/explanation.md`** — Replace lines 1-9 (the `<!--` through the 6 bullets) with:
   ```
   <!--
   # Common Guidelines
   {{common.metadata}}

   # Template-Specific Guidelines
   ```
   Keep lines 10-12 (the type-specific heading bullets) and everything after as-is. The closing `-->` on the original line 55 stays.
   
   Specifically, the type-specific lines that remain after `# Template-Specific Guidelines` are:
   - `- Key concept headings must be concise, descriptive titles (3-7 words).`
   - `- Placeholder headings such as \`### Concept 1\` and \`### Concept 2\` must be replaced with topic-specific titles before completion.`
   - `- Use \`####\` subheadings for troubleshooting subsections instead of bold text with numbers.`
   - Then the `**Purpose Section Requirement:**` block and everything below.

3. **Edit `templates/tutorials/tutorial.md`** — Same pattern as explanation.md. The type-specific lines after the common block are identical to explanation (same heading bullets, same Purpose/Linking/Code Evidence/File Setup/Compliance sections).

4. **Edit `templates/how-tos/howto.md`** — Same pattern. Type-specific lines are identical to explanation/tutorial.

5. **Edit `templates/explanations/pr.md`** — Same replacement of lines 1-9. The type-specific lines differ:
   - `- Change section headings must be concise, descriptive titles (3-7 words).`
   - `- Placeholder headings such as \`### Change 1\` and \`### Change 2\` must be replaced...`
   - `- Use \`####\` subheadings for subsections instead of bold text with numbers.`
   - Then `**Purpose Section Requirement:**` (PR-specific), `**Linking Rules:**` (adds Commits), `**Changes Section Requirement:**`, `**What Did NOT Change:**`, `**Final Compliance Check:**` — all PR-specific.

6. **Edit `templates/references/handover.md`** — Same replacement of lines 1-9. The type-specific lines are:
   - `- Key concept headings must be concise, descriptive titles (3-7 words).`
   - `- Use \`####\` subheadings for troubleshooting subsections instead of bold text with numbers.`
   - Then `**Linking Rules:**` — handover has no Purpose, Code Evidence, File Setup, or Compliance sections.

7. **Verify no changes to templates without metadata** — Confirm `templates/references/adr.md`, `templates/references/note.md`, `templates/references/fivewhyanalysis.md`, and `templates/references/project.md` are untouched.

8. **Generate post-change outputs and diff** — Re-generate the same document types and diff against baselines. The visible content (everything after `-->`) must be identical. The HTML comment block will differ structurally (section headers added) but the injected content must be equivalent.

9. **Run existing test suite** — `bundle exec rspec && bundle exec cucumber` to confirm behavioral equivalence.

## Must-Haves

- [ ] All 5 templates use `{{common.metadata}}` inside `<!-- # Common Guidelines ... # Template-Specific Guidelines ... -->` structure
- [ ] Type-specific lines (lines 10+ in originals) remain hardcoded in each template after `# Template-Specific Guidelines`
- [ ] Templates without metadata (adr, note, fivewhyanalysis, project) are unchanged
- [ ] Generated documents are content-equivalent to pre-change baselines
- [ ] `bundle exec rspec` passes
- [ ] `bundle exec cucumber` passes

## Verification

- `bundle exec rspec` — all existing specs pass
- `bundle exec cucumber` — all features pass
- Diff of generated documents before/after shows equivalent visible content
  - Files: `templates/explanations/explanation.md`, `templates/tutorials/tutorial.md`, `templates/how-tos/howto.md`, `templates/explanations/pr.md`, `templates/references/handover.md`
  - Verify: bundle exec rspec && bundle exec cucumber

- [ ] **T03: Add TemplateLoader unit tests for placeholder resolution** `est:30m`
  ## Description

Add a new spec file `spec/template_loader_spec.rb` with focused unit tests for the `{{common.metadata}}` placeholder resolution in `TemplateLoader.load_template()`.

## Steps

1. Create `spec/template_loader_spec.rb` with these test cases:

   a. **Resolves `{{common.metadata}}` placeholder** — Call `TemplateLoader.load_template()` with a document class whose template contains `{{common.metadata}}`. Verify the returned content includes the Style Guidelines bullets from `templates/common.metadata` and does NOT contain the literal string `{{common.metadata}}`.

   b. **Resolves placeholder before title/date** — Verify that if `common.metadata` hypothetically contained `{{title}}`, it would NOT be double-substituted. (Defensive test — current content doesn't have this, but ordering matters.)

   c. **Templates without placeholder work unchanged** — Call `TemplateLoader.load_template()` with a document class whose template does NOT contain `{{common.metadata}}` (e.g., ADR). Verify it returns the expected content without error.

   d. **Missing common.metadata raises TemplateError** — Temporarily stub `File.exist?` or rename the file, then call `load_template` with a template that contains the placeholder. Verify it raises `Diataxis::TemplateError` with a message mentioning "common.metadata".

   e. **Behavioral equivalence for explanation** — Generate an explanation document via `Diataxis::CLI.run(['explanation', 'new', 'Test Topic'])` and verify the output contains the Style Guidelines content AND the type-specific metadata (Purpose Section Requirement, etc.) AND the template body sections (Purpose, Background, Key Concepts).

   f. **Behavioral equivalence for handover** — Same pattern, verify handover output contains Style Guidelines + Linking Rules + template body (Problem Summary, What Do We Know, etc.).

2. Use the existing test patterns from `spec/diataxis_spec.rb`: `test_dir` with `tmp/test`, `Dir.chdir(test_dir)`, `.diataxis` config setup in `before` block, cleanup in `after` block.

3. Run `bundle exec rspec spec/template_loader_spec.rb` to verify all tests pass.

4. Run `bundle exec rspec` to verify no regressions.

## Must-Haves

- [ ] `spec/template_loader_spec.rb` exists with tests for: placeholder resolution, ordering, no-placeholder templates, missing file error, behavioral equivalence for at least 2 template types
- [ ] All new tests pass
- [ ] All existing tests still pass

## Verification

- `bundle exec rspec spec/template_loader_spec.rb` — all new specs pass
- `bundle exec rspec` — full suite passes
- `bundle exec cucumber` — all features pass
  - Files: `spec/template_loader_spec.rb`
  - Verify: bundle exec rspec spec/template_loader_spec.rb && bundle exec rspec && bundle exec cucumber

## Files Likely Touched

- lib/diataxis/template_loader.rb
- templates/common.metadata
- diataxis.gemspec
- templates/explanations/explanation.md
- templates/tutorials/tutorial.md
- templates/how-tos/howto.md
- templates/explanations/pr.md
- templates/references/handover.md
- spec/template_loader_spec.rb
