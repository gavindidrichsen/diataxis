## [Unreleased]

- **Breaking:** `dia` no longer generates or updates a README. `dia update [directory]` now only renames documents so their filenames match their titles and repoints `[[wiki-links]]` to the renamed files; `dia <type> new` only creates the document (it no longer runs a rename pass over the tree). Existing generated READMEs are left on disk as static files. See [ADR-0020](docs/adr/0020-drop-readme-generation-so-dia-only-renames-documents-and-repoints-wiki-links.md).
- **Breaking:** `dia update` no longer falls back to the current directory. `dia update <directory>` applies to that directory; `dia update` with no directory applies to `DIATAXIS_ROOT`; with neither it errors. The target must hold a `.diataxis`, otherwise it errors (naming the ancestor `.diataxis` root if there is one) instead of silently reporting that every filename already matches. See [ADR-0021](docs/adr/0021-dia-update-targets-an-explicit-directory-or-diataxis-root-and-requires-a-diataxis-root.md).
- `.diataxis` only has to exist: an empty file or `{}` means every default applies, and `dia init` now writes just `{}` (it used to write every default). Overrides are documented in the README. Invalid JSON, or JSON that is not an object, raises a `ConfigurationError` naming the file instead of a stack trace. See [ADR-0022](docs/adr/0022-a-diataxis-file-only-has-to-exist-and-dia-init-writes-an-empty-object.md).
- `Config::DEFAULT_CONFIG` is simplified to `default`, `adr` and `projects`: the `readme` and `wow` keys are removed (a leftover `readme` key in an existing `.diataxis` is ignored; `wow` documents go to the default directory unless a `wow` location is configured).
- Internal: the rename step is extracted from `ReadmeManager` (deleted) into `DocumentRenamer`; document types no longer carry `readme_section`, `section_tag` or `format_readme_entry`.
- Tests: removed README assertions and the stale IDR scenarios (the `idr` type was removed by ADR-0019); added `features/no_readme.feature` and a `DocumentRenamer` spec.
- `dia <type> new` no longer hard-fails when there's no `.diataxis` anywhere: with `DIATAXIS_ROOT` unset and no local config, it writes the document straight into the current directory (no README management); with `DIATAXIS_ROOT` set and no config there, it publishes using the default config instead of raising.
- When `DIATAXIS_ROOT` is set to a directory other than CWD *and* a local `.diataxis` also applies, `dia` now asks which one you meant instead of silently letting `DIATAXIS_ROOT` win.
- Added `--here`/`--root` flags to resolve that conflict non-interactively, and a clear error (instead of a hang) when stdin isn't interactive and neither flag is given.

## [0.1.0] - 2025-02-12

- Initial release
