# 0015. Support environment variable configuration with DIATAXIS_ROOT and DIATAXIS_TAGS

Date: 2026-05-02

## Status

Accepted

## Context

The `dia` CLI tool required users to be in the project root directory when running commands like `dia update` or `dia explanation new "Title"`. This made it awkward to use in several real-world scenarios:

- **CI/CD pipelines** — build scripts run from arbitrary working directories and cannot always `cd` to the doc root before invoking `dia`
- **Monorepos** — a user editing code in `services/auth/` wants to create documentation rooted at the top-level `docs/` without navigating there first
- **Tagging at creation time** — teams wanted to categorize documents by sprint, component, or audience at creation time rather than manually editing YAML front matter after the fact

The existing `.diataxis` config file controls *directory structure* (where each document type lives), but there was no mechanism to control *which project root* that config is resolved from, nor any way to inject metadata into generated documents.

## Decision

Support environment-variable-based configuration alongside CLI flags, following a layered precedence model:

### DIATAXIS_ROOT

- When set, all `dia` operations (init, document creation, update) target the directory specified by `DIATAXIS_ROOT` instead of the current working directory
- The `.diataxis` config file is loaded from `DIATAXIS_ROOT`, not from `pwd`
- When unset or empty, behaviour is unchanged — `pwd` is used as before
- An explicit directory argument (e.g., `dia update /some/path`) still overrides `DIATAXIS_ROOT`

### DIATAXIS_TAGS and --tag/-t

- `--tag TAG` (or `-t TAG`) attaches one or more tags to a generated document's YAML front matter
- `DIATAXIS_TAGS` accepts a comma-separated list of tags (e.g., `DIATAXIS_TAGS="sprint-42, auth"`)
- Tags from both sources are merged and deduplicated; CLI flags take precedence over env var
- When no tags are specified, no YAML front matter is added — existing behaviour is preserved exactly

### Why environment variables over config-file-only

- Environment variables compose naturally with shell workflows (`export DIATAXIS_ROOT=... && dia ...`)
- They are the standard mechanism for CI/CD override without modifying committed files
- The `.diataxis` config file continues to own directory structure; environment variables own runtime context (where to operate, what metadata to attach)

## Consequences

**Positive:**

- Users can run `dia` from any directory in a monorepo or CI pipeline without `cd`
- Documents can be tagged at creation time, enabling downstream filtering and categorization
- All existing behaviour is preserved when neither environment variable is set
- The precedence model (explicit arg > env var > pwd) is consistent with standard Unix conventions

**Negative:**

- Two configuration surfaces (config file + env vars) increase the number of things a user must understand
- If `DIATAXIS_ROOT` is set in a shell profile and forgotten, `dia` commands may unexpectedly target a different directory
- Tag format is currently flat YAML list only — structured metadata (key-value pairs, namespaces) would require a future extension

## References

- [ADR-0002: Use Configuration File for Document Paths](./0002-use-configuration-file-for-document-paths.md) — the original config file decision that this extends
- [ADR-0013: Set default directory for all templates](./0013-set-default-directory-for-all-templates.md) — the prior directory default decision
- [PR: Add DIATAXIS_ROOT, --tag/-t, and DIATAXIS_TAGS support](../pr_add_diataxis_root_tag_t_and_diataxis_tag_environment_variable_support.md) — implementation details
