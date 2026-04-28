---
estimated_steps: 21
estimated_files: 1
skills_used: []
---

# T03: Add TemplateLoader unit tests for placeholder resolution

## Description

Add a new spec file `spec/template_loader_spec.rb` with focused unit tests for the `{{common.metadata}}` placeholder resolution in `TemplateLoader.load_template()`.

## Steps

1. Create `spec/template_loader_spec.rb` with these test cases:

   a. **Resolves `{{common.metadata}}` placeholder** — Call `TemplateLoader.load_template()` with a document class whose template contains `{{common.metadata}}`. Verify the returned content includes the Style Guidelines bullets from `templates/common.metadata` and does NOT contain the literal string `{{common.metadata}}`.

   b. **Resolves placeholder before title/date** — Verify that if `common.metadata` hypothetically contained `{{title}}`, it would NOT be double-substituted. (Defensive test — current content doesn't have this, but ordering matters.)

   c. **Templates without placeholder work unchanged** — Call `TemplateLoader.load_template()` with a document class whose template does NOT contain `{{common.metadata}}` (e.g., ADR). Verify it returns the expected content without error.

   d. **Missing common.metadata raises TemplateError** — Temporarily stub `File.exist?` or rename the file, then call `load_template` with a template that contains the placeholder. Verify it raises `Diataxis::TemplateError` with a message mentioning "common.metadata".

   e. **Behavioral equivalence for explanation** — Generate an explanation document via `Diataxis::CLI.run(['explanation', 'new', 'Test Topic'])` and verify the output contains the Style Guidelines content AND the type-specific metadata (Purpose Section Requirement, etc.) AND the template body sections (Purpose, Background, Key Concepts).

   f. **Behavioral equivalence for handover** — Same pattern, verify handover output contains Style Guidelines + Linking Rules + template body (Problem Summary, What Do We Know, etc.).

2. Use the existing test patterns from `spec/diataxis_spec.rb`: `test_dir` with `tmp/test`, `Dir.chdir(test_dir)`, `.diataxis` config setup in `before` block, cleanup in `after` block.

3. Run `bundle exec rspec spec/template_loader_spec.rb` to verify all tests pass.

4. Run `bundle exec rspec` to verify no regressions.

## Must-Haves

- [ ] `spec/template_loader_spec.rb` exists with tests for: placeholder resolution, ordering, no-placeholder templates, missing file error, behavioral equivalence for at least 2 template types
- [ ] All new tests pass
- [ ] All existing tests still pass

## Verification

- `bundle exec rspec spec/template_loader_spec.rb` — all new specs pass
- `bundle exec rspec` — full suite passes
- `bundle exec cucumber` — all features pass

## Inputs

- `lib/diataxis/template_loader.rb`
- `templates/common.metadata`
- `spec/diataxis_spec.rb`
- `spec/spec_helper.rb`
- `templates/explanations/explanation.md`
- `templates/references/handover.md`

## Expected Output

- `spec/template_loader_spec.rb`

## Verification

bundle exec rspec spec/template_loader_spec.rb && bundle exec rspec && bundle exec cucumber
