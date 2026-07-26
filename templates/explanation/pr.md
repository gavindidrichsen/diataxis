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
- Each change section has a descriptive heading, followed immediately by the problem description as prose (no separate Problem subheading).
- Then a Fix subheading that embeds the commit link and, when the fix has a clear short title, that title follows the commit link on the same line:
  `#### Fix ([\`short-sha\`](https://github.com/org/repo/commit/full-sha)) Optional fix title`
- If the fix has no meaningful title, just use:
  `#### Fix ([\`short-sha\`](https://github.com/org/repo/commit/full-sha))`
- After the Fix heading, list what was done as bullet points or prose.

**What Did NOT Change Section Requirement:**
- Every PR description must include a "What Did NOT Change" section.
- This reassures reviewers about the blast radius of the changes.
- List the boundaries explicitly: what systems, behaviours, and contracts remain untouched.

**Final Compliance Check (required before finishing):**
- Heading structure follows this template.
- Placeholder text removed.
- Purpose questions are PR-specific.
- Related Topics links are all concrete and valid.
- Each change section has problem prose followed by a Fix heading with embedded commit link.
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

Explain what was broken or needed. Show the problematic code or behaviour with code samples where relevant.

#### Fix ([`short-sha`](https://github.com/org/repo/commit/full-sha)) Optional fix title

- What was done to solve it.
- Why this approach was chosen.
- Any caveats or assumptions.

---

### Change 2: Descriptive Title

Explain the problem as prose...

#### Fix ([`short-sha`](https://github.com/org/repo/commit/full-sha))

- What was done...

## What Did NOT Change

It is important to understand the boundaries of this work:

- List unchanged systems, behaviours, and contracts here.
- This reassures reviewers about blast radius.

## Related Topics

- Related concepts, how-tos, reference docs, and backout/removal docs links go here.
