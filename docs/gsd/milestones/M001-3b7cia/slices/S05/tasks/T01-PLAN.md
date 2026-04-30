---
estimated_steps: 30
estimated_files: 4
skills_used: []
---

# T01: Add common.metadata to note and fivewhyanalysis templates and normalize reference sections

## Description

Two of 9 templates (`note.md`, `fivewhyanalysis.md`) lack the `{{common.metadata}}` HTML comment wrapper that the other 6 non-ADR templates use. This task adds the wrapper to these two templates for consistency, and normalizes the reference section heading across templates. `project.md` is left as-is because its GTD-specific HTML comment serves a different purpose (philosophy guide, not style rules). `adr.md` is left as-is because it follows the community ADR standard format.

**Auto-mode assumption:** Adding `{{common.metadata}}` to `note.md` and `fivewhyanalysis.md` is non-controversial since 6 of 7 non-ADR templates already have it. The project template's GTD metadata serves a distinct purpose and should not be conflated with common.metadata (per D004). ADR format is a community standard. These decisions will be documented for user review.

## Steps

1. Read `templates/references/note.md` and add an HTML comment wrapper at the top with `# Common Guidelines` / `{{common.metadata}}` / `# Template-Specific Guidelines` matching the pattern used in `explanation.md`, `handover.md`, `pr.md`, etc.
2. Read `templates/references/fivewhyanalysis.md` and add the same HTML comment wrapper at the top.
3. Verify the `TemplateLoader` resolves `{{common.metadata}}` correctly by running `bundle exec rspec` — the existing tests exercise template loading for all types.
4. Run `bundle exec cucumber` to confirm no behavioral regressions.
5. Verify the generated output by inspecting what `dia new note` and `dia new 5why` produce in a temp directory — confirm the common.metadata content appears in the HTML comment.

## Must-Haves

- [ ] `templates/references/note.md` has `<!--\n# Common Guidelines\n{{common.metadata}}\n...-->` wrapper at top
- [ ] `templates/references/fivewhyanalysis.md` has the same wrapper at top
- [ ] `templates/references/project.md` is NOT modified (GTD metadata is intentionally distinct)
- [ ] `templates/references/adr.md` is NOT modified (community standard format)
- [ ] All 46 rspec examples pass
- [ ] All 6 cucumber scenarios pass

## Verification

- `bundle exec rspec` — 46 examples, 0 failures
- `bundle exec cucumber` — 6 scenarios, all passed
- `grep -c 'common.metadata' templates/references/note.md` returns 1
- `grep -c 'common.metadata' templates/references/fivewhyanalysis.md` returns 1

## Inputs

- `templates/references/note.md` — current template without common.metadata
- `templates/references/fivewhyanalysis.md` — current template without common.metadata
- `templates/common.metadata` — the shared style guidelines content
- `templates/explanation/explanation.md` — reference for the HTML comment wrapper pattern
- `templates/references/handover.md` — reference for the HTML comment wrapper pattern

## Expected Output

- `templates/references/note.md` — updated with HTML comment wrapper containing {{common.metadata}}
- `templates/references/fivewhyanalysis.md` — updated with HTML comment wrapper containing {{common.metadata}}

## Inputs

- ``templates/references/note.md` — current template without common.metadata`
- ``templates/references/fivewhyanalysis.md` — current template without common.metadata`
- ``templates/common.metadata` — the shared style guidelines content`
- ``templates/explanation/explanation.md` — reference for the HTML comment wrapper pattern`
- ``templates/references/handover.md` — reference for the HTML comment wrapper pattern`

## Expected Output

- ``templates/references/note.md` — updated with HTML comment wrapper containing {{common.metadata}}`
- ``templates/references/fivewhyanalysis.md` — updated with HTML comment wrapper containing {{common.metadata}}`

## Verification

bundle exec rspec && bundle exec cucumber && grep -q 'common.metadata' templates/references/note.md && grep -q 'common.metadata' templates/references/fivewhyanalysis.md
