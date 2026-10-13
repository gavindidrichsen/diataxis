## [Unreleased]

- **Breaking:** `dia` no longer generates or updates a README. `dia update [directory]` now only renames documents so their filenames match their titles and repoints `[[wiki-links]]` to the renamed files; `dia <type> new` only creates the document (it no longer runs a rename pass over the tree). Existing generated READMEs are left on disk as static files. See [ADR-0020](docs/adr/0020-drop-readme-generation-so-dia-only-renames-documents-and-repoints-wiki-links.md).
- `Config::DEFAULT_CONFIG` is simplified to `default`, `adr` and `projects`: the `readme` and `wow` keys are removed (a leftover `readme` key in an existing `.diataxis` is ignored; `wow` documents go to the default directory unless a `wow` location is configured).
- Internal: the rename step is extracted from `ReadmeManager` (deleted) into `DocumentRenamer`; document types no longer carry `readme_section`, `section_tag` or `format_readme_entry`.
- Tests: removed README assertions and the stale IDR scenarios (the `idr` type was removed by ADR-0019); added `features/no_readme.feature` and a `DocumentRenamer` spec.
- `dia <type> new` no longer hard-fails when there's no `.diataxis` anywhere: with `DIATAXIS_ROOT` unset and no local config, it writes the document straight into the current directory (no README management); with `DIATAXIS_ROOT` set and no config there, it publishes using the default config instead of raising.
- When `DIATAXIS_ROOT` is set to a directory other than CWD *and* a local `.diataxis` also applies, `dia` now asks which one you meant instead of silently letting `DIATAXIS_ROOT` win.
- Added `--here`/`--root` flags to resolve that conflict non-interactively, and a clear error (instead of a hang) when stdin isn't interactive and neither flag is given.

## [0.1.0] - 2025-02-12

- Initial release
