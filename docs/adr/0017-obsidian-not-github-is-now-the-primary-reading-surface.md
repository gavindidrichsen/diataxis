# 0017. Obsidian, not GitHub, is now the primary reading surface

Date: 2026-06-03

## Status

Accepted

Supersedes [ADR-0003](./0003-auto-generate-readme-with-document-links.md) and [ADR-0006](./0006-implement-automated-readme-link-management.md).

## Context

[ADR-0003](./0003-auto-generate-readme-with-document-links.md) and [ADR-0006](./0006-implement-automated-readme-link-management.md) were written when these documents were read primarily on GitHub. There, the auto-generated `README.md` is the landing page, and relative Markdown links (`[title](path.md)`) are the only links that render. Both ADRs treat the README as *the* discovery surface and mandate relative Markdown links to make it work.

That assumption no longer holds. The vault is now read in Obsidian, whose whole value is its native machinery — `[[wiki-links]]`, backlinks, tags, and the graph view. In that world:

- The README is no longer the front door; the graph and backlinks are how documents are discovered.
- Relative Markdown links are the "old way" — they do not participate in Obsidian's link graph and are not maintained automatically when a file is renamed.
- Wiki-links, by contrast, resolve by filename and survive moves within the vault, and are kept correct on rename by the link-updater introduced alongside this decision.

The tooling has already been drifting this way: the ADR and project templates both mandate `[[wiki-links]]` for local cross-references. This ADR makes the generated index consistent with that.

## Decision

- The generated index uses Obsidian wiki-links — `[[explanation_advanced_system_design]]` — instead of relative Markdown links. The link target carries no `.md` extension; on-disk filenames are unchanged.
- Obsidian (graph, backlinks, tags) is the primary navigation surface. The README is demoted from "the index" to, at most, a convenience file — it is no longer the canonical way to discover documents.
- Whether to stop generating the README altogether is **deliberately not decided here**. It is tracked as an open project: [[project_drop_the_readme_altogether]].

## Consequences

### Easier

- Documents are first-class in the Obsidian link graph and backlinks.
- One linking style across the whole vault — document bodies and the index alike.
- Renames keep the index correct for free, since wiki-links are repointed by the link-updater.

### Harder

- Wiki-links render as literal `[[text]]` on GitHub; the repo is no longer meant to be browsed there.
- Existing relative Markdown links need a one-time migration to wiki-links.

### Unchanged

- File-on-disk names and the `*.md` extension are untouched — only link *targets* change.

## Related Topics

- [[0003-auto-generate-readme-with-document-links|ADR-0003]] — superseded; established the README as the discovery surface.
- [[0006-implement-automated-readme-link-management|ADR-0006]] — superseded; mandated relative Markdown links.
- [[project_drop_the_readme_altogether]] — open project tracking the README's fate.
