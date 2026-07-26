---
tags:
  - -references/diataxis
---

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
Project doc — a project is any outcome needing more than one action.

**Title Rule:**
- The `# Simplify Diataxis CLI Output Routing Behaviour` heading must always be an **imperative verb phrase** — action verb first, present tense.
- Good: `# create GSD milestone retrospective slice`, `# investigate resource_api sensitive parameters`, `# fix bolt-136 broken test`
- Bad: `# GSD milestone`, `# resource_api`, `# dummy`
- The verb encodes intent (what you are doing to the subject), which makes the doc self-orienting in any file list and tells an AI agent the goal immediately.
- Pass the full verb phrase as the `dia` argument: `dia project new 'create GSD milestone retrospective slice'`

**Dual audience — a human GTD doc AND an AI investigation seed.** This document
has two readers at once, and must serve both:
- A **human** scanning for the point, the motivation, and the next actions —
  skimmable, GTD-shaped, depth pushed down.
- An **AI agent** handed this doc as the *seed* to cold-start a fresh
  investigation — it must be able to begin productively from this file alone,
  without the author present to fill gaps.
Write so neither audience is shortchanged. For the agent that means: state the
goal AND the deeper knowledge being chased (not just "fix X"); separate confirmed
facts from hypotheses cleanly so it doesn't re-litigate settled ground; and give
it concrete, openable entry points — local clones to read (per the
check-local-clones convention), key files with line-linked locations, commands to
run, and the tickets/docs that hold prior context. A good test: could a competent
agent that has never seen this work pick the right first move from this doc?

Shape: open by capturing your thinking (handover style — problem, motivation,
what we know, what we think), then a sparse Next Actions checklist, with the
supporting detail pushed down into a Key Concepts section (explanation style).
Each task assumes the reader already knows what it means and links to its Key
Concept for the "what does this actually mean / what are the options" detail. This
keeps the task list lovely and clear without losing the depth a reviewer — human
or AI — needs.

