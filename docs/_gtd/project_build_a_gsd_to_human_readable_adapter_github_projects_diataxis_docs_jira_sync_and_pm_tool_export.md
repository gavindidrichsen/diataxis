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

# Build a GSD-to-human-readable adapter: GitHub Projects, diataxis docs, Jira sync, and PM-tool export

**@urgent** tasks:

- [ ] Run `gh auth refresh -h github.com -s project` to add the `project` scope to the GitHub token
- [ ] Inspect the template board structure: `gh project view 9 --owner gavindidrichsen-puppetlabs --format json`
- [ ] Copy the template board to the personal account: `gh project copy 9 --source-owner gavindidrichsen-puppetlabs --target-owner gavindidrichsen --title "Diataxis Project Board"`

## Context

GSD (Get Shit Done) produces rich structured artifacts in `.gsd/` — milestones, slices, tasks, decisions, requirements, knowledge entries — stored as markdown files and a SQLite database. These artifacts are excellent for agent-driven execution but are not easily consumable by humans or existing project management tools.

This umbrella project aims to bridge GSD's internal world with four human-facing output channels:

1. **GitHub Projects V2 boards** — push milestones/slices as board items with status, priority, and custom fields
2. **Diataxis documentation** — graduate GSD artifacts (DECISIONS.md, KNOWLEDGE.md, milestone summaries) into proper diataxis-categorized docs (ADRs, how-tos, explanations, retrospectives) suitable for living alongside PRs and repos
3. **CSV/PM-tool export** — generate standard CSV or structured data for import into Asana, Linear, or any tool accepting tabular input
4. **Jira bidirectional sync** — push GSD milestones/slices/tasks to Jira as epics/stories/subtasks, pull Jira context (descriptions, acceptance criteria, comments) back into GSD, and keep status synchronized in both directions via the Atlassian Rovo MCP server

### Key discovery: `gh project copy`

GitHub CLI has a built-in `gh project copy` command that copies views, custom fields, draft issues, and workflows from one Project V2 board to another. This is the simplest path for Phase 1.

```bash
gh project copy <PROJECT_NUMBER> --source-owner <ORG_OR_USER> --target-owner <ORG_OR_USER> --title "New Board"
```

**Prerequisite:** The `project` OAuth scope must be added to the current token:

```bash
gh auth refresh -h github.com -s project
```

### Template board

The reference template board is at: https://github.com/orgs/gavindidrichsen-puppetlabs/projects/9

This board has the column layout, custom fields, and views that all future project boards should replicate.

## Existing related work

These project files already cover parts of this problem space:

