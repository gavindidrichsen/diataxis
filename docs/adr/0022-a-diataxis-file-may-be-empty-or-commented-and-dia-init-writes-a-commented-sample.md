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
- **Chat (Slack, etc.)**: Every quoted message needs its own permalink, not just a link to the thread as a whole — a paraphrase with no per-message link is not proof under the Evidence Discipline below. Slack permalinks aren't one-click like GitHub's `y` key; build them from the message's `ts` (timestamp): `https://<workspace>.slack.com/archives/<channel-id>/p<ts-with-the-decimal-point-removed>` (append `?thread_ts=<root-ts>&cid=<channel-id>` when the message is a thread reply, for readers who need thread context). E.g. `ts` `1789633639.433619` in channel `G049EJF2Z2A` becomes `https://workspace.slack.com/archives/G049EJF2Z2A/p1789633639433619`.

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

**Evidence Discipline — proven vs. inferred is a first-class distinction (mandatory, universal to every diataxis type):**

- **Bias toward proven.** Every factual claim in this document must default to proven-with-evidence. A claim is *proven* only when it is backed by a first-hand artefact the reader can independently open — a commit-SHA permalink, a quoted log line, a live command's exit code and output, a Slack `ts` link, a ticket ID, a screenshot, a test that reproduces it. Restating what someone said without a link is **not** proof.
- **Never smuggle an inferred claim into a proven-looking sentence.** If any sub-claim inside a paragraph, bullet, table row, evidence block, or code annotation is not first-hand-verifiable, that sub-claim MUST be marked inline with the literal bolded phrase **`Inferred, not proven.`** (verbatim, so it is greppable). Do not soften with adjacent language ("likely proven", "probably confirmed"); the marker is binary. When multiple sub-claims share a section, prefer a per-claim verdict table (claim → evidence → verdict) over prose, because prose hides gaps and tables surface them.
- **Every inferred claim owes the reader two things: what would prove it, and why it isn't proven yet.** Beside every `**Inferred, not proven.**` marker, name the specific artefact that *would* upgrade it (e.g. "would be proven by inspecting the Jenkins job history for `pipeline_release-packages_publish` between 2026-02-10 and 2026-07-31") and briefly say why that check was not done in this investigation (out of scope, no access, blocked on X, next step). An inferred claim without a named upgrade-path is a bug in the document.
- **Follow-up is not optional if it matters.** If the inferred claim is load-bearing for the document's conclusion (root cause, recommended fix, next step, ADR verdict), the document MUST also record either (a) a named follow-up action (ticket, task, next investigation), or (b) an explicit acknowledgement that the conclusion is contingent on that unproved link. Load-bearing inference without a follow-up is prohibited.
- **Author's checklist before publishing.** Before saving the file, grep it for weasel-words that mask inference: "clearly", "must have", "obviously", "certainly", "we know that", "presumably". Every occurrence is a mandatory review point — either replace with a proven citation, or replace with `**Inferred, not proven.**` + upgrade path.

This discipline exists because a diataxis document that reads *proven* on the surface but contains hidden inferred assertions silently invalidates every conclusion built on top of it. Transparency of provenance is not an optional courtesy — it is how the document earns the reader's trust to act on it.

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

# 0022. A .diataxis file may be empty or commented and dia init writes a commented sample

Date: 2026-10-13

## Status

Accepted

Refines [ADR-0002](./0002-use-configuration-file-for-document-paths.md).

## Context

With README generation gone ([[0020-drop-readme-generation-so-dia-only-renames-documents-and-repoints-wiki-links|ADR-0020]]) and `dia update` requiring a `.diataxis` root ([[0021-dia-update-targets-an-explicit-directory-or-diataxis-root-and-requires-a-diataxis-root|ADR-0021]]), the `.diataxis` file has two jobs: it marks a directory as a documentation root, and it optionally overrides where document types are written. Every location already has a default (`docs/`, `docs/adr`, `docs/_gtd`), so nothing has to be written in the file.

Two problems showed up in testing:

- An **empty** `.diataxis` crashed with a raw `JSON::ParserError` stack trace.
- `dia init` wrote a fully populated JSON object, which listed defaults the user never chose and left no place to explain the overrides.

JSON has no comments, although the `json` gem in use happened to accept `//` lines; relying on that would break silently on a gem change.

## Decision

- **The file only has to exist.** An empty file, a file of only comments, and `{}` all mean "no overrides": every default applies.
- **Full-line `//` comments are ignored** by `dia` itself (not by the JSON library): lines whose first non-blank characters are `//` are removed before parsing. `//` inside a value is untouched.
- **Overrides are plain JSON** added inside an object (`{ "howtos": "docs/guides" }`), merged over the defaults.
- **`dia init` writes a commented sample above an empty `{}`.** The sample shows the override keys (`default`, `adr`, `projects`, `explanations`, `tutorials`, `howtos`, `cheatsheets`, `wow`) and that paths are relative to the file's directory; the object stays empty.
- **Bad content is a clear error.** Invalid JSON, or JSON that is not an object, raises a `ConfigurationError` naming the file, not a stack trace.

## Consequences

### Easier

- Marking a directory as a root is `touch .diataxis`.
- A new `.diataxis` explains itself and carries no values the user did not choose.
- A malformed config is a one-line message pointing at the file.

### Harder

- The format is JSON plus full-line `//` comments, which is not standard JSON; editors may flag the comments, and only whole-line `//` comments are supported (not trailing or `/* */` comments).
- Existing `.diataxis` files keep working unchanged, but `dia init` output differs from before (comments plus `{}` instead of a populated object).

### Unchanged

- Override keys, precedence (explicit key, then `default`), and the `DEFAULT_CONFIG` values.

## Related Topics

- [[0002-use-configuration-file-for-document-paths|ADR-0002]] - introduced the configuration file.
- [[0021-dia-update-targets-an-explicit-directory-or-diataxis-root-and-requires-a-diataxis-root|ADR-0021]] - why a `.diataxis` is the root marker `update` checks for.
- [[project_simplify_the_default_diataxis_to_just_the_docs_root]] - the remaining part: built-in per-type subdirectories.
- [`lib/diataxis/config.rb`](../../lib/diataxis/config.rb) - `Config::TEMPLATE`, `load`, `parse`.
