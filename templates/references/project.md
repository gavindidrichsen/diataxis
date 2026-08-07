<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines
Project doc — a project is any outcome needing more than one action.

**Title Rule:**
- The `# {{title}}` heading must always be an **imperative verb phrase** — action verb first, present tense.
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

# {{title}}

## Problem

**Problem:** State the problem motivating this project in one line.

**Done looks like:** State the concrete end-state you're aiming for in one line.

**Motivation:** Why this matters in one line — and, where relevant, the deeper domain knowledge you're really chasing (what understanding this project is meant to leave you with), so a human and an AI agent both know what to optimise for.

### What we know

- Confirmed facts and current state, with evidence (link code lines, logs, or command output rather than asserting).
- Entry points for an investigation (this is the AI seed's starting map): the repos / local clones to read first, key files as line-linked locations, and any command that reproduces the current state.

### What we think

- The chosen plan, or hypotheses if anything is still open — each with its reasoning. Mark unconfirmed items as such.

## Next Actions

- [ ] First next action — see [[#Concept One|the concept]]
- [ ] Second next action — see [[#Concept Two|the concept]]

## Backlog

<!-- Omit this section entirely if nothing has been deferred yet. -->

- Deferred item surfaced during the work — one line, link to a Key Concept if it needs framing.

## Key Concepts

The supporting detail behind the tasks. One subsection per term, mechanism, or
decision a task leans on, so the task list itself can stay one line per item.
Where a task is a *decision*, lay out the options and trade-offs here.

### Concept One

Explain the concept, mechanism, or decision a task refers to.

**Code Location** (if relevant): [`filename:line`](https://github.com/org/repo/blob/<commit-sha>/path/file.rb#L123)

### Concept Two

Explain the next one.

## Background

Running breadcrumb trail: decisions already made, progress, and dead-ends — so
the project can be picked up later without re-deriving everything.

## Related Topics

- Code, documentation, issue trackers, and local docs links go here.
