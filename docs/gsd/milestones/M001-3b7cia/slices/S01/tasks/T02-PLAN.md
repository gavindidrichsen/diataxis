---
estimated_steps: 62
estimated_files: 5
skills_used: []
---

# T02: Update 5 templates to use {{common.metadata}} with section-header structure

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

## Inputs

- `templates/common.metadata`
- `lib/diataxis/template_loader.rb`
- `templates/explanations/explanation.md`
- `templates/tutorials/tutorial.md`
- `templates/how-tos/howto.md`
- `templates/explanations/pr.md`
- `templates/references/handover.md`

## Expected Output

- `templates/explanations/explanation.md`
- `templates/tutorials/tutorial.md`
- `templates/how-tos/howto.md`
- `templates/explanations/pr.md`
- `templates/references/handover.md`

## Verification

bundle exec rspec && bundle exec cucumber
