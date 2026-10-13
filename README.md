# Diataxis

Diataxis is a command-line tool for managing documentation following the [Diataxis framework](https://diataxis.fr/). It supports 9 document types — how-to guides, tutorials, explanations, ADRs, 5-why analyses, project briefs, PR summaries, ways of working, and cheatsheets — and keeps filenames and wiki-links in step with titles.

## Features

* **Create** documents from templates with `dia <type> new "Title"` — 9 document types via a registry DSL, with how-to title normalization, auto-numbered ADRs and tag front matter. `new` only creates the file; it never renames anything or writes a README.
* **Keep names in step with titles** with `dia update [directory]` — renames documents so each filename matches its `# title` and repoints `[[wiki-links]]` to them. It acts on the directory you give, else `DIATAXIS_ROOT`, and fails if neither is available or the target has no `.diataxis`.
* **Configure only what you change.** A `.diataxis` file only has to exist: `dia init` writes `{}` and every default applies. Add JSON overrides to move where a type is written (see Configuration below).
* Recursive document discovery in subdirectories.
* `DIATAXIS_ROOT` for running `dia` from any directory, with `--here`/`--root` to resolve a local-vs-root conflict non-interactively when creating documents.
* `--tag`/`-t` flags and `DIATAXIS_TAGS` for attaching YAML front matter tags at creation time.
* `--stdout` to print a template to standard output instead of writing a file.

## Installation

Install the gem by executing:

```bash
git clone https://github.com/gavindidrichsen/diataxis.git
cd diataxis
gem build diataxis.gemspec
gem install diataxis
```

Make sure that `dia` is available on your PATH.  

## Usage

```bash
# mark this directory as a diataxis root (writes .diataxis containing just {})
dia init

# Create documents — all 9 types supported
dia howto new "How to configure SSL certificates"       # how-to guide (auto "How to" prefix)
dia howto new "Configure SSL certificates"              # imperative form also works
dia tutorial new "Getting Started with Docker"          # tutorial
dia explanation new "Why We Use PostgreSQL"             # explanation
dia adr new "Do whiteboard wednesday talks"             # ADR (auto-numbered)
dia fivewhy new "Login Timeout Root Cause"              # 5-why analysis
dia project new "API Migration"                         # project brief
dia pr new "Refactor Auth Module"                       # PR summary
dia wow new "Branch Discipline"                         # way of working
dia cheatsheet new "Docker commands"                    # cheatsheet
```

### Configuration (`.diataxis`)

A `.diataxis` file marks a directory as a documentation root. It only has to exist: `dia init` writes a single empty JSON object,

```json
{}
```

and every default applies (documents in `docs/`, ADRs in `docs/adr`, projects in `docs/_gtd`). An empty file is treated the same way. The file is plain JSON, so it cannot hold comments.

#### Overriding locations

To move where a type is written, add its key to the object. Paths are relative to the directory that holds the `.diataxis`. For example, to put how-tos in `docs/guides` and ADRs in `decisions`:

```json
{
  "howtos": "docs/guides",
  "adr": "decisions"
}
```

| Key | Document types it controls | Default |
|---|---|---|
| `default` | every type that has no key of its own | `docs` |
| `adr` | `adr` | `docs/adr` |
| `projects` | `project` | `docs/_gtd` |
| `explanations` | `explanation`, `pr`, `fivewhy` | the `default` directory |
| `tutorials` | `tutorial` | the `default` directory |
| `howtos` | `howto` | the `default` directory |
| `cheatsheets` | `cheatsheet` | the `default` directory |
| `wow` | `wow` | the `default` directory |

A key you do not set keeps its default. Note that `default` alone does not move ADRs or projects (they have their own defaults); set `adr` and `projects` too if you want them elsewhere. Invalid JSON, or JSON that is not an object, is reported as an error naming the file. See [ADR-0022](docs/adr/0022-a-diataxis-file-only-has-to-exist-and-dia-init-writes-an-empty-object.md).

### Renaming documents after a title change (`dia update`)

If you change a document's title, run `dia update` to rename its file and repoint `[[wiki-links]]` to it:

```bash
dia update .                       # the directory that holds the .diataxis
dia update /path/to/docs/root      # a specific directory, from anywhere
dia update                         # DIATAXIS_ROOT
```

| You run | It acts on |
|---|---|
| `dia update <directory>` | that directory, which must hold a `.diataxis` |
| `dia update` | `$DIATAXIS_ROOT` (which must hold a `.diataxis`) |
| `dia update`, with `DIATAXIS_ROOT` unset | nothing: it fails and tells you to pass a directory or set `DIATAXIS_ROOT` |
| `dia update <directory>` without a `.diataxis` in it | nothing: it fails, naming the `.diataxis` root above it if there is one |

`update` never assumes the current directory and never prompts. Creating a document (`dia <type> new`) does not rename anything; run `dia update` for that. See [ADR-0021](docs/adr/0021-dia-update-targets-an-explicit-directory-or-diataxis-root-and-requires-a-diataxis-root.md).

### Environment Variables

Set `DIATAXIS_ROOT` to run `dia` commands from any directory without `cd`-ing to the project root:

```bash
export DIATAXIS_ROOT=/path/to/my/project
dia explanation new "Why We Chose PostgreSQL"           # creates doc under DIATAXIS_ROOT
dia update                                              # renames documents under DIATAXIS_ROOT to match their titles
```

`init` targets `DIATAXIS_ROOT` when set. `dia update` targets the directory you pass, otherwise `DIATAXIS_ROOT`, otherwise it fails (it never assumes the current directory); the `.diataxis` config is loaded from that directory. `dia <type> new` routes based on whether `DIATAXIS_ROOT` is set to somewhere other than the current directory, and whether a local `.diataxis` governs the current directory:

| `DIATAXIS_ROOT` | local `.diataxis` | Where the new document goes |
|---|---|---|
| unset (or same as CWD) | absent | Straight into the current directory — no `docs/` subdirectory |
| unset (or same as CWD) | present | The current directory, using the local config (as usual) |
| set, elsewhere | absent | `DIATAXIS_ROOT`, falling back to the default config if it has none of its own |
| set, elsewhere | present | **Asks** — this directory, or your `DIATAXIS_ROOT` central knowledge store? |

That last row is the only case that prompts, because it's the only one where the two signals genuinely disagree. Skip the prompt (e.g. for scripts, CI, or an AI-agent session creating several documents in one sitting) with an explicit flag:

```bash
dia explanation new "Repo-Specific Design Doc" --here   # force this directory, ignoring DIATAXIS_ROOT
dia explanation new "Vault Note" --root                 # force DIATAXIS_ROOT
```

If neither flag is given and stdin isn't interactive, `dia` fails with a clear error rather than blocking. See [ADR-0018](docs/adr/0018-prompt-on-diataxis-root-and-local-diataxis-conflict.md) for the full reasoning.

### Tagging Documents

Attach tags to generated documents as YAML front matter using `--tag`/`-t` flags or the `DIATAXIS_TAGS` environment variable:

```bash
# CLI flags (repeatable)
dia explanation new "API Design" --tag backend -t api

# Environment variable (comma-separated)
export DIATAXIS_TAGS="sprint-42, backend"
dia howto new "Configure Redis"                         # inherits tags from DIATAXIS_TAGS

# Both sources are merged and deduplicated
DIATAXIS_TAGS="backend" dia note new "Redis Notes" -t api
# Result front matter: tags: [backend, api]
```

Tags are prepended as YAML front matter at the top of the generated document:

```yaml
---
tags:
  - backend
  - api
---
```

When no tags are specified, no front matter is added — existing behaviour is unchanged.

### Printing to stdout

Add `--stdout` to any document command to print the rendered template to standard output instead of writing a file. This is useful for piping a fresh template into another tool — for example, injecting it into an AI discussion:

```bash
dia explanation new "How to fly" --stdout            # prints the template, creates nothing
dia adr new "Use PostgreSQL" --stdout                # ADR number/status still injected
dia howto new "Configure Redis" --stdout --tag backend
```

`--stdout` has no filesystem side effects: it needs no `.diataxis` config, creates no directories and writes no file. Type-specific behaviour (how-to title normalization, ADR numbering, tag front matter) is preserved.

For design decisions see [docs/adr](./docs/adr); to add a document type see [how to add a new document template](./docs/how_to_add_a_new_document_template.md). The index below is maintained by hand (`dia` no longer generates a README).

## Testing

This project uses:

* **RSpec** for unit testing
* **Cucumber with Aruba** for BDD/CLI integration testing

The behaviour is specified as Cucumber features in [`features/`](features):

| Feature | Behaviour it defines |
|---|---|
| `configuration_management` | a `.diataxis` may be empty or `{}`; overrides move a document type; `dia init` writes `{}`; invalid JSON is a clear error |
| `document_types` | each document type is created with its template, numbering and location |
| `title_rename` | `dia update` renames documents to match their titles and repoints wiki-links |
| `update_target` | `dia update` acts on the given directory or `DIATAXIS_ROOT`, and fails elsewhere |
| `no_readme` | `dia` creates and renames documents but never writes a README |
| `subdirectory_discovery`, `yaml_front_matter` | documents in subdirectories and with front matter are found and renamed |
| `diataxis_root`, `tagging` | `DIATAXIS_ROOT`, `--here`/`--root`, and tags |

For detailed information on using Cucumber with Aruba, see [Cucumber & Aruba Cheatsheet](../../../tools/@cheatsheets/cucumber.md).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Acknowledgments

The ADR functionality in this tool is inspired by and maintains compatibility with two excellent projects:

* [adr-tools](https://github.com/npryce/adr-tools) - The original ADR management tool that established many of the conventions we follow
* [adr-log](https://github.com/adr/adr-log) - A complementary tool for generating ADR logs

Like these tools, our ADR implementation:

* Uses the standard ADR format (Context, Decision, Consequences)
* Maintains a chronological sequence of decisions
* Supports superseding and amending previous decisions
* Generates consistent, numbered filenames
* Preserves markdown formatting

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gavindidrichsen/diataxis. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gavindidrichsen/diataxis/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Diataxis project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gavindidrichsen/diataxis/blob/main/CODE_OF_CONDUCT.md).

## Appendix

### Design Decisions

* [ADR-0001](docs/adr/0001-adopt-diataxis-documentation-framework.md) - Adopt Diataxis Documentation Framework
* [ADR-0002](docs/adr/0002-use-configuration-file-for-document-paths.md) - Use Configuration File for Document Paths
* [ADR-0003](docs/adr/0003-auto-generate-readme-with-document-links.md) - Auto-Generate README with Document Links
* [ADR-0004](docs/adr/0004-use-linguistic-prefixes-for-document-classification.md) - Use Linguistic Prefixes for Document Classification
* [ADR-0005](docs/adr/0005-use-purpose-driven-document-templates.md) - Use Purpose-Driven Document Templates
* [ADR-0006](docs/adr/0006-implement-automated-readme-link-management.md) - Implement Automated README Link Management
* [ADR-0007](docs/adr/0007-enable-recursive-document-discovery.md) - Enable Recursive Document Discovery
* [ADR-0008](docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md) - Refactor document templates into separate class files for improved maintainability
* [ADR-0009](docs/adr/0009-hide-readme-sections-when-no-matching-documents-exist.md) - Hide README sections when no matching documents exist
* [ADR-0010](docs/adr/0010-implement-custom-error-handling-system.md) - Implement Custom Error Handling System
* [ADR-0011](docs/adr/0011-implement-centralized-logging-system-with-ruby-logger.md) - Implement centralized logging system with Ruby Logger
* [ADR-0012](docs/adr/0012-move-to-external-template-system-with-direct-templateloader-usage.md) - Move to External Template System with Direct TemplateLoader Usage
* [ADR-0013](docs/adr/0013-set-default-directory-for-all-templates.md) - Set default directory for all templates
* [ADR-0014](docs/adr/0014-underscore-the-gtd-directory-for-project-files-so-they-always-live-at-the-top.md) - Underscore the gtd directory for project files so they always live at the top
* [ADR-0015](docs/adr/0015-support-environment-variable-configuration-with-diataxis-root-and-diataxis-tags.md) - Support environment variable configuration with DIATAXIS_ROOT and DIATAXIS_TAGS
* [ADR-0016](docs/adr/0016-replace-per-type-class-files-with-registry-dsl-and-template-method-hooks.md) - Replace per-type class files with registry DSL and template method hooks
* [ADR-0017](docs/adr/0017-obsidian-not-github-is-now-the-primary-reading-surface.md) - Obsidian, not GitHub, is now the primary reading surface
* [ADR-0018](docs/adr/0018-prompt-on-diataxis-root-and-local-diataxis-conflict.md) - Prompt on DIATAXIS_ROOT and local .diataxis conflict
* [ADR-0019](docs/adr/0019-tag-adrs-by-scope-instead-of-a-separate-idr-document-type.md) - Tag ADRs by scope instead of a separate IDR document type
* [ADR-0020](docs/adr/0020-drop-readme-generation-so-dia-only-renames-documents-and-repoints-wiki-links.md) - Drop README generation so dia only renames documents and repoints wiki-links
* [ADR-0021](docs/adr/0021-dia-update-targets-an-explicit-directory-or-diataxis-root-and-requires-a-diataxis-root.md) - dia update targets an explicit directory or DIATAXIS_ROOT and requires a diataxis root
* [ADR-0022](docs/adr/0022-a-diataxis-file-only-has-to-exist-and-dia-init-writes-an-empty-object.md) - A .diataxis file only has to exist and dia init writes an empty object

### Projects

* [Simplify the default .diataxis to just the docs root](docs/_gtd/project_simplify_the_default_diataxis_to_just_the_docs_root.md)
