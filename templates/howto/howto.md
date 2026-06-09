<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Purpose Section Requirement:**
- Rewrite the Purpose questions so they explicitly describe what this specific document explains.
- Do not keep generic Purpose questions if they are template placeholders.

**Concept-Mapped Code Snippets (required when a companion explanation doc exists):**
- When the howto has a companion explanation document, each code snippet or proof script must map to a specific named concept from that explanation.
- Open each step's section with a **Key concept:** line that names the concept being demonstrated and links to the explanation doc using a wiki link.
- Keep one concept per snippet — split multi-concept scripts into separate files so each is self-contained and independently runnable.
- The sequence of snippets should build progressively, each adding one concept on top of the previous.

**Final Compliance Check (required before finishing):**
- Heading structure unchanged.
- Placeholder text removed.
- Purpose questions are document-specific.
- Related Topics links are all concrete and valid.
- Each code reference includes both a link and an explanatory code sample.
- File setup instructions use “Create <file>” + code block format (no `cat > ...` heredoc flow).
- If a companion explanation exists, every code snippet has a **Key concept:** line linking to it.
-->

# {{title}}

## Description

A brief overview of what this guide helps the reader achieve.

## Prerequisites

List any setup steps, dependencies, or prior knowledge needed before following this guide.

## Usage

```bash
# step 1
some-command --option value

# step 2

# step 3
```

## Appendix

### Sample usage output

```bash
```

### Related Resources

- Reference to code
- Reference to online documentation
- Reference to local documentation

### Troubleshooting: Common Issue Name

If you encounter [specific error or situation]:

#### Symptom Name

Symptoms: Description of what the user sees

Solution:

- First troubleshooting step
- Second troubleshooting step
- Third troubleshooting step
