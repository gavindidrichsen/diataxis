<!--
# Common Guidelines
**Style Guidelines (Strict):**

- Treat this document as a template to be filled, not redesigned.
- Replace placeholder text completely; do not leave generic filler.
- Keep wording concise, specific, and scoped to this document's topic.
- Use bulleted lists with `-` instead of numbered lists for easy reordering.
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`).
- Keep headings descriptive so steps can be rearranged without renumbering.

**Heading Rules:**
- All `###` and lower subheadings must be concise, descriptive titles (3-7 words).
- Placeholder headings (e.g., `### Concept 1`, `### Change 1`) must be replaced with topic-specific titles before completion.
- Use `####` subheadings for subsections instead of bold text with numbers.

**Linking Rules:**
- Every reference in Related Topics must be a real link (no placeholder bullets).
- **Code**: Link to GitHub with line numbers: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123).
- **Docs**: Link to official documentation pages.
- **Local**: Link to local docs with relative paths.

**Code Evidence Requirement (required when code is referenced):**
- For each major section,
  - include BOTH a source link to real code (with line numbers), and a short "Code Sample" block that clarifies intent.
- The "Code Sample" may be:
  - A minimal real excerpt, or
  - A simplified pseudocode version with brief comments.
- The sample must explain behavior, not just repeat syntax.
- Keep samples small and focused (about 5-20 lines).
- Add 1-3 bullets under each sample explaining:
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

# Consolidate common template directives into common.metadata

## Purpose

This PR answers:

- Why were 7 of 9 templates carrying identical directive blocks?
- How does the new `common.metadata` consolidation work?
- What naming inconsistencies were resolved alongside the consolidation?
- What did NOT change? (template output, test contracts, CLI behaviour)

## Background

Every diataxis template carries an HTML comment block with style directives that guide AI-generated content. Over time, Linking Rules, Code Evidence Requirements, Heading Rules, and File Setup Formatting were copy-pasted into 7+ templates verbatim. A `{{common.metadata}}` placeholder mechanism already existed in `TemplateLoader` but only covered basic style guidelines. This PR extends it to cover all truly shared directives and strips the duplicates.

Separately, the 5-why template was registered as `fivewhyanalysis.md` with config_key `five_why_analyses` — inconsistent with the CLI command `5why` and file prefix `5why_`. This PR aligns the naming.

## Changes

### Extend common.metadata with shared directives

[`3632818`](https://github.com/puppetlabs/diataxis/commit/3632818dfe71b3d1409251ae2a96a9ebdfa53e48)

#### Problem

Linking Rules (Code/Docs/Local), Code Evidence Requirement (7 sub-points), Heading Rules, and File Setup Formatting were duplicated across 7 templates. Any update required editing every file.

**Code Location**: [`templates/common.metadata`](https://github.com/puppetlabs/diataxis/blob/development/templates/common.metadata)

```markdown
**Heading Rules:**
- All `###` and lower subheadings must be concise, descriptive titles (3-7 words).
- Placeholder headings must be replaced with topic-specific titles.
- Use `####` subheadings for subsections instead of bold text with numbers.

**Linking Rules:**
- Every reference in Related Topics must be a real link.
- **Code**: Link to GitHub with line numbers.
- **Docs**: Link to official documentation pages.
- **Local**: Link to local docs with relative paths.
```

- These four directive blocks are now the single source of truth in `common.metadata`.
- Templates that need extras (e.g. pr.md adds Commits, adr.md adds Related ADRs, 5why.md adds Issues) keep only the additions.

#### Fix

Moved all four directive blocks into `templates/common.metadata`. Stripped the duplicated text from explanation, pr, howto, tutorial, note, handover, and project templates. Each template now has `{{common.metadata}}` in its Common Guidelines section and only template-specific rules below.

**Code Location**: [`templates/references/note.md:1-7`](https://github.com/puppetlabs/diataxis/blob/development/templates/references/note.md#L1-L7)

```markdown
<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines
(No additional template-specific guidelines.)
-->
```

- Templates with no extra rules get a clean "(No additional)" marker.
- `TemplateLoader.load_template` resolves `{{common.metadata}}` before `{{title}}`/`{{date}}` substitutions — no code changes needed.

---

### Convert adr.md to use common.metadata

[`3632818`](https://github.com/puppetlabs/diataxis/commit/3632818dfe71b3d1409251ae2a96a9ebdfa53e48)

#### Problem

`adr.md` was the only template not using the `{{common.metadata}}` mechanism, carrying its own inline directives.

#### Fix

Converted adr.md to use `{{common.metadata}}` with a template-specific "Related ADRs" linking rule. Updated `template_loader_spec.rb` expectations since the resolved content now includes the full common metadata block.

**Code Location**: [`templates/references/adr.md:1-9`](https://github.com/puppetlabs/diataxis/blob/development/templates/references/adr.md#L1-L9)

```markdown
<!--
# Common Guidelines
{{common.metadata}}

# Template-Specific Guidelines

**Additional Linking Rules:**
- **Related ADRs**: Link to other ADRs: [ADR-0001](./0001-title.md).
-->
```

---

### Rename fivewhyanalysis to 5why

[`3632818`](https://github.com/puppetlabs/diataxis/commit/3632818dfe71b3d1409251ae2a96a9ebdfa53e48), [`4213796`](https://github.com/puppetlabs/diataxis/commit/4213796b7200905b944f8004ed7fa0ff35f1455e)

#### Problem

The template was `fivewhyanalysis.md`, the config_key was `five_why_analyses`, and the readme_section was `Five Why Analyses` — but the CLI command was `5why` and files were prefixed `5why_`. Inconsistent naming across the system.

#### Fix

Renamed `templates/references/fivewhyanalysis.md` → `templates/references/5why.md`. Updated `document_types.rb` registration:

**Code Location**: [`lib/diataxis/document_types.rb:73-80`](https://github.com/puppetlabs/diataxis/blob/development/lib/diataxis/document_types.rb#L73-L80)

```ruby
r.register(
  command: '5why',
  prefix: '5why',
  category: 'references',
  config_key: '5whys',
  readme_section: '5-Whys',
  template: '5why',
  section_tag: '5why'
)
```

- `config_key` changed from `'five_why_analyses'` to `'5whys'`.
- `readme_section` changed from `'Five Why Analyses'` to `'5-Whys'`.
- **Breaking**: existing `.diataxis` config files using `five_why_analyses` for a custom path must update to `5whys`.

## What Did NOT Change

- **Template output**: The rendered document content is identical — the directives live in HTML comments, not visible output.
- **CLI commands**: All `dia <type> new` commands work exactly as before.
- **Test suite**: All 46 tests pass without modification (except the `template_loader_spec.rb` assertion update for adr.md's new common metadata content).
- **TemplateLoader resolution logic**: No changes to `template_loader.rb` — the `{{common.metadata}}` mechanism already handled substitution.
- **Document class hierarchy**: `Document`, `ADR`, `HowTo`, and the registry DSL are untouched.
- **Non-5why config keys**: All other config keys (`explanations`, `tutorials`, `howtos`, `handovers`, `notes`, `projects`, `adr`) are unchanged.

## Related Topics

- [ADR-0012: Move to external template system](docs/adr/0012-move-to-external-template-system-with-direct-templateloader-usage.md) — established the `{{common.metadata}}` mechanism
- [`templates/common.metadata`](templates/common.metadata) — the consolidated directive file
- [`lib/diataxis/template_loader.rb`](lib/diataxis/template_loader.rb) — substitution logic
- [`lib/diataxis/document_types.rb`](lib/diataxis/document_types.rb) — type registry with 5why rename
