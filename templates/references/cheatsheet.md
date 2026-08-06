<!--
# Common Guidelines
{{common.metadata}}

**Purpose:** Operational "glance-and-go" reference. Holds ALL commands for the tool/topic.
The reader is mid-task and scanning for the right command — not learning, not reading for context.

**What belongs here:**
- Commands, flags, and YAML/config snippets with short inline comments.
- Tables for option/flag/value lookup grids.
- One-liner "Gotchas" for non-obvious behaviour that bites people at the command line.
- Callout links to explanation or how-to docs for anything that needs more than one line of prose.
- **Any script that the cheatsheet's commands invoke.** A cheatsheet is a manual-run reference, so it must be self-contained: if a command reads `bolt script run scripts/foo.ps1`, the body of `foo.ps1` MUST appear inside the cheatsheet — either inline in the section that invokes it, or in a `## Scripts` appendix at the bottom for anything longer than ~20 lines. A cheatsheet that points at an external script file the reader has to open separately has failed the glance-and-go test.

**What does NOT belong here:**
- Multi-paragraph explanations — link to an explanation doc instead.
- Step-by-step procedures — link to a how-to doc instead.
- Architecture or design rationale — link to an explanation doc instead.
- The *why* behind a command, or *how* to choose between alternatives — that's explanation-doc territory. Cheatsheets carry the *what*; explanation docs carry the *why* and *how*.

**Format rules (strict):**
- H1 body placeholder is `# {{title}}` — when populating, keep the title a **plain domain-first noun phrase** (e.g. `# PDK Windows Steel-Thread Explore-Phase Commands`). **Do NOT append the word "Cheatsheet" to the H1.** The `cheatsheet_` filename prefix already signals the doc's type; adding "Cheatsheet" to the H1 also has the side effect of causing `dia update` to slugify the trailing word into the filename (`..._commands_cheatsheet.md` instead of `..._commands.md`), which produces the awkward double-cheatsheet stem you're trying to avoid.
- One-sentence subtitle immediately below H1 — the "what this tool does in a nutshell".
- Section order: Quick Reference table → topic H2 sections → `## Gotchas` → (optional `## Scripts` appendix) → `## Related Topics`.
- H2: topic areas (e.g. Setup, Configuration, Common Patterns). H3 for sub-areas within a long section.
- Code blocks: annotate with short inline `#` comments — not paragraphs above or below.
- Tables: use for any option/key/value reference that has 3+ rows (flags, profiles, operation/meaning combos).
- No numbered lists — bullets only, for easy reordering.
- Keep prose to a single lead line per section at most; anything longer belongs in a linked explanation doc.

**Self-contained code rule (strict):**
- The cheatsheet is the reader's single-page reference for running the topic manually. Every script, snippet, or file referenced by name in a command MUST have its body reproduced somewhere in this same document.
- Small scripts (≤ ~20 lines): inline the body directly under the command that invokes it, in a fenced code block whose first line is a `# filename.ext` comment.
- Larger scripts: place them in a `## Scripts` H2 appendix at the bottom (before `## Related Topics`). Each script gets an H3 named after the filename, followed by a fenced code block containing the full file contents.
- The Quick Reference table's script-invocation entries should point at the appendix section they're mirrored in — e.g. `bolt script run scripts/02-download-pdk-msi.ps1 ...` in the table, with a `↓` reference or wiki-anchor to `## Scripts → 02-download-pdk-msi.ps1` below.
- Rationale — *why* the script exists, *how* it was derived, *when* it should evolve — does NOT belong in the cheatsheet; that goes in a linked `dia explanation new` doc.

**Linking rules:**
- Add `> 📖 **Deeper dive:** [[explanation_...]]` as a one-line callout above any section
  where a vault explanation doc exists. One line only — do not describe the doc inline.
- Related Topics at the bottom: Obsidian wiki-links `[[filename]]` for vault docs,
  plain markdown links for external URLs. No placeholder bullets — omit rather than fake.

**Placeholder rules:**
- Replace every `{{placeholder}}` with topic-specific text before finishing.
- Replace generic section headings (`## Section One`) with real topic names.
- Remove any section that has no content for this topic.

**Final check:**
- H1 is a plain domain-first noun phrase, **without** a trailing "Cheatsheet" word.
- Every script referenced from a Quick Reference row or a topic section has its body reproduced inline or in the `## Scripts` appendix — no bare `bolt script run scripts/foo.ps1` invocations that the reader must chase to disk.
- Every section has at least one command, snippet, or table row.
- No `{{placeholder}}` text remains.
- No placeholder bullets in Related Topics.
- Prose kept to one-liners; longer explanations live in linked docs.

**Usage with `dia`:**
- Run `dia cheatsheet new "<tool-name>"` — pass the tool name ONLY, without "Cheatsheet".
  The `cheatsheet_` prefix is added to the filename automatically by `dia update`.
  Passing "pdk-templates Cheatsheet" instead of "pdk-templates" produces the double-prefixed
  filename `cheatsheet_pdk_templates_cheatsheet.md`.
- Once scaffolded, **leave the H1 as a plain domain noun phrase** — do NOT append "Cheatsheet" to the H1. `dia update` slugifies the H1 into the filename, so a "Cheatsheet"-suffixed H1 produces `cheatsheet_..._cheatsheet.md`, and the double stem serves no purpose.
-->

# {{title}}

{{one_sentence_description}}.

## Quick Reference

| Task | Command / Pattern |
|---|---|
| {{task_1}} | `{{command_1}}` |
| {{task_2}} | `{{command_2}}` |
| {{task_3}} | `{{command_3}}` |

## {{Section One}}

> 📖 **Deeper dive:** [[{{explanation_doc_filename}}]]

```bash
command --flag arg   # what it does
command --flag arg2  # what it does
```

## {{Section Two}}

```bash
command arg          # what it does
```

## Gotchas

- **{{Gotcha title}}** — one-line explanation of the non-obvious behaviour.
- **{{Gotcha title}}** — one-line explanation of the non-obvious behaviour.

## Related Topics

- [[{{related-vault-doc}}]] — one-line description
