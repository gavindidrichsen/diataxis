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
Project doc — a project is any outcome needing more than one action.

**Title Rule:**
- The `# Simplify the default .diataxis to just the docs root` heading must always be an **imperative verb phrase** — action verb first, present tense.
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
- Backlog            — deferred/follow-up items surfaced but NOT on the critical path — triage at project completion, don't action mid-flight
- Key Concepts       — the meat behind the actions (mechanisms, decisions, jargon)
- Background         — running breadcrumb of decisions made and progress so far
- Related Topics     — real links to code, docs, tickets, and local notes
- Plan               — (only if seeded from a Claude Code plan) the full verbatim plan, always last

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

**Backlog section:**
- A single flat `Backlog` collection, separate from `Next Actions` — NOT the fuller GTD taxonomy (no `@waiting`/`@someday`/"Other Lists" split). One list, one purpose: things worth doing that surfaced while working the critical path but would derail it if actioned now.
- Populate it as the work surfaces things — a bigger redesign idea, a hardening pass, a "test this on another version/environment" note, an upstream-feedback item. Each entry is one line; link to a Key Concept if it needs more than a sentence of framing.
- **Do not action Backlog items mid-project.** They exist so the critical path doesn't absorb scope creep. Triage the whole list explicitly at project completion — decide per item: promote to a new project, file a ticket, or drop it.
- If an item turns out to block the critical path after all, promote it into `Next Actions` (and remove it from `Backlog`) rather than working it from the backlog list.

**Key Concepts section:**
- One subsection per term, mechanism, or decision a task links to — nothing the
  tasks don't reach for.
- A concept that is a *decision* lays out the options and their trade-offs (a
  short comparison table works well), then states the recommendation.
- A concept that touches code includes a source link (with line numbers) and a
  short code sample, per the Code Evidence Requirement above.

