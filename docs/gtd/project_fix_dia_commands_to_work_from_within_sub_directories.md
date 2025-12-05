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

# Project: Fix dia commands to work from within sub-directories

**@urgent** tasks:

- [ ] Review the walk-up implementation approach vs. root-only enforcement
- [ ] Decide on the preferred solution (walk-up vs. root-only)
- [ ] Create ADR-0015 documenting the decision
- [ ] Re-implement chosen solution

## Context

Currently, diataxis commands fail or behave incorrectly when run from subdirectories. For example:

- Rename a document in `docs/gtd/`
- `cd` into `docs/gtd/`
- Run `dia update .`

The command uses the current directory as the config root, not the actual project root where `.diataxis` exists. This causes incorrect behavior because commands use `Dir.pwd` or the argument directory directly instead of finding the project root.

### Root Cause

Commands in [`lib/diataxis/cli/command_handlers.rb`](https://github.com/gavindidrichsen/diataxis/blob/development/lib/diataxis/cli/command_handlers.rb) use `Dir.pwd` or explicit directory arguments without leveraging the existing `Config.find_config(start_dir)` method that already walks up the directory tree.

## Other Lists

These hold my other actions so I can know they're recorded but "forget" about them to reduce cognitive load.

**@waiting** for these tasks:

- [ ] User decision on approach: walk-up vs. root-only

**@backlog** tasks for later:

- [ ] Update user documentation with final behavior
- [ ] Consider if `dia update` should work differently from other commands
- [ ] Fix markdown_utils test discovery issue (pre-existing, 15 tests not running in default suite)

**@someday** ideas to revisit:

- [ ] Add `--root` flag to explicitly specify project root
- [ ] Add `dia root` command to display current project root

## Project Purpose

**Why does this project matter?**

Users expect CLI tools to work from any subdirectory within a project (like git, npm, bundler). Currently diataxis breaks this expectation, causing confusion and incorrect operations when run from subdirectories.

## Desired Outcome

**What does "done" look like?**

Like git, npm, and other modern CLI tools, diataxis should:

- Walk up the directory tree to find `.diataxis`
- Use that directory as the project root for all operations
- Fail gracefully with a clear error if no `.diataxis` is found
- Work consistently regardless of which subdirectory you run commands from

**OR**

Diataxis should explicitly require running from the project root and fail fast with a clear message when run from elsewhere.

## Background

### Implementation Attempt (Rolled Back)

A complete walk-up solution was implemented with these changes to [`lib/diataxis/cli/command_handlers.rb`](https://github.com/gavindidrichsen/diataxis/blob/development/lib/diataxis/cli/command_handlers.rb):

- Added `find_project_root(start_dir)` method that:
  - Calls `Config.find_config(start_dir)` to walk up the tree
  - Returns `File.dirname(config_path)` if found
  - Raises clear `FileSystemError` if not found
- Updated all 8 command handlers (`handle_howto`, `handle_tutorial`, `handle_adr`, `handle_explanation`, `handle_handover`, `handle_five_why`, `handle_note`, `handle_project`) to call `find_project_root` first
- Changed `create_document_with_readme_update` to use keyword arguments (`document_class:`, `config_key:`, `readme_types:`, `directory:`)
- Modified `handle_update` to accept optional `start_dir` parameter

Tests were added to [`spec/diataxis_spec.rb`](https://github.com/gavindidrichsen/diataxis/blob/development/spec/diataxis_spec.rb):

- Test 1: Creates documents from subdirectory (verifies find_project_root works)
- Test 2: Runs `dia update` from subdirectory (verifies update command works)
- Test 3: Fails with clear error when no `.diataxis` exists (verifies error handling)

All 38 tests passed (35 existing + 3 new subdirectory tests).

### Rollback Reason

Decided to document and validate the approach before committing. Questions to answer:

- Is walk-up behavior what users actually want?
- Should commands only work from project root for clarity and predictability?
- What are the edge cases and gotchas with walk-up behavior?
- How do other Ruby CLI tools handle this?

### Decision Points

**Option 1: Walk-Up Behavior (Like Git)**

Pros:
- Matches user expectations from other tools
- More convenient workflow
- Implementation ready and tested

Cons:
- May confuse users about which `.diataxis` is being used
- Could mask configuration issues
- More complex error scenarios

**Option 2: Root-Only Enforcement**

Pros:
- Simple and explicit
- No ambiguity about project context
- Easier to reason about

Cons:
- Less convenient
- Breaks common workflow patterns
- Users need to remember to `cd` to root

**Option 3: Hybrid Approach**

- Update command works from anywhere (walk-up)
- Create commands require root directory (explicit)
- Provides clear error messages guiding users
