<!--
# Common Guidelines
**Orientation — capture the knowledge behind the problem (read this first):**

- This document is almost always written mid-investigation — while fixing a bug, a broken build, or a failing test. **The problem is the lens, not the subject.** Solving it is the author's day-job; it is not what this document is for.
- The document's enduring value is the **domain knowledge that the problem revealed** — how the system (e.g. Bolt, Puppet, Puppet Enterprise) actually works. Make that the centre of gravity.
- Before writing, answer for yourself: *What does this problem and its solution verify about the domain? What is now understood better about how this system behaves, because of this issue?* Let those answers drive the content.
- Keep the triggering problem to a brief motivating context (a sentence or two: "this surfaced while fixing X"). Spend the document on the mental model, mechanism, and transferable insight that outlive the specific incident.
- Litmus test: if the specific problem vanished tomorrow, the document should still be worth reading as an account of how the domain works.

**Style Guidelines (Strict):**

- Treat this document as a template to be filled, not redesigned.
- Replace placeholder text completely; do not leave generic filler.
- Keep wording concise, specific, and scoped to this document's topic.
- Use bulleted lists with `-` instead of numbered lists for easy reordering.
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`).
- Keep headings descriptive so steps can be rearranged without renumbering.

**Heading Rules:**
- All `###` and lower subheadings must be concise, descriptive titles (3-7 words).
- Placeholder headings (e.g., `### Concept 1`, `### Change 1`) must be replaced with topic-specific titles before completion.
- Use `####` subheadings for subsections instead of bold text with numbers.

