# 0012. Move to External Template System with Direct TemplateLoader Usage

Date: 2025-11-05

## Status

Accepted

## Context

Templates were hardcoded as strings in Ruby classes, making them difficult to edit and not AI-friendly. I wanted external markdown templates so that I could easily fix template structure or get AI to update them without touching Ruby code.

Initially tried keeping templates beneath `lib/diataxis/templates/` but this doesn't conform to gem best practices.

## Decision

Move templates to external markdown files in the root `templates/` directory:

```bash
templates/
├── howto.md        # {{title}} → document title
├── tutorial.md     # {{title}} → document title  
├── explanation.md  # {{title}} → document title
└── adr.md         # {{title}}, {{adr_number}}, {{date}}, {{status}}
```

Templates use `{{variable}}` substitution and are loaded via `TemplateLoader.load_template()` utility method.

## Consequences

### What becomes easier

1. **Template Editing**: Can visually inspect and edit templates as markdown files in any editor
2. **AI Assistance**: AI tools can easily analyze and improve template structure
3. **Gem Best Practices**: Templates in root `templates/` directory follows Ruby community standards
4. **Version Control**: Template changes show as clear markdown diffs

### What becomes more difficult

1. **Runtime Dependency**: Templates must exist as files (no embedded fallbacks)
