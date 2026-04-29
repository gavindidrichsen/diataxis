<!--
GTD Philosophy Overview

Getting Things Done (GTD) is a productivity methodology by David Allen designed to reduce 
stress and improve clarity by organizing tasks and commitments into actionable lists.

Core Principles:

1. Capture Everything
   Collect all tasks, ideas, and commitments into a trusted system so nothing stays in your head.

2. Clarify & Organize
   Decide what each item means and where it belongs:
   - Is it actionable?
   - If yes, what's the Next Action?
   - If no, trash it, incubate it, or file it as reference.

3. Next Action Thinking
   Break projects into the very next physical, visible step you can take to move it forward.
   Example: Instead of "Plan website redesign," write "Email designer to schedule kickoff."

4. Project Definition
   A project in GTD is any outcome requiring more than one action. Define:
   - Purpose (Why this matters)
   - Desired Outcome (What "done" looks like)
   - Next Actions (What to do now)

5. Contextual Lists
   Organize actions by context or state:
   - @waiting – tasks dependent on others
   - @backlog – deferred tasks
   - @someday – ideas for the future

6. Review Regularly
   Weekly review ensures clarity and trust in your system.
-->
<!--
**Style Guidelines:**

- Use bulleted lists with `-` instead of numbered lists for easy reordering
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`)
- Keep headings descriptive so steps can be rearranged without renumbering
- Use `####` subheadings for troubleshooting subsections instead of bold text with numbers

When referencing code or documentation:
- **Code**: Link to GitHub with line numbers: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)
- **Docs**: Link to official documentation: [Ruby Logger Documentation](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html)
- **Local**: Link to local docs: [Related How-to](../how_to_other_guide.md)
-->

# Project: Fix GSD slice insertion and reordering to keep markdown and database aligned

**@urgent** tasks:

- [ ] Add a `sequence` field to `updateSliceFields()` in `gsd-db.ts` so existing slices can be reordered
- [ ] Add a `position` or `insertAfter` parameter to `gsd_reassess_roadmap` so new slices can be inserted at a specific position instead of always appending
- [ ] Ensure `renderRoadmapFromDb()` respects the updated sequence values after reordering

## Context

When a new slice needs to be inserted into the middle of an in-progress milestone, GSD has no mechanism to do this correctly. The `gsd_reassess_roadmap` tool always appends new slices to the end (sequence = existingCount + i + 1), and `updateSliceFields()` does not expose a `sequence` parameter. The roadmap markdown is rendered from the database — there is no markdown-to-DB sync path.

This means:
- New slices added via `gsd_reassess_roadmap` always appear last in the roadmap, regardless of where they logically belong in the dependency chain
- Manually editing the roadmap markdown to reorder slices has no effect on the database ordering — the next render overwrites the manual edit
- The only workaround is direct SQL against the `slices` table (`UPDATE slices SET sequence = N WHERE id = 'S03'`), which bypasses validation and is fragile

**Discovered during:** M001-3b7cia in the diataxis project, when S03 (a bugfix slice) needed to be inserted between the completed S02 and the planned S04. The agent had to manually edit the roadmap multiple times, and the DB and markdown kept drifting apart.

## Other Lists

**@backlog** tasks for later:

- [ ] Add a `gsd_reorder_slices` tool that accepts a milestoneId and an ordered array of slice IDs, then updates all sequence values atomically
- [ ] Add markdown-to-DB roundtrip sync so manual roadmap edits can be persisted (this is a much larger change and may not be desirable)
- [ ] Consider adding a `gsd_insert_slice` tool specifically for mid-milestone slice insertion, which handles sequence renumbering automatically

**@someday** ideas to revisit:

- [ ] Investigate whether the slice ordering problem also affects task ordering within slices

## Project Purpose

**Why does this project matter?**

GSD's core value proposition is that the database and markdown artifacts stay in sync. When inserting or reordering slices breaks this invariant, users lose trust in the system and waste time manually fixing drift. This is especially painful during auto-mode, where the agent relies on the DB for dispatch ordering.

## Desired Outcome

**What does "done" look like?**

- `gsd_reassess_roadmap` can insert new slices at a specific position (not just append)
- `updateSliceFields()` exposes a `sequence` parameter for reordering existing slices
- After any slice insertion or reorder operation, the rendered roadmap markdown reflects the new order
- No manual SQL or markdown editing is needed to insert a slice mid-milestone

## Background

### Root cause analysis

The GSD database stores slice ordering in a `sequence INTEGER DEFAULT 0` column on the `slices` table. Queries use `ORDER BY sequence, id` so ordering is well-defined. The gap is that no tool exposes a way to set or update `sequence` for existing slices:

- `gsd_plan_milestone` assigns `sequence: i + 1` based on the input array order — correct for initial planning
- `gsd_reassess_roadmap` assigns `sequence: existingCount + i + 1` for new slices — always appends
- `updateSliceFields()` in `gsd-db.ts:3052-3074` accepts `title`, `risk`, `depends`, and `demo` — no `sequence`
- The roadmap renderer reads from DB (`getMilestoneSlices`) and writes markdown — one-way, DB → markdown

### What had to be done manually to fix alignment

When S03 was inserted into M001-3b7cia between S02 and S04:

- The slice was created via `gsd_reassess_roadmap` with `sliceChanges.added`, which placed it at sequence 6 (after S04 at 4 and S05 at 5)
- The roadmap markdown showed S03 at the bottom, after S04 and S05
- Multiple manual edits to the roadmap markdown were needed to reorder the slice entries
- The boundary map section (which describes what each slice produces and what the next consumes) also needed manual rewriting
- Previous attempts to fix the ordering introduced escaped `\n` literal strings instead of actual newlines
- The S01 and S02 slices had bare titles ("S01: S01") instead of descriptive titles because the original `gsd_plan_milestone` call didn't include them and there was no way to update them via tools (this was eventually fixed by manual markdown editing, but the DB still has the bare titles)

### Relevant source files

- `gsd-db.ts:361-385` — slices table schema with `sequence` column
- `gsd-db.ts:1805+` — `insertSlice()` function
- `gsd-db.ts:2572` — `getMilestoneSlices()` with `ORDER BY sequence, id`
- `gsd-db.ts:3052-3074` — `updateSliceFields()` (missing `sequence` parameter)
- `reassess-roadmap.ts:189-203` — append-only new slice insertion
- `plan-milestone.ts:306` — initial sequence assignment
- `markdown-renderer.ts:152-187` — one-way DB → markdown rendering
