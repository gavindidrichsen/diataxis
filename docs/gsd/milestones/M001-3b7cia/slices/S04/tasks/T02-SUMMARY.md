---
id: T02
parent: S04
milestone: M001-3b7cia
key_files:
  - spec/diataxis_spec.rb
key_decisions:
  - Used glob-based file discovery for project tests instead of exact path assertion, because the CLI update phase renames the file due to the template title prefix pattern
duration: 
verification_result: passed
completed_at: 2026-04-29T23:48:56.159Z
blocker_discovered: false
---

# T02: Add creation and content tests for project, 5why, and pr document types — 9 new examples covering file creation, template structure, and README updates

**Add creation and content tests for project, 5why, and pr document types — 9 new examples covering file creation, template structure, and README updates**

## What Happened

Added three new test contexts to `spec/diataxis_spec.rb` for the previously untested document types: `project`, `5why`, and `pr`. Each context follows the established handover/note pattern with three tests: file creation with correct filename prefix, template structure verification, and README section/link updates.

**project** — Uses glob-based file discovery for the assertion because the CLI's update phase renames the initial file (the template title `Project: {{title}}` causes `generate_filename_from_file` to produce a double-prefixed filename). Tests verify the file lands in `docs/_gtd` (per the `projects` config key in DEFAULT_CONFIG), contains key template sections (`## Context`, `## Project Purpose`, `## Desired Outcome`), and the README gets a `### Projects` section with the correct link.

**5why** — Straightforward: file at `docs/5why_server_crash.md`, content includes `# Server Crash`, `## Problem Statement`, `## Analysis`, `## References`. README gets `### Five Why Analyses` section.

**pr** — Uses the `explanation` config_key so files land in `docs/`. File at `docs/pr_fix_login_bug.md`, content includes `# Fix Login Bug`, `## Purpose`, `## Background`, `## Changes`. README gets `### Pull Requests` section.

Test count went from 37 to 46 examples (9 new), all passing.

## Verification

Ran `bundle exec rspec spec/diataxis_spec.rb` — 46 examples, 0 failures (0.25s). Ran `bundle exec rspec` — 46 examples, 0 failures (0.19s). Ran `bundle exec cucumber` — 6 scenarios, 39 steps, all passed (1.81s). All three verification commands from the task plan pass.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bundle exec rspec spec/diataxis_spec.rb` | 0 | ✅ pass | 246ms |
| 2 | `bundle exec rspec` | 0 | ✅ pass | 193ms |
| 3 | `bundle exec cucumber` | 0 | ✅ pass | 1808ms |

## Deviations

None

## Known Issues

The project document type has a double-prefix rename issue during creation (project_test_project.md → project_project_test_project.md) caused by the template title format `Project: {{title}}` — this is pre-existing behavior, not introduced by this task.

## Files Created/Modified

- `spec/diataxis_spec.rb`
