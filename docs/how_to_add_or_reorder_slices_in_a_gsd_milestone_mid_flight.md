<!--
# Common Guidelines
**Style Guidelines (Strict):**

- Treat this document as a template to be filled, not redesigned.
- Replace placeholder text completely; do not leave generic filler.
- Keep wording concise, specific, and scoped to this document's topic.
- Use bulleted lists with `-` instead of numbered lists for easy reordering.
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`).
- Keep headings descriptive so steps can be rearranged without renumbering.

# Template-Specific Guidelines
- Key concept headings must be concise, descriptive titles (3-7 words).
- Placeholder headings such as `### Concept 1` and `### Concept 2` must be replaced with topic-specific titles before completion.
- Use `####` subheadings for troubleshooting subsections instead of bold text with numbers.

**Purpose Section Requirement:**
- Rewrite the Purpose questions so they explicitly describe what this specific document explains.
- Do not keep generic Purpose questions if they are template placeholders.

**Linking Rules:**
- Every reference in Related Topics must be a real link (no placeholder bullets).
- **Code**: Link to GitHub with line numbers: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123).
- **Docs**: Link to official documentation pages.
- **Local**: Link to local docs with relative paths.

**Code Evidence Requirement (required when code is referenced):**
- Each major concept section must begin with a concise summary title (3-7 words) as the section heading.
- For each major concept,
  - Create a summary title for the concept
  - include BOTH A source link to real code (with line numbers), and A short “Code Sample” block that clarifies intent.
- The “Code Sample” may be:
  - A minimal real excerpt, or
  - A simplified pseudocode version with brief comments.
- The sample must explain behavior, not just repeat syntax.
- Keep samples small and focused (about 5–20 lines).
- Add 1–3 bullets under each sample explaining:
  - what the code is doing,
  - why it matters in this document,
  - and any important caveat/assumption.
- Never fabricate APIs or behavior; if code cannot be verified, explicitly state that and omit the sample.

**File Setup Formatting Rule (required for how-to steps):**
- Do not use heredoc-style file creation commands such as `cat > file <<'EOF'` in instructional steps.
- For each file, present setup as:
  - `Create <path/filename>` (short purpose sentence), then
  - one fenced code block containing the file contents.
- Include the filename as the first line in the code block (for example, `# hosts.yaml`).
- Keep command blocks for executable commands only (for example, directory setup, `bundle install`, and test execution).

**Final Compliance Check (required before finishing):**
- Heading structure unchanged.
- Placeholder text removed.
- Purpose questions are document-specific.
- Related Topics links are all concrete and valid.
- Each code reference includes both a link and an explanatory code sample.
- File setup instructions use “Create <file>” + code block format (no `cat > ...` heredoc flow).
-->

# How to add or reorder slices in a GSD milestone mid-flight

## Description

How to insert a new slice into the middle of an in-progress GSD milestone, or reorder existing slices. This documents a **proven workaround** for known GSD limitations, tested live on milestone M001-3b7cia (2026-04-29).

**Key limitation:** Any `gsd_*` tool that re-renders the roadmap (including `gsd_reassess_roadmap` with no changes) will overwrite manual markdown edits. Manual roadmap fixes must be re-applied after every `gsd_*` roadmap operation. See the [project file](_gtd/project_fix_gsd_slice_insertion_and_reordering_to_keep_markdown_and_database_aligned.md) tracking the upstream fix.

## Prerequisites

- A GSD milestone that is already in progress (some slices completed, some pending)
- Understanding of the `.gsd/` directory structure (see `.gsd/PROJECT.md`)
- The `gsd_reassess_roadmap` tool available (used to add new slices)

## What the database actually stores

Before using this workaround, understand what the DB tracks and what it ignores:

| Field | Stored in DB | Stored in markdown only |
|-------|-------------|------------------------|
| Slice ID (S01, S02, ...) | Yes | Yes |
| Slice title | Yes (often bare, e.g. "S01") | Yes (can be descriptive) |
| Slice status | Yes | Yes (checkbox) |
| Sequence (display order) | Yes (but no tool to update it) | Implicit by position |
| Dependencies (`depends:[]`) | **No** — `depends_on` field does not exist in DB | Yes — only in markdown text |
| Boundary map | Yes (as a single escaped string) | Yes |

