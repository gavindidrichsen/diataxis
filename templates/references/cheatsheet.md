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

**What does NOT belong here:**
- Multi-paragraph explanations — link to an explanation doc instead.
- Step-by-step procedures — link to a how-to doc instead.
- Architecture or design rationale — link to an explanation doc instead.

**Format rules (strict):**
- H1: `# {{Tool/Topic}} Cheatsheet` — tool name + "Cheatsheet", nothing else.
- One-sentence subtitle immediately below H1 — the "what this tool does in a nutshell".
- H2: topic areas (e.g. Installation, Configuration, Common Patterns, Gotchas).
- H3: subtopics within an area when a section gets long.
- Code blocks: annotate with short inline `#` comments — not paragraphs above or below.
- Tables: use for any option/key/value reference that has 3+ rows.
- No numbered lists — bullets only, for easy reordering.

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
- H1 ends with "Cheatsheet".
- Every section has at least one command, snippet, or table row.
- No `{{placeholder}}` text remains.
- No placeholder bullets in Related Topics.
- Prose kept to one-liners; longer explanations live in linked docs.

**Usage with `dia`:**
- Run `dia cheatsheet new "<tool-name>"` — pass the tool name ONLY, without "Cheatsheet".
  The `cheatsheet_` prefix is added to the filename automatically by `dia update`.
  Passing "pdk-templates Cheatsheet" instead of "pdk-templates" produces the double-prefixed
  filename `cheatsheet_pdk_templates_cheatsheet.md`.
- After scaffolding, append " Cheatsheet" to the H1 so it reads `# <Tool Name> Cheatsheet`.
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

## Common Patterns

```bash
# Pattern: {{description}}
command

# Pattern: {{description}}
command
```

## Gotchas

- **{{Gotcha title}}** — one-line explanation of the non-obvious behaviour.
- **{{Gotcha title}}** — one-line explanation of the non-obvious behaviour.

## Related Topics

- [[{{related-vault-doc}}]] — one-line description