**Linking Rules:**
- Every reference in Related Topics must be a real link (no placeholder bullets).
- **Code**: Link to GitHub with a **permalink** — a commit-SHA-pinned URL with line numbers, NOT a `blob/main` branch URL: [`filename:line`](https://github.com/org/repo/blob/<commit-sha>/path/file.rb#L123). Use the full 40-char SHA (or at least the abbreviated one). Permalinks are mandatory because branch URLs silently drift to the wrong lines as the file changes; a SHA pin always points at the code as it was when you wrote about it. (On GitHub press `y` to convert a branch URL to a permalink.)
- **Commits**: Link to the actual commit: [`short-sha`](https://github.com/org/repo/commit/full-sha). In PR descriptions, each change section must include a commit link so reviewers can navigate directly to the diff.
- **Docs**: Link to official documentation pages.
- **Local**: Link to local docs with Obsidian-style wiki links: `[[doc-filename]]` or `[[doc-filename|display text]]`. Use the filename without the `.md` extension. Wiki links resolve by filename, so they survive file moves within the vault.

**Code Evidence Requirement (required when code is referenced):**
- For each major section,
  - include BOTH a source link to real code (with line numbers), and a short "Code Sample" block that clarifies intent.
- The "Code Sample" may be:
  - A minimal real excerpt, or
  - A simplified pseudocode version with brief comments.
- The sample must explain behavior, not just repeat syntax.
- Keep samples small and focused (about 5-20 lines).
- Add 1-3 bullets under each sample explaining:
  - what the code is doing,
  - why it matters in this document,
  - and any important caveat/assumption.
- Never fabricate APIs or behavior; if code cannot be verified, explicitly state that and omit the sample.

**Diagrams (use Mermaid where it earns its place):**
- Reach for a Mermaid diagram when a picture explains structure or flow faster than prose would — for example: how components fit together, a sequence of steps or messages, a state transition, or a before/after of a change.
- Do NOT add a diagram just to have one. If the prose is already clear, or the relationship is trivial (two or three linear steps), skip it — a needless diagram is worse than none.
- Prefer one focused diagram over a single sprawling one; split distinct ideas into separate diagrams. If a diagram would otherwise grow wide (many parallel subgraphs/branches, or several loosely-related stages), first check whether splitting it into two or more smaller diagrams reads more clearly than one large one — prefer that split over cramming everything into a single diagram.
- Use a fenced ` ```mermaid ` block. Keep node labels short and the diagram readable without zooming.
- **Orient top-to-bottom for flowcharts and state diagrams**: use `flowchart TD` (or `TB`) and `stateDiagram-v2` default direction, not `flowchart LR`. Rendered width grows with the diagram in a top-to-bottom layout, so the reader scrolls vertically (natural) instead of horizontally (requires scrolling the page sideways, which most viewers handle poorly). Only use `LR` when the content is inherently a short horizontal sequence (2-4 nodes) that reads awkwardly stacked vertically — a rare exception, not the default. This does NOT apply to `sequenceDiagram` — participants are naturally laid out left-to-right with time flowing down, so that convention stays as-is.
- If a flowchart has several parallel branches (e.g. multiple subgraphs or sibling paths), stack them as sequential top-to-bottom sections rather than side-by-side columns, even if that makes the diagram taller — taller is scrollable in place, wider is not. If stacking makes the single diagram feel overloaded, split it instead (see above).
- Always keep the surrounding prose self-sufficient: the diagram should reinforce the explanation, not be the only place a key point is made (it may not render on every surface).

**File Setup Formatting Rule (required for how-to steps):**
- Do not use heredoc-style file creation commands such as `cat > file <<'EOF'` in instructional steps.
- For each file, present setup as:
  - `Create <path/filename>` (short purpose sentence), then
  - one fenced code block containing the file contents.
- Include the filename as the first line in the code block (for example, `# hosts.yaml`).
- Keep command blocks for executable commands only (for example, directory setup, `bundle install`, and test execution).

# Template-Specific Guidelines

**Scope Check — how broad is this decision?**
- ADRs span a spectrum: some change system structure, technology choices, or component boundaries; others are narrower, made while building within an already-settled architecture (e.g. "why this repo over that one for a migration," "why this hook is scoped the way it is").
- Tag the narrower kind with `-scope/implementation` (`-t -scope/implementation`, or add it to the frontmatter `tags:` list by hand) so readers and AI agents can gauge blast radius at a glance, without a separate document type or numbering stream to maintain.
- Leave the tag off for decisions that do change structure, technology choices, or component boundaries — that's the default, untagged case.
- Still unsure? Ask: "would reversing this decision require a rearchitecture, or just a rewrite of one component?" Rearchitecture → no tag. Rewrite of one component → tag `-scope/implementation`.

**Additional Linking Rules:**
- **Related ADRs**: Link to other ADRs: [[0001-title|ADR-0001]].
-->

# 0019. Tag ADRs by scope instead of a separate IDR document type

Date: 2026-07-28

## Status

Accepted

## Context

A separate `idr` document type was added alongside `adr` to distinguish narrow, implementation-scoped decisions ("why this repo over that one," "why this hook is scoped this way") from full architecture decisions (structure, technology choices, component boundaries). Each type got its own directory, numbering sequence, and README section.

Applying this in a real project (`bolt_dynamic_inventory`) surfaced the cost: classifying 10 existing ADRs into "architecture" vs "implementation" required real judgment on every entry, and several were genuinely borderline. Migrating the implementation-scoped ones to `idr` meant moving files between directories, renumbering, and rewriting every cross-reference wiki-link that pointed at them — real effort spent on a boundary that itself wasn't stable. Decisions get reclassified over time as more context arrives; a document's *type* (and therefore its directory and number) is expensive to change, while a tag is a one-line edit.

Mainstream ADR practice (Nygard's original format, and the guidance ThoughtWorks Radar has carried for years) doesn't split by scope at all — it keeps one flat log and resolves granularity by writing more, smaller ADRs, not by inventing a second document type.

## Decision

Remove the `idr` document type entirely and record scope as a tag on the single `adr` type instead:

- Deleted [`lib/diataxis/document/idr.rb`](../../lib/diataxis/document/idr.rb), [`templates/references/idr.md`](../../templates/references/idr.md), the `idr` registration in [`document_types.rb`](../../lib/diataxis/document_types.rb), and the `'idr'` default path in [`config.rb`](../../lib/diataxis/config.rb).
- [`templates/references/adr.md`](../../templates/references/adr.md)'s Scope Check now instructs: tag a narrower, implementation-scoped decision with `-scope/implementation` (`-t -scope/implementation`, or added to frontmatter `tags:` by hand); leave the tag off for decisions that do change structure, technology choices, or component boundaries. Same judgment test as before ("would reversing this require a rearchitecture, or just a rewrite of one component?"), different consequence — a tag, not a type.
- [`templates/references/wow.md`](../../templates/references/wow.md)'s own Scope Check no longer mentions IDR as a sibling type to rule out against.
- WoW stays a separate type (see [ADR-0005: Use purpose-driven document templates](./0005-use-purpose-driven-document-templates.md)) — it records team-process decisions, a genuinely different axis from "how technical is this decision," not just a narrower version of the same thing.

## Consequences

- Reclassifying a decision's scope later (which happens — see Context) is now a tag edit, not a file move plus a renumber plus a cross-reference rewrite.
- One numbering sequence, one directory, one README section — less to keep in sync, and "when in doubt, write one" stays true without a type-choice detour first.
- Losing the directory-level split means "show me only the architecture-level ADRs" now needs a tag-aware view (Obsidian tag search, or `grep` for the absence of `-scope/implementation`) rather than `ls docs/adr`.
- Existing `idr` documents in any repo need a one-time move back into `docs/adr` (restoring their original filename/number) plus the `-scope/implementation` tag; there's no automated migration for this — `dia update` doesn't renumber or retag on its own.

## Related Topics

- [ADR-0016: Replace per-type class files with registry DSL and template method hooks](./0016-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md) — the registry mechanism this decision removes an entry from
- [`templates/references/adr.md`](../../templates/references/adr.md) — the updated Scope Check guidance
- [`templates/references/wow.md`](../../templates/references/wow.md) — the sibling scope check that no longer references IDR