**Critical finding:** Dependencies exist only in the roadmap markdown. The DB has no `depends_on` field for slices. When the roadmap is re-rendered from DB, the `depends:[]` values in the markdown come from the milestone's `boundary_map_markdown` field stored as a single text blob — which preserves whatever was set at initial planning time but does not get updated by `gsd_reassess_roadmap`.

## Usage

### Add a new slice between existing slices

**This is the proven workflow. Every step has been tested.**

#### Create the slice in the database

Use `gsd_reassess_roadmap` with `sliceChanges.added`. Set `depends` correctly — while it won't be stored in the DB, it will appear in the re-rendered roadmap markdown.

```
gsd_reassess_roadmap({
  milestoneId: "M001-xxx",
  completedSliceId: "S02",      // last completed slice
  verdict: "roadmap-adjusted",
  assessment: "Adding S06 between S03 and S04 for <reason>",
  sliceChanges: {
    modified: [],
    added: [{
      sliceId: "S06",
      title: "Your descriptive title",
      risk: "low",
      depends: ["S03"],
      demo: "After this: <what changes>"
    }],
    removed: []
  }
})
```

**What happens:**
- The new slice is added to the DB with `sequence = existingCount + 1` (always appended)
- The roadmap markdown is **re-rendered from DB**, destroying any prior manual edits
- The new slice appears at the bottom of the `## Slices` section
- The boundary map reverts to the DB-stored version (often with escaped `\n` literals)
- S06 and S03 may get the same sequence number (duplicate sequence bug)
- No `S06/` directory is created on disk — only DB + markdown are updated

#### Fix the roadmap markdown (mandatory after every re-render)

After the tool finishes, manually edit the roadmap file at `docs/gsd/milestones/M###/M###-ROADMAP.md`:

- Move the new slice entry to its correct position in `## Slices`
- Fix the `depends:[]` on the downstream slice (e.g., S04 should now say `depends:[S06]`)
- Fix any bare slice titles (e.g., "S01: S01" → "S01: Descriptive title")
- Replace the boundary map section — the DB version has escaped `\n` literals on a single line; replace with actual newlines and correct section headings
- Add the new slice to the boundary map (e.g., `### S03 → S06` and `### S06 → S04`)

**Important: Edit `.gsd/` first, then copy to `docs/gsd/`.** GSD maintains both `.gsd/milestones/` and `docs/gsd/milestones/` as separate copies. When a `gsd_*` tool re-renders the roadmap, it writes to `.gsd/` and syncs to `docs/gsd/`. If you only edit `docs/gsd/`, the `.gsd/` copy may silently overwrite your changes on the next sync. The reliable approach:

```bash
# Edit the .gsd/ copy (this is the authoritative source)
# Then copy to docs/gsd/ to keep them in sync:
cp .gsd/milestones/M001-xxx/M001-xxx-ROADMAP.md docs/gsd/milestones/M001-xxx/M001-xxx-ROADMAP.md
```

#### Accept the fragility

Your manual edits **will be destroyed** the next time any of these tools run:
- `gsd_reassess_roadmap` (even with empty `sliceChanges`)
- `gsd_slice_complete` (triggers roadmap checkbox toggle + re-render)
- Any other `gsd_*` tool that calls `renderRoadmapFromDb()`

**After each such tool call, re-apply the manual fix.** There is no way to prevent this with current GSD tooling.

### Reorder existing slices

There is no tool-supported way to reorder existing slices. The practical approach:

- Edit the roadmap markdown to reflect the desired order
- Ensure all `depends:[]` references form a valid DAG (no circular dependencies)
- Update the boundary map section to match
- Accept that the fix must be re-applied after any `gsd_*` roadmap re-render

### Add new tasks to an existing slice

