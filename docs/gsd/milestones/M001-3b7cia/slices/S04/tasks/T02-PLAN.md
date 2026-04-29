---
estimated_steps: 6
estimated_files: 1
skills_used: []
---

# T02: Add creation and content tests for project, 5why, and pr document types

The existing spec covers howto, tutorial, adr, explanation, handover, and note — but project, 5why (fivewhyanalysis), and pr have zero creation or content tests. Add test contexts for all three in spec/diataxis_spec.rb.

For each type, test:
1. File is created with correct filename prefix
2. Content includes the expected title and key template sections
3. README is updated with correct section and link

Reference the existing handover and note test contexts (lines 171-228) for the pattern. Use the registered command names: 'project', '5why', 'pr'.

## Inputs

- `spec/diataxis_spec.rb — existing test file to extend`
- `lib/diataxis/document_types.rb — registry with command names and config keys`
- `templates/references/project.md — project template for expected sections`
- `templates/references/fivewhyanalysis.md — 5why template for expected sections`
- `templates/explanation/pr.md — pr template for expected sections`

## Expected Output

- `spec/diataxis_spec.rb — 3 new test contexts covering project, 5why, and pr document creation`

## Verification

bundle exec rspec spec/diataxis_spec.rb && bundle exec rspec && bundle exec cucumber
