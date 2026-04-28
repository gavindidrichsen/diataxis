# S01 — Common metadata template injection — Research

**Date:** 2026-04-28

## Summary

The diataxis gem has 9 template files across 4 category subdirectories. Five of them (explanation, tutorial, howto, pr, handover) carry HTML comment metadata blocks at the top; four (adr, note, fivewhyanalysis, project) do not. Among the five that have metadata, the first 12 lines (Style Guidelines) are nearly identical — only minor wording varies per type (e.g., "Key concept" vs "Change section" headings). Lines 14–55 diverge more: explanation/tutorial/howto share Purpose, Linking Rules, Code Evidence, File Setup, and Final Compliance sections identically, while pr.md has PR-specific variations (Changes Section, reviewer framing) and handover.md carries only Style Guidelines + Linking Rules (18 lines total).

The CONTEXT doc describes ~9 lines of truly universal formatting rules. After line-by-line comparison, the actual universal block is lines 1–12: the Style Guidelines (Strict) section. These 12 lines are identical or near-identical across all 5 templates that carry metadata. Everything after line 12 is type-specific — Linking Rules have slight variations (pr adds Commits links), Code Evidence has reviewer vs learner framing in pr, and File Setup only applies to how-to-style templates.

The implementation is straightforward: create `templates/common.metadata` with the universal Style Guidelines block, add `{{common.metadata}}` placeholder support to `TemplateLoader.load_template()`, and replace the duplicated block in each template. Templates that currently lack metadata (adr, note, fivewhyanalysis, project) will not include the placeholder.

## Recommendation

**Approach:** Extend `TemplateLoader.load_template()` to resolve `{{common.metadata}}` by reading `templates/common.metadata` and injecting its content. This fits naturally into the existing `.gsub()` placeholder pipeline — add it as a special-case substitution before the `{{title}}`/`{{date}}` replacements.

**Scope the common.metadata content to the 12-line Style Guidelines block** (lines 1–12 of the current shared comment). This is the only truly universal content. The Linking Rules, Code Evidence, File Setup, and Final Compliance sections vary per type and should remain hardcoded in each template.

**Why this boundary:** The Style Guidelines are formatting rules that apply identically regardless of document type. Everything below them carries document-type-specific context (reviewer vs learner framing, section-specific requirements). Extracting more would require parameterization, which was explicitly rejected in D001.

## Implementation Landscape

### Key Files

- `lib/diataxis/template_loader.rb` — The only file that needs code changes. Currently has `load_template()` (lines 8–20) doing `.gsub()` substitutions and `find_template_file()` (lines 22–35) locating templates. The `{{common.metadata}}` resolution should be added as a new substitution step in `load_template()`, reading from a sibling path relative to the template directory.
- `templates/common.metadata` — New file to create. Contains the ~12-line universal Style Guidelines block (the HTML comment opening `<!--`, the Style Guidelines header, 9 bullet points, and a blank line). Does NOT include the closing `-->` — each template's type-specific metadata follows and closes the comment.
- `templates/explanations/explanation.md` — Lines 1–12 replaced with `{{common.metadata}}`. Lines 13–55 (Purpose, Linking, Code Evidence, File Setup, Compliance) remain.
- `templates/tutorials/tutorial.md` — Same pattern as explanation.md.
- `templates/how-tos/howto.md` — Same pattern as explanation.md.
- `templates/explanations/pr.md` — Lines 1–12 replaced with `{{common.metadata}}`. Lines 10–12 have slight wording variations ("Change section headings" vs "Key concept headings") that need to be checked — if PR's line 10 differs, it stays hardcoded in pr.md after the placeholder, or the common block uses the more general wording.
- `templates/references/handover.md` — Lines 1–11 replaced with `{{common.metadata}}`. Line 11 in handover is the last shared line before its shorter Linking Rules section.
- `templates/references/adr.md` — No changes (no metadata block currently).
- `templates/references/note.md` — No changes (no metadata block currently).
- `templates/references/fivewhyanalysis.md` — No changes (no metadata block currently).
- `templates/references/project.md` — No changes (has its own GTD-specific metadata, not overlapping).

### Detailed Line Comparison

Templates with the full 55-line metadata block (explanation, tutorial, howto) share these sections identically:
1. **Style Guidelines (lines 1–12)** — UNIVERSAL, extract to common.metadata
2. **Purpose Section Requirement (lines 14–16)** — TYPE-SPECIFIC (wording varies by type)
3. **Linking Rules (lines 18–22)** — NEARLY identical but pr adds Commits
4. **Code Evidence (lines 24–38)** — NEARLY identical but pr reframes for reviewer
5. **File Setup (lines 40–46)** — Same across explanation/tutorial/howto, absent in pr
6. **Final Compliance (lines 48–55)** — Nearly identical, pr adds PR-specific checks

