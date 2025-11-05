# Diataxis Document Templates

This directory contains markdown templates for each document type in the Diataxis framework.

## Template Files

- `howto.md` - Template for how-to guides (procedural, goal-oriented)
- `tutorial.md` - Template for tutorials (learning-oriented, step-by-step)
- `explanation.md` - Template for explanations (understanding-oriented, concept-focused)
- `adr.md` - Template for Architecture Decision Records (decision documentation)

## Template Variables

Templates use `{{variable}}` placeholder syntax for dynamic content:

### Common Variables

- `{{title}}` - The document title
- `{{date}}` - Current date in YYYY-MM-DD format

### ADR-Specific Variables

- `{{adr_number}}` - Four-digit ADR number (e.g., 0001)
- `{{status}}` - Decision status (e.g., "Proposed", "Accepted")

## Customization

Users can override these templates by placing custom versions in their project's template directory (configured via `diataxis.yml`).

## Template Format

Templates are standard markdown files with simple placeholder substitution. This keeps them:

- Readable in any markdown editor
- Easy to edit without technical knowledge
- Compatible with AI tools for content analysis and improvement
- Version-controllable with clear diffs
