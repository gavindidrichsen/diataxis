# How to add a new document template

## Description

This guide walks you through adding a new document template type to the Diataxis gem. The registry DSL makes this a simple process — most of the infrastructure (CLI routing, help text, document creation, README integration) is automatic.

## Prerequisites

- Ruby development environment
- Access to the diataxis gem source code
- Familiarity with the existing document types (run `dia --help` to see the current list)

## Key files

| File | Purpose |
|------|---------|
| `lib/diataxis/document_types.rb` | Registry DSL — all document types are registered here |
| `templates/<category>/<type>.md` | Markdown template with `{{title}}`, `{{date}}`, and `{{common.metadata}}` placeholders |
| `lib/diataxis/config.rb` | `DEFAULT_CONFIG` — only needed if your type requires a non-default directory |

## What's automatic

Once a type is registered, the following happens with zero additional code:

- **CLI command**: `dia <command> new "Title"` is routed automatically via `DocumentRegistry.lookup` in `CommandRouter`
- **Help text**: `dia --help` lists the new command automatically via `DocumentRegistry.command_names` in `UsageDisplay`
- **Document creation**: `CommandHandlers.handle_document` is generic — it works for all registered types
- **README integration**: `dia update .` discovers files, generates sections, and manages links for all registered types

## Usage

### Step 1: Create the template file

Create a markdown template in `templates/<category>/` where `<category>` matches the Diataxis quadrant or `references` for reference documents:

```
templates/
  explanation/    # Explanations, PRs
  howto/          # How-to guides
  tutorial/       # Tutorials
  references/     # ADRs, notes, handovers, 5-whys, projects
```

For example, to add a "checklist" reference type:

```bash
touch templates/references/checklist.md
```

Add the template content with the standard metadata wrapper:

```markdown
<!--
# Common Guidelines

{{common.metadata}}

# Template-Specific Guidelines

- Each checklist should have a clear completion criteria
- Items should be actionable and verifiable
-->

# {{title}}

**Date:** {{date}}

## Purpose

Brief description of what this checklist covers.

## Checklist Items

- [ ] Item 1
- [ ] Item 2
- [ ] Item 3

## Notes

Additional context or instructions.
```

The `{{common.metadata}}` placeholder is resolved by `TemplateLoader` from `templates/common.metadata` and contains universal formatting rules shared across all templates. The `{{title}}` and `{{date}}` placeholders are substituted at document creation time.

### Step 2: Register the type

Add a `register` call to the `DocumentRegistry.configure` block in `lib/diataxis/document_types.rb`:

```ruby
r.register(
  command: 'checklist',       # CLI command name: `dia checklist new "Title"`
  prefix: 'checklist',        # Filename prefix: checklist_my_title.md
  category: 'references',     # Template directory: templates/references/
  config_key: 'checklists',   # .diataxis config key for custom directory
  readme_section: 'Checklists', # README section heading
  template: 'checklist',      # Template filename (without .md)
  section_tag: 'checklist'    # HTML comment tag in README
)
```

**Registration fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `command` | yes | CLI command name used in `dia <command> new "Title"` |
| `prefix` | yes | Filename prefix — files are named `<prefix>_<slug>.md` |
| `category` | yes | Template subdirectory under `templates/` |
| `config_key` | yes | Key in `.diataxis` config for custom directory path |
| `readme_section` | yes | Section heading used in the generated README |
| `template` | yes | Template filename (without `.md` extension) in `templates/<category>/` |
| `section_tag` | yes | HTML comment tag used to mark the README section |
| `slug_separator` | no | Character between prefix and slug (default: `_`). ADR uses `-` |
| `handler` | no | Custom Document subclass (see "Custom behavior" below) |

### Step 3 (optional): Add a default directory

By default, documents are created in the directory specified by the `default` key in `.diataxis` (typically `docs`). If your type should have its own directory by default, add it to `Config::DEFAULT_CONFIG` in `lib/diataxis/config.rb`:

```ruby
DEFAULT_CONFIG = {
  'default' => DEFAULT_DOCS_ROOT,
  'readme' => 'README.md',
  'adr' => "#{DEFAULT_DOCS_ROOT}/adr",
  'projects' => "#{DEFAULT_DOCS_ROOT}/_gtd",
  'checklists' => "#{DEFAULT_DOCS_ROOT}/checklists"  # Add this
}.freeze
```

Users can also override the directory per-project in their `.diataxis` config file without changing `DEFAULT_CONFIG`.

### Step 4: Run tests

```bash
bundle exec rspec
bundle exec cucumber
```

The existing test suite exercises template loading, document creation, and README integration for all registered types. If your template uses `{{common.metadata}}`, the TemplateLoader tests will verify it resolves correctly.

## Custom behavior

Most types need only the register call above. For types that require special behavior during document creation, provide a `handler` class that extends `Document` and overrides the template method hooks:

| Hook | Default | Example use |
|------|---------|-------------|
| `customize_title(title)` | Returns title unchanged | HowTo prepends "How to " if missing |
| `customize_filename(title, dir)` | Returns `nil` (use default) | ADR generates auto-numbered filenames like `0001-title.md` |
| `customize_content(content)` | Returns content unchanged | Could inject dynamic sections |

Example — registering with a custom handler:

```ruby
# In lib/diataxis/document_types.rb:
r.register(
  handler: Diataxis::ADR,      # Custom class instead of generic Document
  command: 'adr',
  prefix: '[0-9][0-9][0-9][0-9]',
  category: 'references',
  config_key: 'adr',
  readme_section: 'Design Decisions',
  slug_separator: '-',
  template: 'adr',
  section_tag: 'adr'
)
```

The custom handler class lives in `lib/diataxis/document/adr.rb` and overrides `customize_filename` to implement auto-numbering. Only ADR and HowTo currently use custom handlers — all other types use generic registration.

## Testing a new type manually

```bash
# Initialize config if needed
bundle exec dia init

# Create a document
bundle exec dia checklist new "Deployment checklist"

# Verify the file was created
ls docs/checklists/

# Verify README was updated
cat docs/README.md | grep -A2 "Checklists"

# Test title change and filename sync
# (edit the title in the created file, then:)
bundle exec dia update .
```

## Summary

| What you need | Simple type | Custom behavior |
|---------------|-------------|-----------------|
| Template file | yes | yes |
| Register call | yes | yes (with `handler:`) |
| Handler class | no | yes (`lib/diataxis/document/<type>.rb`) |
| Config change | only if custom default dir | only if custom default dir |
| CLI changes | none (automatic) | none (automatic) |
| Help text changes | none (automatic) | none (automatic) |
