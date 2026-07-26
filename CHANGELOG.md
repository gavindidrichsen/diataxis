## [Unreleased]

- `dia <type> new` no longer hard-fails when there's no `.diataxis` anywhere: with `DIATAXIS_ROOT` unset and no local config, it writes the document straight into the current directory (no README management); with `DIATAXIS_ROOT` set and no config there, it publishes using the default config instead of raising.
- When `DIATAXIS_ROOT` is set to a directory other than CWD *and* a local `.diataxis` also applies, `dia` now asks which one you meant instead of silently letting `DIATAXIS_ROOT` win.
- Added `--here`/`--root` flags to resolve that conflict non-interactively, and a clear error (instead of a hang) when stdin isn't interactive and neither flag is given.

## [0.1.0] - 2025-02-12

- Initial release
