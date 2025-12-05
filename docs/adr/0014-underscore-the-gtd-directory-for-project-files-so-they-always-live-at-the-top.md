# 0014. Underscore the gtd directory for project files so they always live at the top

Date: 2025-12-05

## Status

Accepted

## Context

When working with documentation that includes GTD (Getting Things Done) project files, these project directories need to be immediately visible and easily discoverable. Without a naming convention, `gtd/` directories are mixed alphabetically with regular documentation directories and files, making it harder to:

1. **Quickly identify active projects**: When browsing a `docs/` directory, you can't immediately see if there are active projects without scanning through all subdirectories
2. **Search for projects globally**: Finding all project files across a large workspace requires knowing the exact location of each `gtd/` directory
3. **Maintain focus**: GTD project files represent active work that requires regular review - they should be prominently positioned, not hidden among reference documentation

Directory listings sort underscore-prefixed directories before alphanumeric ones, which means `_gtd/` will always appear at the top of any directory listing.

## Decision

Rename all `gtd/` directories to `_gtd/` across the documentation workspace.

**Rationale for underscore prefix:**

- Underscore sorts before letters and numbers in most filesystem listings
- Visually distinct - immediately recognizable as "special" or "meta" directories
- Common convention for hidden/system directories (like `.git`, `_site`, etc.)
- Not hidden by default (unlike dot-prefixed directories), but clearly separated

## Consequences

**Positive:**

- **Improved visibility**: `_gtd/` directories always appear at the top of directory listings, making active projects immediately visible
- **Easy global search**: Can find all projects with simple glob: `find . -type d -name "_gtd"` or `grep -r "pattern" **/_gtd/`
- **Clear separation**: Visual distinction between active project work (`_gtd/`) and reference documentation
- **Better project awareness**: When entering any documentation area, you immediately see if there are active projects
- **Consistent sorting**: Works across terminal listings, file browsers, and IDEs

**Examples:**

Before:

```bash
docs/
├── adr/
├── gtd/           # Hidden among other directories
├── how-tos/
└── references/
```

After:

```bash
docs/
├── _gtd/          # Always at the top
├── adr/
├── how-tos/
└── references/
```