Use `gsd_plan_task` to add tasks to an existing slice. This tool works correctly — tasks are added to the slice's task list and the plan markdown is updated. No manual fixup needed.

The slice must already exist (created via `gsd_plan_slice` or `gsd_reassess_roadmap`). Task sequence is assigned based on existing task count.

### Remove a slice

Use `gsd_reassess_roadmap` with `sliceChanges.removed: ["S06"]`. This correctly removes the slice from the DB. The roadmap is re-rendered without it. You still need to manually fix ordering and boundary map after the re-render.

## Appendix

### Proven test results (M001-3b7cia, 2026-04-29)

This workflow was tested end-to-end. Here is what happened at each step:

| Step | Action | Result |
|------|--------|--------|
| Baseline | Fixed roadmap manually (ordering, titles, boundary map) | Roadmap looked correct |
| Add slice | `gsd_reassess_roadmap` with `sliceChanges.added: [S06]` | S06 added to DB as seq=6 (same as S03). **All manual edits destroyed** — roadmap re-rendered from DB |
| Manual fix | Moved S06 between S03 and S04, fixed deps and boundary map | Roadmap looked correct again |
| Durability test | `gsd_reassess_roadmap` with empty `sliceChanges` | **All manual edits destroyed again** — identical re-render from DB |
| Cleanup | `gsd_reassess_roadmap` with `sliceChanges.removed: ["S06"]` | S06 removed correctly. Manual edits destroyed (expected). |
| Final fix | Re-applied manual ordering fix | Roadmap correct but fragile |

**Conclusion:** The manual fix works for human-readable display but is not durable. Any `gsd_*` roadmap operation requires re-applying the fix.

### Escaped newlines in boundary maps

The GSD DB stores the boundary map as a single text field. When `renderRoadmapFromDb()` writes it to markdown, newlines are escaped as literal `\n` characters on a single line. For example:

```
### S01 → S02\n\nProduces:\n- item one\n- item two
```

When fixing the roadmap manually, replace these escaped sequences with actual line breaks.

### Dependencies not stored in database

The `depends:[]` values visible in the roadmap markdown are **not persisted in the DB**. The `state-manifest.json` export confirms that slices have no `depends_on` field. This means:

- Auto-mode cannot use dependency order from the DB — it only has sequence order
- If auto-mode reads dependencies from the roadmap markdown (which is re-rendered from DB), the depends values come from the milestone's stored boundary map text, not from any structured dependency field
- The `depends:[]` you set in `gsd_reassess_roadmap`'s `added` array may or may not survive the re-render, depending on how the boundary map is reconstructed

### Related Resources

- [Project: Fix GSD slice insertion and reordering](_gtd/project_fix_gsd_slice_insertion_and_reordering_to_keep_markdown_and_database_aligned.md) — tracks the upstream GSD fix
- GSD source: `gsd-db.ts` — database schema and query functions
- GSD source: `reassess-roadmap.ts` — slice addition logic
- GSD source: `markdown-renderer.ts` — roadmap rendering from DB

### Troubleshooting: Roadmap reverts to wrong ordering

If the roadmap slice order reverts after a `gsd_*` tool call:

#### Slices appear in wrong order after tool re-render

Symptoms: Roadmap shows slices in the database sequence order, not the logical order you intended. Boundary map collapses to a single line with escaped `\n` characters.

Solution:

- Re-edit the roadmap markdown to fix the ordering (this is expected — it happens every time)
- Verify `depends:[]` references are correct
- Fix the boundary map newlines
- Fix any bare slice titles that reverted

#### New slice has duplicate sequence number

Symptoms: Two slices have the same `sequence` value in the DB (visible in `.gsd/state-manifest.json`)

Impact: Low — display order within same-sequence slices falls back to alphabetical ID ordering. But the visual order in the roadmap will not match the intended logical order.

Solution: No tool-supported fix exists. The duplicate sequence is a cosmetic DB issue. Rely on manual markdown ordering for display and `depends:[]` in markdown for execution order.
