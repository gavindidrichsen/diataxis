<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Purpose Section Requirement:**
- Rewrite the Purpose questions so they explicitly describe what this specific PR explains.
- Do not keep generic Purpose questions if they are template placeholders.
- Frame questions from the reviewer's perspective: "What problem does this solve?", "What changed?", "What didn't change?", "What do I need to watch for going forward?"

**Additional Linking Rules:**
- **Commits**: Link to specific commits: [`short-message`](https://github.com/org/repo/commit/full-sha).

**Changes Section Requirement (the core of this template):**
- Each change section must follow the Problem → Fix → Commit structure:
  1. **Problem**: What was broken or needed, with code evidence showing the issue.
  2. **Fix**: What was done, with code evidence showing the solution.
  3. **Commit**: Link to the commit(s) that implement this change.

**What Did NOT Change Section Requirement:**
- Every PR description must include a "What Did NOT Change" section.
- This reassures reviewers about the blast radius of the changes.
- List the boundaries explicitly: what systems, behaviours, and contracts remain untouched.

**Final Compliance Check (required before finishing):**
- Heading structure follows this template.
- Placeholder text removed.
- Purpose questions are PR-specific.
- Related Topics links are all concrete and valid.
- Each change section includes Problem, Fix, and Commit link.
- Each code reference includes both a link and an explanatory code sample.
- "What Did NOT Change" section is present and specific.
-->

# {{title}}

## Purpose

This PR answers:

- What problem does this solve?
- What changed and why?
- What did NOT change? (blast radius)
- What temporary measures were introduced, and when do they go away?

## Background

Explain the context: why this work was needed, what the current state is, and what state this PR moves us to...

## Changes

### Change 1: Descriptive Title

#### Problem

Explain what was broken or needed. Show the problematic code or behaviour.

**Code Location**: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)

```ruby
# Show the problematic code or behaviour
```

- What this code does and why it's a problem.

#### Fix

Explain what was done to solve it.

**Code Location**: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)

```ruby
# Show the fix
```

- What the fix does and why this approach was chosen.
- Any caveats or assumptions.

**Commit**: [`short commit message`](https://github.com/org/repo/commit/full-sha)

---

### Change 2: Descriptive Title

#### Problem

...

#### Fix

...

**Commit**: [`short commit message`](https://github.com/org/repo/commit/full-sha)

## What Did NOT Change

It is important to understand the boundaries of this work:

- List unchanged systems, behaviours, and contracts here.
- This reassures reviewers about blast radius.

## Related Topics

- Related concepts, how-tos, reference docs, and backout/removal docs links go here.