| Project | Location | Covers |
|---|---|---|
| GSD-Jira Bidirectional Sync | `@INBOX/docs/gsd-tooling/project_building_gsd_jira_bidirectional_milestone_sync.md` | Pushing GSD milestone/slice status to Jira epics/stories via Rovo MCP |
| Rsync Hook ADR | `@INBOX/docs/adr/0001-gsd-rsync-hook-for-mirroring-gsd-artifacts-to-docs.md` | Auto-mirroring `.gsd/*.md` artifacts to `docs/gsd/` |
| KNOWLEDGE.md with Diataxis Subdirectories | `@INBOX/docs/gsd-tooling/project_building_a_knowledge_md_index_with_diataxis_subdirectories.md` | Organizing GSD knowledge into diataxis categories |
| Unified Reference Search | `@INBOX/docs/gsd-tooling/project_designing_unified_reference_search_and_project_linked_context.md` | Structured References sections linking GSD artifacts to external sources |
| GitHub Project Board Template | `diataxis/docs/_gtd/project_creating_a_github_project_board_template_and_copy_workflow_using_gh_cli.md` (issue [#32](https://github.com/gavindidrichsen/diataxis/issues/32)) | Copying a template board to a new repo using `gh project copy` |

## GSD artifact → human-readable doc mapping

| GSD Artifact | Diataxis Category | Human Output |
|---|---|---|
| `DECISIONS.md` entries | Reference (ADR) | `docs/adr/NNNN-decision-title.md` |
| `KNOWLEDGE.md` entries | How-to / Explanation | `docs/how_to_*.md` or `docs/understanding_*.md` |
| Milestone `CONTEXT.md` | Explanation (Design Doc / RFC) | `docs/understanding_*.md` or `docs/rfc/` |
| Milestone `SUMMARY.md` | Explanation (Retrospective) | `docs/understanding_*.md` |
| Slice `SUMMARY.md` | Reference (Changelog entry) | Aggregated into release notes |
| `REQUIREMENTS.md` | Reference | `docs/reference/requirements.md` |

## Phase 1: GitHub Projects adapter

**Goal:** Copy a template board and push GSD milestones/slices to it.

- [ ] Add `project` scope to `gh` token
- [ ] Inspect the template board (project 9 on `gavindidrichsen-puppetlabs`) — document its fields, views, and columns
- [ ] Use `gh project copy` to create a board on `gavindidrichsen/diataxis`
- [ ] Write a script or GSD hook that creates board items from milestones/slices using `gh project item-add` and `gh project item-edit`
- [ ] Create a `dia explanation new` doc in `@INBOX/docs/` explaining how `gh project` works for board management
- [ ] Update the cheatsheet at `@cheatsheets/git-gh.md` with a new "Projects V2" section covering `gh project list`, `copy`, `item-add`, `item-edit`, `field-list`, `view`

### Useful `gh project` commands

```bash
gh project list --owner <owner>
gh project view <number> --owner <owner> --format json
gh project field-list <number> --owner <owner>
gh project copy <number> --source-owner <src> --target-owner <dst> --title "Title"
gh project item-add <number> --owner <owner> --url <issue-or-pr-url>
gh project item-create <number> --owner <owner> --title "Title" --body "Body"
gh project item-edit --id <item-id> --project-id <proj-id> --field-id <fid> --single-select-option-id <oid>
```

## Phase 2: GSD → diataxis docs pipeline

**Goal:** Graduate GSD artifacts into proper diataxis-categorized documentation.

- [ ] Define which GSD artifacts map to which diataxis document types (see mapping table above)
- [ ] Extend the existing rsync hook (from the ADR) to also transform artifact content into diataxis template format
- [ ] Create `dia` commands or GSD hooks that auto-generate ADR files from new DECISIONS.md entries
- [ ] Create a graduation workflow: when a milestone completes, prompt to export CONTEXT.md as an explanation doc and SUMMARY.md as a retrospective
- [ ] Integrate with the KNOWLEDGE.md diataxis subdirectories project for organizing graduated knowledge

## Phase 3: CSV/PM-tool export

**Goal:** One-shot or scheduled export for import into Jira, Asana, Linear, or similar.

- [ ] Define a standard CSV schema: `Title, Description, Status, Type, Labels, Priority, Parent, DependsOn`
- [ ] Write a query against `.gsd/gsd.db` (using GSD tools, not raw sqlite3) that generates CSV output for milestones, slices, and tasks
- [ ] Test import into GitHub Projects (via `gh project item-create` loop), Jira (CSV import), and at least one other tool
- [ ] Extend the Jira sync project to use this CSV as a transport format where appropriate

## Phase 4: Jira bidirectional sync

**Goal:** Push GSD state to Jira and pull Jira context back into GSD, keeping both systems in sync.

This phase builds on the existing [GSD-Jira Bidirectional Milestone Sync](../../@troubleshooting/@INBOX/docs/gsd-tooling/project_building_gsd_jira_bidirectional_milestone_sync.md) project, which already has Phase 1 (manual push) scoped out and the Atlassian Rovo MCP tools identified.

### GSD → Jira mapping

| GSD Artifact | Jira Entity | Sync Direction |
|---|---|---|
| Milestone | Epic | GSD → Jira (status, summary, progress %) |
| Slice | Story | GSD → Jira (status, title, completion) |
| Task | Sub-task | GSD → Jira (status, summary evidence) |
| Decision (DECISIONS.md) | Epic comment / linked Confluence page | GSD → Jira |
| Jira description, acceptance criteria | Milestone/Slice CONTEXT.md | Jira → GSD |
| Jira comments (stakeholder feedback) | Slice/task context | Jira → GSD |

### Available Rovo MCP tools

The Atlassian Rovo MCP server is already configured:

- `searchJiraIssuesUsingJql` — find issues by JQL
- `getJiraIssue` — read a single issue with all fields
- `addCommentToJiraIssue` — post a comment
- `editJiraIssue` — update fields (status, description, labels)
- `createJiraIssue` — create new issues
- `addWorklogToJiraIssue` — log time
- `getTransitionsForJiraIssue` / `transitionJiraIssue` — move through workflow states
- `createIssueLink` — link related issues (epic→story, blocks, relates-to)

### Tasks

- [ ] Store Jira key in milestone metadata (e.g., `CONTEXT.md` frontmatter: `jira: BOLT-146`)
- [ ] Build manual "push update" workflow: read GSD state → format as Jira comment → post via `addCommentToJiraIssue`
- [ ] Build "pull context" workflow: read Jira issue → extract description/acceptance criteria → surface in GSD planning
- [ ] Create/update Jira stories from GSD slices when a roadmap is planned or reassessed
- [ ] Sync status transitions: when a GSD slice completes, transition the corresponding Jira story
- [ ] Build bidirectional link: Jira comment/field changes propagate back into GSD (via scheduled polling or GSD hook)
- [ ] Handle Jira ideas/initiatives: map Jira "Idea" issue types to GSD milestone candidates in `QUEUE.md`
- [ ] Document the Jira field-mapping conventions so teams can configure which Jira fields map to which GSD metadata

## Other Lists

**@backlog** tasks for later:

- [ ] Investigate whether GitHub Projects V2 has a bulk import API beyond single `item-create` calls
- [ ] Research Linear's API for direct GSD → Linear sync (simpler than Jira)
- [ ] Consider a `dia export gsd` command that reads `.gsd/` and generates all diataxis docs in one pass
- [ ] Investigate GitHub Actions workflow that auto-syncs GSD state to a project board on push
- [ ] Explore Jira Automation rules that could trigger GSD pulls (webhook → GSD hook)
- [ ] Map Jira "Idea" and "Initiative" issue types to GSD milestone candidates for intake workflows

**@someday** ideas to revisit:

- [ ] Bidirectional sync: changes on the GitHub board flow back to GSD artifacts
- [ ] Dashboard web page generated from GSD state (static HTML export)
- [ ] Integration with Notion API for teams that use Notion for project tracking

## Project Purpose

**Why does this project matter?**

GSD produces structured, machine-readable project artifacts that are excellent for agent-driven execution but invisible to humans using standard project management tools. This creates a gap: the agent knows exactly what's happening, but stakeholders, teammates, and future-you can't see the state of play without reading raw markdown files in `.gsd/`.

Bridging this gap means GSD work becomes visible in the tools humans already use — GitHub project boards, diataxis documentation repos, Jira, etc. — without manual transcription.

## Desired Outcome

**What does "done" look like?**

- A working `gh project copy` workflow that replicates the template board to any repo
- A script or hook that pushes GSD milestones/slices to a GitHub project board
- A documentation pipeline that graduates GSD artifacts into diataxis docs
- A CSV export that can be imported into at least two PM tools
- Bidirectional Jira sync: GSD milestones/slices push to Jira epics/stories, Jira context pulls back into GSD
- An explanation doc and cheatsheet section documenting the `gh project` CLI

## Background

**2026-04-29:** Project registered. Initial investigation revealed that `gh project copy` is the simplest path for board replication. The `project` OAuth scope needs to be added before any board operations work. The template board at `gavindidrichsen-puppetlabs/projects/9` has the desired column layout and fields. Five existing project files in the @INBOX docs already cover related ground (Jira sync, rsync hook, knowledge diataxis, unified references, board template copy). This umbrella project unifies them under four phases.

**Related GitHub issues:**
- [gavindidrichsen/diataxis#33](https://github.com/gavindidrichsen/diataxis/issues/33) — This umbrella project (GSD-to-human-readable adapter)
- [gavindidrichsen/diataxis#32](https://github.com/gavindidrichsen/diataxis/issues/32) — GitHub project board template and copy workflow
