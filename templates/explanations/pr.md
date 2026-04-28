<!--
**Style Guidelines (Strict):**

- Treat this document as a template to be filled, not redesigned.
- Replace placeholder text completely; do not leave generic filler.
- Keep wording concise, specific, and scoped to this document's topic.
- Use bulleted lists with `-` instead of numbered lists for easy reordering.
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`).
- Keep headings descriptive so steps can be rearranged without renumbering.
- Change section headings must be concise, descriptive titles (3-7 words).
- Placeholder headings such as `### Change 1` and `### Change 2` must be replaced with topic-specific titles before completion.
- Use `####` subheadings for subsections instead of bold text with numbers.

**Purpose Section Requirement:**
- Rewrite the Purpose questions so they explicitly describe what this specific PR explains.
- Do not keep generic Purpose questions if they are template placeholders.
- Frame questions from the reviewer's perspective: "What problem does this solve?", "What changed?", "What didn't change?", "What do I need to watch for going forward?"

**Linking Rules:**
- Every reference in Related Topics must be a real link (no placeholder bullets).
- **Code**: Link to GitHub with line numbers: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123).
- **Commits**: Link to specific commits: [`short-message`](https://github.com/org/repo/commit/full-sha).
- **Docs**: Link to official documentation pages.
- **Local**: Link to local docs with relative paths.

**Changes Section Requirement (the core of this template):**
- Each change section must follow the Problem → Fix → Commit structure:
  1. **Problem**: What was broken or needed, with code evidence showing the issue.
  2. **Fix**: What was done, with code evidence showing the solution.
  3. **Commit**: Link to the commit(s) that implement this change.
- Each change section must begin with a concise summary title (3-7 words) as the section heading.
- For each change,
  - Create a summary title for the change
  - include BOTH a source link to real code (with line numbers), and a short "Code Sample" block that clarifies intent.
- The "Code Sample" may be:
  - A minimal real excerpt, or
  - A simplified pseudocode version with brief comments.
- The sample must explain behavior, not just repeat syntax.
- Keep samples small and focused (about 5-20 lines).
- Add 1-3 bullets under each sample explaining:
  - what the code is doing,
  - why it matters for the reviewer,
  - and any important caveat/assumption.
- Never fabricate APIs or behavior; if code cannot be verified, explicitly state that and omit the sample.

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

For the following information make sure to add a URL link with location. For example, if the reference is a git URL then include the full URL plus line numbers; if a website document then point to the appropriate document; if simply a reference to another local markdown document, then point to it locally:

- Link to related concepts.
- Link to relevant how-tos.
- Link to reference docs.
- Link to backout/removal docs for any temporary workarounds.
