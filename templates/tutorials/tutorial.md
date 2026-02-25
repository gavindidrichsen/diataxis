<!--
**Style Guidelines (Strict):**

- Treat this document as a template to be filled, not redesigned.
- Keep the existing section order and heading levels exactly as written.
- Do not add, remove, or rename sections unless explicitly requested.
- Replace placeholder text completely; do not leave generic filler.
- Keep wording concise, specific, and scoped to this document’s topic.
- Use bulleted lists with `-` instead of numbered lists for easy reordering.
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`).
- Keep headings descriptive so steps can be rearranged without renumbering.
- Key concept headings must be concise, descriptive titles (3-7 words).
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

# {{title}}

## Learning Objectives

What the reader will learn from this tutorial.

## Prerequisites

What the reader needs to know or have installed before starting.

## Tutorial

Step-by-step instructions...

## Related Resources

When referencing code or documentation:
- **Code**: Link to GitHub with line numbers: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)
- **Docs**: Link to official documentation: [Tool Documentation](https://example.com/docs)
- **Local**: Link to local docs: [Related Tutorial](../tutorial_other_guide.md)