Sections:
- Problem            — the problem in one line + what "done" looks like in one line + why it matters / what knowledge is being chased
  - What we know     — (### subsection) confirmed facts / current state, with evidence AND the concrete entry points an agent would open first
  - What we think    — (### subsection) hypotheses, or the chosen plan and the reasoning for it
- Next Actions       — @urgent items, one line each, each linking to a Key Concept
- Key Concepts       — the meat behind the actions (mechanisms, decisions, jargon)
- Background         — running breadcrumb of decisions made and progress so far
- Related Topics     — real links to code, docs, tickets, and local notes

**Problem section:**
- Lead with three bold lines: **Problem:** (one line), **Done looks like:** (one
  line), and **Motivation:** (one line — why this matters and, where relevant, the
  deeper domain knowledge being chased, not just the task outcome). The Motivation
  line is what tells both a human and an AI agent what to *optimise for*.
- Then two `###` subsections — **What we know** and **What we think** (see below).
- This is the orientation. Keep the leads to one sentence each — depth belongs lower down.

**What we know / What we think:**
- "What we know" = confirmed, evidenced facts and current state — link evidence
  (code lines, logs, command output) rather than asserting.
- This section doubles as the **AI seed's entry map**: name the repos and local
  clones to read first (per the check-local-clones convention), the key files with
  line-linked locations, and any command that reproduces the current state. An
  agent should be able to start exploring from these handles alone.
- "What we think" = hypotheses or the chosen plan, each with its reasoning. This
  is where judgement lives; mark anything unconfirmed as such.
- If a project has no open thinking (pure delivery), keep "What we think" short
  — a one-line statement of the plan is fine — but do not delete the heading.

**Next Actions ↔ Key Concept linking:**
- Next Actions is a bare `@urgent` checklist — one line per item, with **no
  intro or explanatory line above it** (that rule lives here, not in the body).
- Each item is sparse and skimmable; assume the reader knows the terms.
- Any term, mechanism, or decision an action leans on gets its own Key Concept
  subsection, and the action links to it with a same-file heading link
  (Obsidian form: `[[#Heading Text|display text]]`).
- Push all explanation into Key Concepts — never pad the Next Actions list itself.

**Key Concepts section:**
- One subsection per term, mechanism, or decision a task links to — nothing the
  tasks don't reach for.
- A concept that is a *decision* lays out the options and their trade-offs (a
  short comparison table works well), then states the recommendation.
- A concept that touches code includes a source link (with line numbers) and a
  short code sample, per the Code Evidence Requirement above.

**Background section:**
- This is the running log, not static context: decisions already made,
  progress, dead-ends. It is what lets the project be resumed later. Keep it
  distinct from "What we know" (which is the current evidenced picture).

**Final Compliance Check (required before finishing):**
- "Other Lists" / @waiting / @backlog / @someday are NOT present.
- Problem leads with **Problem:** + **Done looks like:** + **Motivation:**, then the
  What we know / What we think `###` subsections.
- "What we know" gives an AI agent concrete entry points (local clones, line-linked
  files, repro commands) — not just assertions.
- Seed test: a competent agent that has never seen this work could pick the right
  first move from this doc alone.
- Next Actions has NO intro line — just the `@urgent` checklist; every item is
  one line and links to a Key Concept (unless trivially self-explanatory).
- Each Key Concept that touches code has both a link and a short code sample.
- Related Topics links are all concrete and valid.
-->

# Simplify Diataxis CLI Output Routing Behaviour

## Problem

**Problem:** Creating diataxis docs outside of `DIATAXIS_ROOT` requires a cumbersome `DIATAXIS_ROOT=$PWD dia explanation new ...` incantation, which discourages per-repo documentation.

**Done looks like:** Running `dia <type> new "Title"` drops docs into the right place automatically -- the current directory's `.diataxis`-configured location when present, or `DIATAXIS_ROOT` as fallback -- without manual env var overrides.

**Motivation:** The friction of the override kills the habit of documenting where the knowledge lives. Understanding what the "right default" should be for output routing is the real design question here -- it determines whether diataxis remains a single-vault tool or becomes a use-anywhere CLI.

### What we know

- `DIATAXIS_ROOT` env var is resolved exactly once, at the composition root: [`cli.rb:15`](https://github.com/gavindidrichsen/diataxis/blob/e06f4abb10871486d643b34c17b40a4254b24517/lib/diataxis/cli.rb#L15). Everything downstream receives `root` as an argument and never touches `ENV` again (comment at `cli.rb:11-14` states this explicitly).
- `Config.find_config` walks **upward** from the resolved root to `/`, looking for a `.diataxis` file; first one found wins: [`config.rb:34-43`](https://github.com/gavindidrichsen/diataxis/blob/e06f4abb10871486d643b34c17b40a4254b24517/lib/diataxis/config.rb#L34-L43). `Config.load` (`config.rb:18-26`) merges its JSON over `DEFAULT_CONFIG` (`"default": "docs"`, `"projects": "docs/_gtd"`, etc., `config.rb:11-16`).
- There is no interactive prompt or `--local`/`--here` flag today. Flags are hand-parsed in a `while`/`case` loop, not OptionParser: [`global_flags_handler.rb:18-36`](https://github.com/gavindidrichsen/diataxis/blob/e06f4abb10871486d643b34c17b40a4254b24517/lib/diataxis/cli/global_flags_handler.rb#L18-L36). A new flag (e.g. `--local`) would be added as another `when` branch here, following the `--tag`/`-t` pattern (lines 25-27).
- Commit [`b771ad5`](https://github.com/gavindidrichsen/diataxis/commit/b771ad5) fixed a double-resolution bug: `command_handlers.rb` used to pre-resolve a subdirectory via `Config.path_for` and pass that *already-resolved* path into `Document.new`, which internally re-ran `get_configured_directory` (`document.rb:146-157`) and walked up from the resolved subdir -- sometimes finding a stray *nested* `.diataxis` and doubling the path (`docs/docs/...`). Fix: pass the raw root straight through so config resolution happens exactly once. **This means today's precedence is already: explicit CLI directory arg > `DIATAXIS_ROOT` > CWD, then `.diataxis` (found by upward walk from whichever root won) supplies per-type subdirectories** -- any new routing model must not reintroduce a second resolution pass.
- The current workflow to create docs in a specific repo requires: `cd <repo> && DIATAXIS_ROOT=$PWD dia explanation new "Title"`. The repo must contain a `.diataxis` file or the command fails (`ensure_config_exists!` hard-fails otherwise -- see [[project_fix_dia_behavriour_when_no_diataxis_file_is_present]]).
- Most of the time, docs go to the central Obsidian vault (`DIATAXIS_ROOT` pointing at `@INBOX`). But targeted repo docs (e.g. the diataxis gem's own `docs/`) need the override.
- The env-var mechanism itself is an ADR-level decision, not incidental: `docs/adr/0015-support-environment-variable-configuration-with-diataxis-root-and-diataxis-tags.md`. Any routing-model change should update or supersede that ADR, not silently diverge from it.
- Entry points for investigation:
  - Local clone: `~/@REFERENCES/github/app/development/tools/puppet/repositories/gavindidrichsen/diataxis/`
  - Root resolution: [`lib/diataxis/cli.rb:15`](https://github.com/gavindidrichsen/diataxis/blob/e06f4abb10871486d643b34c17b40a4254b24517/lib/diataxis/cli.rb#L15)
  - Config resolution: `lib/diataxis/config.rb` (`find_config` walk-up, `load`, `path_for`)
  - Directory computation per-document: `lib/diataxis/document.rb:146-157` (`get_configured_directory`)
  - Flag parsing: `lib/diataxis/cli/global_flags_handler.rb:12-42` (`process!`)
  - Command dispatch: `lib/diataxis/cli/command_handlers.rb:82-98` (`create_document_with_readme_update`)
  - ADR: `docs/adr/0015-support-environment-variable-configuration-with-diataxis-root-and-diataxis-tags.md`
  - Existing coverage: `features/diataxis_root.feature` (Cucumber) and `spec/diataxis_spec.rb:664-756` (`describe 'DIATAXIS_ROOT environment variable'`, including the "no `.diataxis` file" and "loads config from DIATAXIS_ROOT, not CWD" cases) -- any new routing model must keep these green or deliberately update them.

### What we think

- The core tension is between two valid use cases: (a) a central knowledge vault where most docs accumulate, and (b) per-repo docs that live with the code they describe.
- **Hypothesis: presence of `.diataxis` should be the primary routing signal, not `DIATAXIS_ROOT`.** If a `.diataxis` file exists in or above CWD, use it. Only fall back to `DIATAXIS_ROOT` when no local config is found.
- An alternative: `dia` always creates docs relative to CWD unless `DIATAXIS_ROOT` is set. This is simpler but loses the "walk up to find `.diataxis`" convenience.
- A third option: make `.diataxis` a global config (`~/.diataxis`) that defines a default root, with local `.diataxis` files overriding it. This would replace the env var entirely.
- All options need careful thought about what happens with `dia update` (which rebuilds the README index) -- the scope of `update` must match the scope of `new`.

## Next Actions

- [ ] Map the current resolution precedence in detail -- see [[#Current Resolution Precedence|the concept]]
- [ ] Decide on the new routing model -- see [[#Routing Model Options|the concept]]
- [ ] Prototype the chosen model in a branch
- [ ] Verify that `dia update` scope stays consistent with `dia new` scope
- [ ] Update `dia --help` / usage text to reflect the new behaviour

## Key Concepts

### Current Resolution Precedence

Today the effective root is determined by a single check:

```
DIATAXIS_ROOT set?
  YES --> use DIATAXIS_ROOT as root
  NO  --> use CWD as root
```

Then, within that root, `.diataxis` config is found by walking up from root. If no `.diataxis` is found, the command fails hard.

This means `DIATAXIS_ROOT` is a blunt global override -- it cannot coexist with a local `.diataxis` in CWD without the user explicitly unsetting or overriding it.

### Routing Model Options

| Option | How it works | Pros | Cons |
|--------|-------------|------|------|
| **A: Local-first** | Check CWD (and parents) for `.diataxis` first; fall back to `DIATAXIS_ROOT` only if none found | Natural "docs live with code" default; central vault still works via env var fallback | Breaking change for users who set `DIATAXIS_ROOT` and run `dia` from repos that happen to have `.diataxis` |
| **B: CWD-default** | Always create relative to CWD; `DIATAXIS_ROOT` is the only override | Simplest mental model; no config walk-up needed | Loses the convenience of `.diataxis` routing; repos need explicit `DIATAXIS_ROOT=$PWD` if they want non-default paths |
| **C: Global config** | `~/.diataxis` defines the global default root; local `.diataxis` overrides per-repo; no env var needed | Cleanest long-term; env var becomes optional | Most work to implement; migration path for existing users |
| **D: Flag override** | Keep current behaviour but add `--local` / `--here` flag to force CWD | Zero breaking changes | Still cumbersome (just a different incantation); doesn't solve the root UX problem |
| **E: Interactive prompt on detection** | When a `.diataxis` is found in/above CWD *and* `DIATAXIS_ROOT` is also set (a real conflict), prompt: "Found a local `.diataxis` here -- use it, or your global `DIATAXIS_ROOT`?" | Surfaces the ambiguity instead of silently picking one; teaches the user the mechanism as they hit it | Breaks non-interactive/CI use (needs a flag or env var escape hatch, e.g. `--yes`/`DIATAXIS_NONINTERACTIVE`); another code path to maintain |

**Leaning toward:** Option A (local-first) as the silent default, with Option E's prompt reserved for the genuinely ambiguous case -- both `DIATAXIS_ROOT` is set *and* a `.diataxis` exists locally -- so routine use (only one signal present) stays silent and fast. Option C (global config) remains a plausible later refinement. The key insight is that `.diataxis` presence is the strongest signal of "I want docs managed here", and it should win over a global env var; a prompt only earns its keep when both signals genuinely disagree.

## Background

- 2026-07-10: Project created to assess simplification options. No code changes yet.
- The related project [[project_fix_dia_behavriour_when_no_diataxis_file_is_present]] added the fail-fast behaviour when `.diataxis` is missing -- that work is a prerequisite constraint (we don't want to regress it by making `.diataxis` optional again without a clear fallback path).
- 2026-07-23: A second GTD doc (`project_improve_the_diataxis_root_override_mechanism.md`) was created independently covering the same problem, with an additional idea -- prompting interactively when a `.diataxis` is detected. Merged that idea in here as Option E and deleted the duplicate, per the "search before creating" convention.

## Related Topics

- [[project_fix_dia_behavriour_when_no_diataxis_file_is_present]] -- the fail-fast behaviour when no `.diataxis` is found
- [[project_consolidate_diataxis_rules_across_claude_skills]] -- related effort to simplify the diataxis toolchain
- `docs/adr/0015-support-environment-variable-configuration-with-diataxis-root-and-diataxis-tags.md` -- the ADR documenting the current `DIATAXIS_ROOT`/`DIATAXIS_TAGS` design
- [`commit b771ad5`](https://github.com/gavindidrichsen/diataxis/commit/b771ad5) -- fixed double-nested doc paths from a stray nested `.diataxis`, directly relevant prior art for any routing-precedence change
