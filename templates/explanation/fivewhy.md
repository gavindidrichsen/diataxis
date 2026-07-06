<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Subject Requirement (the analysis traces one problem to its root cause):**
- This document performs a single 5 Whys investigation on one specific, well-defined problem. Do not bundle multiple unrelated symptoms into one analysis.
- Each "Why" answer must be evidence-based (a log line, a stack trace, a reproduction step, a code reference) — not a guess. If an answer can't be verified, say so and stop; a fabricated chain produces a fabricated root cause.
- Keep the chain causal: each Why's answer becomes the subject of the next Why. Do not jump levels or answer a different question than the one just asked.
- Focus on process and system causes, not individual blame. "The deploy script didn't validate config before applying it" is a root cause; "Alice made a mistake" is not.
- Five is a guideline, not a rule: stop as soon as the answer is something the team can act on, and fixing it would plausibly prevent the symptom from recurring. Continue past five if the chain is still surface-level.

**Purpose Section Requirement:**
- Rewrite the Purpose questions so they explicitly describe what this specific investigation traces and resolves.
- Do not keep generic Purpose questions if they are template placeholders.

**Root Cause Analysis Section Requirement:**
- Number each Why sequentially (Why 1, Why 2, ...) and title each with the specific question asked, not a placeholder.
- State the evidence for each answer before moving to the next Why.
- Add or remove Why steps to match the chain actually investigated — do not pad to exactly five.

**Root Cause & Solution Requirement:**
- "Root Cause" states the final, verified cause in one or two sentences — the thing that, if fixed, prevents the symptom from recurring.
- "Solution" addresses the root cause, not the symptom described in Background. If a temporary mitigation was also applied, name it separately from the durable fix.

**Final Compliance Check (required before finishing):**
- Heading structure unchanged.
- Placeholder text removed.
- Purpose questions are document-specific.
- Each Why step has evidence, not speculation.
- Root Cause is a single verifiable statement, not another symptom.
- Solution targets the root cause.
- Related Topics links are all concrete and valid.
- Each code reference includes both a link and an explanatory code sample.
- File setup instructions use "Create <file>" + code block format (no `cat > ...` heredoc flow).
-->

# {{title}}

## Purpose

This document traces one problem to its root cause using the 5 Whys technique. It answers:

- What was the observed symptom, and how was it detected?
- What causal chain connects that symptom to its root cause?
- What fixes the root cause — not just the symptom?

## Background

The symptom as first observed: what broke, what the impact was, and how it was noticed (a failing test, an alert, a user report)...

## Root Cause Analysis

> Work through the chain one verified answer at a time. Each Why's answer becomes the subject of the next Why. Stop when the answer is something actionable that would prevent recurrence — that may take fewer or more than five iterations.

### Why 1: Why did [symptom] happen?

Answer, with evidence...

**Code Location** (if relevant): permalink to source — commit-SHA-pinned, not `blob/main`: [`filename:line`](https://github.com/org/repo/blob/<commit-sha>/path/file.rb#L123)

### Why 2: Why did [answer to Why 1] happen?

Answer, with evidence...

### Why 3: Why did [answer to Why 2] happen?

Answer, with evidence...

## Root Cause

State the verified root cause in one or two sentences — the thing that, if fixed, prevents this problem from recurring.

## Solution

Explain the fix that addresses the root cause, not just the symptom. If a temporary mitigation was applied first, name it separately from the durable fix.

## Related Topics

- Related concepts, how-tos, and reference docs links go here.
