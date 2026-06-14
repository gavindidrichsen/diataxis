<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Subject Requirement (the explanation is about the domain, not the incident):**
- The subject of this document is the **domain knowledge revealed by the investigation**, not the bug/issue that triggered it. See the Orientation guideline above.
- "Background" is where the triggering problem lives — keep it brief: a sentence or two of context establishing what was being fixed and what surprised you. Do not let it grow into a bug report.
- "Key Concepts" is the heart of the document: each concept is a piece of how the domain actually works, that this investigation verified or clarified. Frame each as a durable truth about the system, then (optionally) note how the problem demonstrated it.

**Purpose Section Requirement:**
- Rewrite the Purpose questions so they explicitly describe what this specific document explains *about the domain*.
- Do not keep generic Purpose questions if they are template placeholders.

**Final Compliance Check (required before finishing):**
- Heading structure unchanged.
- Placeholder text removed.
- Purpose questions are document-specific.
- Related Topics links are all concrete and valid.
- Each code reference includes both a link and an explanatory code sample.
- File setup instructions use “Create <file>” + code block format (no `cat > ...` heredoc flow).
-->

# {{title}}

## Purpose

This document answers:

- What does this reveal about how the domain actually works?
- What are the core concepts, and how do the pieces fit together?
- Why does the system behave this way — and what would still be worth knowing if the triggering problem disappeared?

## Background

The problem that set up this investigation (keep it brief — this is context, not the subject): what was being fixed, and what about the system's behaviour was surprising or unclear...

## Key Concepts

> The durable knowledge. Each concept is a truth about how the domain works that this investigation verified or clarified — state it as a domain fact first, then optionally how the problem demonstrated it.

### Concept 1

Explain the first key concept...

**Code Location** (if relevant): Link to source code using format [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)

### Concept 2

Explain the second key concept...

**Code Location** (if relevant): Link to source code using format [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)

## Related Topics

- Related concepts, how-tos, and reference docs links go here.
