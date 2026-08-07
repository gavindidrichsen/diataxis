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
- **Decision narrative or re-verification write-ups** — "Verified on `<date>`, here's the full transcript / here's what this confirms / here's the decision and why" belongs in the ADR, fivewhy, or explanation doc that owns that decision, not in the cheatsheet. If a command's outcome fed into a decision, link to that doc (`[[0001-title|ADR-0001]]`) — do not paste the transcript, the verdict prose, or the "confirms both halves of X" reasoning here. Each time a cheatsheet entry gets re-verified, the cheatsheet keeps exactly one evidence line (see Evidence Stays Terse below); it does not grow a new paragraph.

**Evidence Stays Terse — link to the proof, don't paste it (this is how a cheatsheet satisfies Evidence Discipline):**

- The common-metadata Evidence Discipline rule is universal, but a cheatsheet satisfies it with a **link**, not a transcript. Its own contract (glance-and-go, one-liner prose) always wins over embedding full proof inline.
- **Verification evidence is one line, always.** `# verified 2026-08-06 on above-repute: 99 KB / 778 lines` — a date, a target, an outcome. Never a fenced block of command output, never a multi-sentence "confirms X and Y" paragraph.
- **If the verification is worth more than one line — a real investigation, a decision, a reconciled disagreement, a multi-step transcript — that write-up belongs in a linked fivewhy/ADR/explanation doc.** Create or update that doc, then point at it from the cheatsheet with a single `> 📖` callout or a one-line `[[doc]]` reference beside the command. The cheatsheet's job is done once the reader can find the full story one click away; it is not the place the story gets told.
- **Re-verifying an existing entry replaces its evidence line; it does not add a new one below it.** A cheatsheet command should carry at most one "last verified" witness at a time — update the date/outcome in place rather than stacking a growing history of past verification attempts.

**Verification Discipline (aim: every command in this cheatsheet has been run at least once against a real target):**

- **The cheatsheet's implicit contract with the reader is "this command works."** A reader scanning a cheatsheet is not reading for context; they are about to *type it into a shell*. An unverified command wastes their time, damages their trust in the file, and — because they cannot tell which command was verified — damages their trust in **every other** command in the same file.
- **Before writing a new entry, run it.** For each new command, one-liner, table row, code block, or claim about a filesystem/process/log state (e.g. "the log lives at X", "tail this file to see Y", "this command outputs Z"): run it against the intended target (or class of target) via the same channel the reader will use (bolt, `nc`, `curl`, local shell, remote SSH), and confirm the observable outcome the cheatsheet will claim — file exists, byte size non-zero, expected substring in output, exit code as expected, PATH resolution finds the binary, etc.
- **Capture the verification evidence inline as a single line** — either as a comment beside the command (`# verified 2026-08-06 on above-repute: 99 KB / 778 lines`) or a one-line follow-up bullet — so a future reader can see the claim is not asserted, it is witnessed. This costs one line and buys the whole file its credibility; see Evidence Stays Terse above if the story behind it grows past one line.
- **When verification is impossible or blocked, STOP and surface the blocker.** Do not silently write an unverified command. Blockers include: no target of the required OS available, target unreachable, credential missing, external URL blocked, tool absent from PATH, dependency uninstalled. In that case: do NOT append the unverified content; surface the specific claim, the verification that would upgrade it, and the specific blocker; ask whether to (a) provision what's needed and verify now, (b) mark the claim `**Inferred, not proven.**` inline in the cheatsheet with the named upgrade path (per Evidence Discipline in the common metadata) — as a single line, not a paragraph — or (c) drop the entry entirely. Wait for a decision. Never route around this with a "safe-looking" default.
- **Retroactive verification obligation on edits.** When editing an existing cheatsheet — even for what looks like a small correction — re-verify any command whose outcome the edit depends on. Do not trust that a command already in the cheatsheet was verified when it was first written. Update its one-line witness in place (see Evidence Stays Terse) rather than appending a new paragraph.
- **The failure mode this rule exists to prevent.** A confident-sounding one-liner about "tail `$env:LOCALAPPDATA\PDK\pdk-debug.log` after `pdk new module`" once landed in a project cheatsheet without being run. There was no such file — PDK on Windows writes no runtime log. The command was structurally plausible, syntactically correct, and completely fictional. The downstream reader wasted diagnostic time chasing a non-existent artefact. This aim is the retrofit for that failure — and applies to every cheatsheet, every entry, every edit.

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
- No verification evidence longer than one line per command — no fenced transcripts, verdict prose, or decision narrative in the body; that lives in a linked fivewhy/ADR/explanation doc and is referenced here with a single link.

**Usage with `dia`:**
- Run `dia cheatsheet new "<tool-name>"` — pass the tool name ONLY, without "Cheatsheet".
  The `cheatsheet_` prefix is added to the filename automatically by `dia update`.
  Passing "pdk-templates Cheatsheet" instead of "pdk-templates" produces the double-prefixed
  filename `cheatsheet_pdk_templates_cheatsheet.md`.
- Once scaffolded, **leave the H1 as a plain domain noun phrase** — do NOT append "Cheatsheet" to the H1. `dia update` slugifies the H1 into the filename, so a "Cheatsheet"-suffixed H1 produces `cheatsheet_..._cheatsheet.md`, and the double stem serves no purpose.
-->

# {{title}}

{{one_sentence_description}}.

<!--
Verification aim (do not delete this comment until every command below is verified):
Every command, one-liner, table row, code block, and filesystem/log/process claim in this
cheatsheet has been run against a real target and its outcome witnessed. If an entry cannot
be verified, either mark it `**Inferred, not proven.**` with a named upgrade path, or drop it.
See Verification Discipline in this template's header comment for the full rule.
-->

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