**This project doc is the root/hub document — spin off satellite docs rather than absorbing everything inline:**
- **Troubleshooting/investigation** (something failed and had to be diagnosed — logs read, hypotheses tested, a root cause chased down): don't grow a Key Concept or Background into a full investigation narrative. Create a `dia fivewhy new` doc for it, and link out from the relevant Key Concept with a one-line summary + the link. This keeps the project doc skimmable and gives the investigation itself a proper, reusable home.
- **Domain knowledge a Key Concept needs but doesn't have** — if a Key Concept would need real depth to explain properly (a mechanism, a gotcha, a "why does this work this way") and that depth doesn't already exist in a local repo doc or the Obsidian vault, don't inline it. Create a `dia explanation new` doc capturing the full domain knowledge, and link to it from the Key Concept, keeping the Key Concept itself to a short pointer + summary.
- **A decision gets made** (architecture, technology choice, component boundary, an implementation-level choice within settled architecture, or a team working-agreement/process change) — capture it as it happens, don't let it live only as prose in Key Concepts/Background:
  - System/technical decision (including narrower implementation-level ones — tag those `-scope/implementation`, see the ADR template's Scope Check) → `dia adr new`.
  - Team process / working-agreement decision (how people coordinate, branching discipline, review norms, a new provisioning practice) → `dia wow new`.
  - Link the ADR/WoW from the relevant Key Concept or Next Actions item with a one-line summary, same pattern as fivewhy/explanation spin-offs. A WoW's Context section should point back at this project doc as its traceable origin.
- **The cheatsheet stays the operational first-stop.** Commands, flags, verified snippets belong in the companion `dia cheatsheet new` doc (link it from Related Topics), never duplicated into this project doc's prose.
- Rule of thumb: this doc should read like a hub with short summaries and links, not like it's trying to also be a fivewhy, an explanation, an ADR/WoW, and a cheatsheet at once.

**Plan section (only when this project was seeded from a Claude Code plan):**
- If a plan file exists (path shown in the plan-approval banner, typically `~/.claude/plans/<name>.md`), link it plainly from Related Topics AND reproduce its full verbatim content in a final `## Plan` section at the very bottom of the document — after Related Topics, always last. This makes the doc fully self-contained even if the plan file itself is later cleaned up/rotated.
- Do not summarize or trim the plan content — paste it verbatim inside a fenced block or as plain markdown under the heading, exactly as approved.
- If the project has no originating plan (started some other way), omit this section entirely — do not add an empty placeholder.

**Background section:**
- This is the running log, not static context: decisions already made,
  progress, dead-ends. It is what lets the project be resumed later. Keep it
  distinct from "What we know" (which is the current evidenced picture).

**Final Compliance Check (required before finishing):**
- The fuller GTD "Other Lists" taxonomy (`@waiting`/`@someday`, multiple separate lists) is NOT present — only the single flat `Backlog` collection is permitted, and only if the project has actually surfaced deferred items.
- Problem leads with **Problem:** + **Done looks like:** + **Motivation:**, then the
  What we know / What we think `###` subsections.
- "What we know" gives an AI agent concrete entry points (local clones, line-linked
  files, repro commands) — not just assertions.
- Seed test: a competent agent that has never seen this work could pick the right
  first move from this doc alone.
- Next Actions has NO intro line — just the `@urgent` checklist; every item is
  one line and links to a Key Concept (unless trivially self-explanatory).
- Backlog items (if any) are not being silently actioned — they wait for project-completion triage.
- Any troubleshooting narrative lives in a linked `dia fivewhy new` doc, not inlined into Key Concepts/Background.
- Any Key Concept needing depth beyond what's locally/vault-available links to a `dia explanation new` doc rather than inlining it.
- Each Key Concept that touches code has both a link and a short code sample.
- Related Topics links are all concrete and valid.
-->

# Simplify the default .diataxis to just the docs root

## Problem

**Problem:** Setting only `"default"` in a `.diataxis` leaves ADRs and projects behind in `docs/`, because `DEFAULT_CONFIG` still hard-codes `adr` and `projects` under `docs/`.

**Done looks like:** ADRs and projects follow the default root (`<default>/adr`, `<default>/_gtd`) unless a `.diataxis` key overrides them. (The file itself is already minimal: PR #62 lets it be empty and `dia init` writes a commented sample above `{}`, ADR-0022.)

**Motivation:** A config file should only hold choices. The smaller it is, the less there is to explain, copy between repos, and get out of step.

### What we know

- **Done in [PR #62](https://github.com/gavindidrichsen/diataxis/pull/62):** an empty (or comment-only) `.diataxis` works and `dia init` writes a commented sample above `{}` ([[0022-a-diataxis-file-may-be-empty-or-commented-and-dia-init-writes-a-commented-sample|ADR-0022]]). `Config::DEFAULT_CONFIG` is `default`, `adr` and `projects` ([`lib/diataxis/config.rb`](lib/diataxis/config.rb)). `Config.load` merges a user's `.diataxis` over it.
- Path resolution is `config[type's config_key] || config['default']` ([`lib/diataxis/document.rb`](lib/diataxis/document.rb) `get_configured_directory`; ADR does the same in `ADR.pattern`).
- **Observed quirk (2026-10-13):** with a `.diataxis` of only `{"default":"notes"}`, `dia --here howto new` wrote to `notes/`, but `dia --here adr new` wrote to `docs/adr/` and `dia --here project new` to `docs/_gtd/`, because the merged `DEFAULT_CONFIG` still supplies `adr` and `projects` with `docs/` baked in.
- `adr` and `projects` are conventions: [[0014-underscore-the-gtd-directory-for-project-files-so-they-always-live-at-the-top|ADR-0014]] puts projects in `_gtd`; ADRs live in an `adr` folder.
- Types without a config key (explanation, howto, tutorial, ...) already fall back to `default`.

### What we think

- Give a document type an optional built-in subdirectory in `register` (for example `default_subdir: 'adr'` and `'_gtd'`), resolved as: explicit `.diataxis` key, then `<default>/<default_subdir>`, then `<default>`. **Inferred, not proven.** that this is all the resolution needs; upgrade: grep every use of `config_key` and `Config.path_for` and run the suite.
- Existing `.diataxis` files that set `adr` and `projects` explicitly keep working unchanged; ones that set only `default` would now move ADRs/projects under that root (arguably the intended behaviour, but a change). **Inferred, not proven.**

## Next Actions

- [ ] Decide whether per-type subdirectories become built-in defaults - see [[#Options|the options]]
- [ ] Implement the resolution order and shrink `DEFAULT_CONFIG` to `default` - see [[#Options|the options]] (the remaining part of this project)
- [ ] Update specs and features that assume `adr`/`projects` appear in the default config, and add one for "only `default` set"
- [ ] Update the README, the how-to-add-a-template guide (Step 3) and the CHANGELOG; record it in an ADR

## Key Concepts

### Options

| Option | `.diataxis` written by `dia init` | Cost | Notes |
| --- | --- | --- | --- |
| Status quo | an empty `{}` plus a commented sample (done) | none | `default` alone does not move ADRs/projects (quirk above) |
| Built-in per-type subdirectory | still `{}` | small: `register` option, resolution order, specs | fixes the quirk; recommended |
| No `.diataxis` needed for docs | none | medium: needs a root marker | no-config already routes into the current directory ([README](README.md)), so a marker file is still needed |

Recommendation: **built-in per-type subdirectory**.

## Background

- 2026-10-13 - Suggested while removing the README in PR #62; deliberately kept out of that PR to keep it reviewable.

## Related Topics

- [[0014-underscore-the-gtd-directory-for-project-files-so-they-always-live-at-the-top|ADR-0014]] - why `_gtd`.
- [[0020-drop-readme-generation-so-dia-only-renames-documents-and-repoints-wiki-links|ADR-0020]] - the PR that simplified the default config first.
- [`lib/diataxis/config.rb`](lib/diataxis/config.rb) - `DEFAULT_CONFIG` and `Config.load`.
