<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Subject Requirement (the analysis traces one problem to its root cause):**
- This document performs a single 5 Whys investigation on one specific, well-defined problem. Do not bundle multiple unrelated symptoms into one analysis.
- Each "Why" answer must be evidence-based (a log line, a stack trace, a reproduction step, a code reference) — not a guess. If an answer can't be verified, say so and stop; a fabricated chain produces a fabricated root cause.
- Keep the chain causal: each Why's answer becomes the subject of the next Why. Do not jump levels or answer a different question than the one just asked.
- Focus on process and system causes, not individual blame. "The deploy script didn't validate config before applying it" is a root cause; "Alice made a mistake" is not.
- Five is a guideline, not a rule: stop as soon as the root cause is proven (see Root Cause requirement below). Continue past five if the chain is still surface-level.

**Purpose Section Requirement:**
- Rewrite the Purpose questions so they explicitly describe what this specific investigation traces and resolves.
- Do not keep generic Purpose questions if they are template placeholders.

**Root Cause Analysis Section Requirement (transparency of method is mandatory):**
- Number each Why sequentially (Why 1, Why 2, ...) and title each with the specific question asked, not a placeholder.
- Each Why must open with **Why This Tool**: one sentence justifying the choice of tool/command *before* showing it — what it can tell you that a faster or more obvious alternative couldn't, or why it was the most direct way to answer this specific question. This is reasoning, not narration; "because it shows X and this Why is about X" beats "let's check the logs."
- Each Why must show its **Investigation**: the actual tool(s), command(s), or process used to dig into or replicate that specific question — not just the answer. Prefer one fenced shell block with a comment on each step explaining what that step checks and why. If a GUI, dashboard, or doc was consulted instead of a command, name it and link it.
- Each Why must show its **Evidence**: the exact signal the investigation produced (a quoted log line, error message, exit code, metric, or doc excerpt) — the thing that actually justifies the Answer, not a paraphrase of it.
- Each Why must close with **Next Problem**: one sentence naming the next question to chase. This is what the next Why heading is built from — a reader should be able to predict the next heading from this line before turning the page.
- Do not skip Why This Tool/Investigation/Evidence because the answer "seems obvious" — an unverified link in the chain invalidates everything built on top of it.
- Add or remove Why steps to match the chain actually investigated — do not pad to exactly five.

**Root Cause & Solution Requirement (provenance is mandatory, not just proof):**
- "Root Cause" states the final cause in one or two sentences — the thing that, if fixed, prevents the symptom from recurring.
- Root Cause requires **Proof**, not assertion: describe the specific check that confirmed this is the actual root cause and not just the deepest symptom reached (e.g. reverting the fix reproduces the original symptom, a minimal repro isolates exactly this cause, removing this factor alone stops the failure). State what was done and what result confirmed it.
- Root Cause requires **Known Issue?**: state explicitly whether this matches a previously documented issue — link the tracker ticket, changelog entry, vendor advisory, or prior incident doc that confirms it. If no prior report exists, say so plainly ("No prior report found — this root cause is derived solely from the Investigation trail above") rather than leaving provenance ambiguous.
- "Solution" addresses the root cause, not the symptom described in Background. If a temporary mitigation was also applied, name it separately from the durable fix.
- Solution requires **Source**: cite where the fix came from — official docs, a changelog, a prior commit/PR, a vendor-recommended workaround — with a link. If there was no precedent and the fix was derived independently from the Root Cause, say so explicitly.

**Final Compliance Check (required before finishing):**
- Heading structure unchanged.
- Placeholder text removed.
- Purpose questions are document-specific.
- Every Why has Why This Tool, Investigation (tool/command shown), Evidence (the actual signal), and Next Problem.
- Root Cause includes Proof and Known Issue?, not just a claim.
- Solution targets the root cause and includes Source.
- Related Topics links are all concrete and valid.
- Each code reference includes both a link and an explanatory code sample.
- File setup instructions use "Create <file>" + code block format (no `cat > ...` heredoc flow).
-->

# {{title}}

## Purpose

This document traces one problem to its root cause using the 5 Whys technique. It answers:

- What was the observed symptom, and how was it detected?
- What causal chain connects that symptom to its root cause, and how was each link verified?
- What proves this is the true root cause, and what fixes it — not just the symptom?

## Background

The symptom as first observed: what broke, what the impact was, and how it was noticed (a failing test, an alert, a user report)...

## Root Cause Analysis

> Work through the chain one verified answer at a time. Each Why must justify its tool choice, show the tooling used to dig into it, the evidence that tooling produced, and the next problem that evidence points to. Stop when the root cause is proven — that may take fewer or more than five iterations.

### Why 1: Why did [symptom] happen?

**Why This Tool**: Why this specific tool/command is the right way to answer this question — what it reveals that a faster or more obvious alternative couldn't.

**Investigation**:

```bash
# Step 1: reproduce/observe the symptom directly
command-one --flag   # what this step checks, and why it's the right first move

# Step 2: narrow down using what step 1 revealed
command-two path/to/thing   # what signal this surfaces
```

**Evidence**: Quote the exact signal the investigation surfaced (log line, error message, exit code, metric, or doc excerpt) — the thing that actually proves the Answer below, not a paraphrase of it.

**Answer**: The conclusion this evidence supports.

**Code Location** (if relevant): permalink to source — commit-SHA-pinned, not `blob/main`: [`filename:line`](https://github.com/org/repo/blob/<commit-sha>/path/file.rb#L123)

**Next Problem**: The next question this evidence points to — this becomes the subject of Why 2.

### Why 2: Why did [answer to Why 1] happen?

**Why This Tool**: ...

**Investigation**:

```bash
# Step 1: dig into the specific claim from Why 1's Next Problem
command-three ...   # what this checks
```

**Evidence**: The signal that answers this Why.

**Answer**: The conclusion this evidence supports.

**Next Problem**: The next question this evidence points to — this becomes the subject of Why 3.

### Why 3: Why did [answer to Why 2] happen?

**Why This Tool**: ...

**Investigation**: ...

**Evidence**: ...

**Answer**: ...

**Next Problem**: ...

## Root Cause

State the verified root cause in one or two sentences — the thing that, if fixed, prevents this problem from recurring.

**Proof**: Describe the specific check that confirmed this is the actual root cause, not just the deepest symptom reached — what was done (reverted, isolated, reproduced from a minimal case) and what result confirmed it.

**Known Issue?**: State whether this matches a previously documented issue, with a link to the tracker ticket, changelog, vendor advisory, or prior incident doc that confirms it — or state plainly that no prior report was found and this root cause is derived solely from the Investigation trail above.

## Solution

Explain the fix that addresses the root cause, not just the symptom. If a temporary mitigation was applied first, name it separately from the durable fix.

**Source**: Where this fix came from — official docs, a changelog, a prior commit/PR, a vendor-recommended workaround — with a link. If there was no precedent and the fix was derived independently from the Root Cause, say so explicitly.

## Related Topics

- Related concepts, how-tos, and reference docs links go here.
