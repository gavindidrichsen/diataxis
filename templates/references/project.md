<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines
Project doc — a project is any outcome needing more than one action.

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

## Key Concepts

The supporting detail behind the tasks. One subsection per term, mechanism, or
decision a task leans on, so the task list itself can stay one line per item.
Where a task is a *decision*, lay out the options and trade-offs here.

### Concept One

Explain the concept, mechanism, or decision a task refers to.

**Code Location** (if relevant): [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)

### Concept Two

Explain the next one.

## Background

Running breadcrumb trail: decisions already made, progress, and dead-ends — so
the project can be picked up later without re-deriving everything.

## Related Topics

- Code, documentation, issue trackers, and local docs links go here.
