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

How to insert a new slice into the middle of an in-progress GSD milestone, or reorder existing slices, while keeping the database and markdown artifacts aligned. This is a workaround for a known GSD limitation where new slices are always appended to the end — see the [project file](docs/_gtd/project_fix_gsd_slice_insertion_and_reordering_to_keep_markdown_and_database_aligned.md) tracking the fix.

## Prerequisites

- A GSD milestone that is already in progress (some slices completed, some pending)
- Understanding of the `.gsd/` directory structure (see `.gsd/PROJECT.md`)
- The `gsd_reassess_roadmap` tool available (used to add new slices)

## Usage

### Add a new slice between existing slices

Use `gsd_reassess_roadmap` to add the slice. It will be appended to the end of the roadmap. Then manually fix the ordering in the roadmap markdown.

```bash
# Use gsd_reassess_roadmap with sliceChanges.added to create the new slice
# The tool will assign it a sequence number after all existing slices
# Example: if S01-S05 exist, new slice gets sequence 6
```

After the tool creates the slice, the roadmap markdown will show it at the bottom. You need to manually edit the roadmap:

- Move the new slice entry to its correct position in the `## Slices` section
- Ensure `depends:[]` references are correct (the new slice should depend on the slice before it, and the slice after it should depend on the new slice)
- Update the `## Boundary Map` section to describe what the new slice produces and what downstream slices consume from it
- Verify the `S03 → S04` style headings in the boundary map reflect the new ordering

**Important:** The database `sequence` column still has the old ordering. The roadmap markdown will look correct, but the next time any `gsd_*` tool re-renders the roadmap from the database, your manual edits will be overwritten. To make the fix durable, you also need to update the database sequence values.

### Update database sequence values

GSD does not currently expose a tool for this. The workaround is to note that `gsd_plan_milestone` assigns sequence values based on input order — but re-planning an in-progress milestone risks losing completed slice state. For now, the safest approach is:

- Accept that the DB sequence may not match the markdown ordering
- Auto-mode dispatches by dependency graph (`depends:[]`), not by sequence — so execution order is correct as long as dependencies are right
- If the roadmap gets re-rendered by a `gsd_*` tool, you'll need to re-apply the manual ordering fix

### Reorder existing slices

There is no tool-supported way to reorder existing slices. The practical approach:

- Edit the roadmap markdown to reflect the desired order
- Ensure all `depends:[]` references form a valid DAG (no circular dependencies)
- Update the boundary map section to match
- Accept that the DB and markdown ordering may diverge (dependencies are what matter for execution)

### Add new tasks to an existing slice

Use `gsd_plan_task` to add tasks to an existing slice. This tool works correctly — tasks are added to the slice's task list and the plan markdown is updated. No manual fixup needed.

```bash
# gsd_plan_task adds tasks to an existing slice
# The slice must already exist (created via gsd_plan_slice or gsd_reassess_roadmap)
# Task sequence is assigned based on existing task count
```

## Appendix

### What can go wrong

The main failure mode is **DB/markdown drift**:
- You manually edit the roadmap markdown to fix ordering
- A `gsd_*` tool later re-renders the roadmap from the database
- Your manual edits are overwritten
- The roadmap reverts to the wrong ordering

The mitigation is to check the roadmap after any `gsd_*` operation that might re-render it, and re-apply the ordering fix if needed.

### Escaped newlines in boundary maps

When editing the roadmap markdown, be careful with the boundary map section. Some editors or tools may insert escaped `\n` literal strings instead of actual newlines. If you see `### S01 → S02\n\nProduces:` on a single line, replace the `\n` sequences with actual line breaks.

### Related Resources

- [Project: Fix GSD slice insertion and reordering](_gtd/project_fix_gsd_slice_insertion_and_reordering_to_keep_markdown_and_database_aligned.md) — tracks the upstream GSD fix
- GSD source: `gsd-db.ts` — database schema and query functions
- GSD source: `reassess-roadmap.ts` — slice addition logic
- GSD source: `markdown-renderer.ts` — roadmap rendering from DB

### Troubleshooting: Roadmap reverts to wrong ordering

If the roadmap slice order reverts after a `gsd_*` tool call:

#### Slices appear in wrong order after tool re-render

Symptoms: Roadmap shows slices in the database sequence order, not the logical order you intended

Solution:

- Re-edit the roadmap markdown to fix the ordering
- Verify `depends:[]` references are correct — auto-mode uses these, not position
- Check if a `gsd_*` tool triggered a roadmap re-render (look for recent `renderRoadmapFromDb` calls in the activity log)