pr.md variations from the canonical block:
- Line 10: "Change section headings" instead of "Key concept headings"
- Line 11: "Change 1"/"Change 2" instead of "Concept 1"/"Concept 2"
- Line 12: "subsections" without "troubleshooting" qualifier
- Lines 17: adds reviewer perspective framing
- Lines 19–24: Linking adds Commits link type
- Lines 26–44: Changes Section replaces Code Evidence, reframed for reviewer
- Lines 46–49: What Did NOT Change section (unique to pr)
- Lines 51–58: Final Compliance has PR-specific checks

handover.md has only 18 lines of metadata (Style Guidelines + Linking Rules), missing Code Evidence, File Setup, and Final Compliance entirely.

### Build Order

1. **Create `templates/common.metadata`** — Extract lines 1–12 from explanation.md. This is the foundation everything else depends on.
2. **Extend `TemplateLoader.load_template()`** — Add `{{common.metadata}}` resolution. Read the common.metadata file from `{gem_root}/templates/common.metadata` and gsub the placeholder. Add error handling for missing file.
3. **Update templates** — Replace duplicated lines 1–12 in each template with `{{common.metadata}}`. Do explanation.md first as the canonical case, verify output matches, then do the rest.
4. **Verify** — Run existing specs and Cucumber features to confirm output is unchanged.

### Verification Approach

- **Unit test:** `TemplateLoader.load_template()` resolves `{{common.metadata}}` when present in a template.
- **Behavioral equivalence:** Run `dia new explanation "Test Topic"` before and after, diff the output files — they must be identical.
- **Negative case:** Templates without `{{common.metadata}}` (adr, note, fivewhyanalysis, project) continue to work unchanged.
- **Error case:** Missing `templates/common.metadata` produces a clear error message.
- **Commands:**
  - `bundle exec rspec` — all existing specs pass
  - `bundle exec cucumber` — all existing features pass
  - Manual diff of generated documents before/after for each template type

## Constraints

- `TemplateLoader` uses simple `.gsub()` — no ERB or template engine. The `{{common.metadata}}` substitution must fit this pattern.
- The common.metadata file must be included in the gemspec's `spec.files` so it ships with the gem.
- The `{{common.metadata}}` placeholder must be resolved BEFORE `{{title}}` and `{{date}}` to avoid double-substitution issues if the common metadata ever contained those placeholders (it currently wouldn't, but ordering is defensive).
- Per D001: explicit inclusion beats magic merging — templates that want common metadata include the placeholder; those that don't simply omit it.
- Per D004: narrow scope — only universal formatting rules go in common.metadata.

## Common Pitfalls

- **HTML comment boundary** — The current metadata is inside `<!-- ... -->`. The common.metadata must NOT include the closing `-->` tag since type-specific metadata follows. But it also shouldn't include the opening `<!--` if we want the placeholder to be insertable mid-comment. Decision: common.metadata contains the full opening `<!--\n` + Style Guidelines lines but NOT the closing `-->`. Templates that use the placeholder start with `{{common.metadata}}` (which expands to `<!--\nStyle Guidelines...`) followed by their type-specific sections and the closing `-->`.
- **Trailing whitespace / newlines** — The `.gsub()` replacement is exact string matching. The common.metadata file content must end with the exact whitespace expected so templates render correctly. Use `.strip` or `.chomp` on the read content and add a newline in the template after the placeholder.
- **gemspec files list** — If `templates/common.metadata` isn't in `spec.files`, it won't ship with the gem. Check how other template files are included (likely a glob pattern like `templates/**/*`).

## Open Risks

- The CONTEXT doc references "~9 lines" of universal formatting rules but the actual Style Guidelines block is 12 lines (including the `<!--` opening and blank line). This is a minor discrepancy — the intent (narrow scope, only truly universal rules) is clear regardless of exact line count.
- pr.md's lines 10–12 have slightly different wording from the other templates. If common.metadata uses the explanation/tutorial/howto wording, pr.md needs to override those 3 lines after the placeholder. This is cleanly solvable: pr.md's metadata starts with `{{common.metadata}}` for lines 1–9, then has its own lines 10–12 with PR-specific wording, then continues with PR-specific sections. Alternatively, common.metadata contains only lines 1–9 (the bullets that are truly identical across ALL 5 templates), and lines 10–12 stay in each template. **Recommend: use lines 1–9 as common (the 7 bullets that are identical everywhere), not 1–12.**

Refined common.metadata content (lines that are identical across ALL templates with metadata):
```
<!--
**Style Guidelines (Strict):**

- Treat this document as a template to be filled, not redesigned.
- Replace placeholder text completely; do not leave generic filler.
- Keep wording concise, specific, and scoped to this document's topic.
- Use bulleted lists with `-` instead of numbered lists for easy reordering.
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`).
- Keep headings descriptive so steps can be rearranged without renumbering.
```

That's 9 lines (matching the CONTEXT doc's "~9 lines"). Lines 10–12 vary per type and stay in each template.
