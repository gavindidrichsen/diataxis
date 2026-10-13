# Drop the README altogether

## Problem

> **Status (2026-10-13): done in [PR #62](https://github.com/gavindidrichsen/diataxis/pull/62), awaiting merge.** Decision: [[0020-drop-readme-generation-so-dia-only-renames-documents-and-repoints-wiki-links|ADR-0020]]. Delete this doc once the PR is merged; the only remaining item is per-vault data, tracked under Backlog.

**Problem:** [[0017-obsidian-not-github-is-now-the-primary-reading-surface|ADR-0017]] demoted the README from "the index" to a convenience file, but left open whether `dia` should keep generating it at all.

**Done looks like:** A decision recorded in a follow-up ADR — keep / make opt-in / drop — and the code, tests, and any existing READMEs brought in line with it.

### What we know

- The README is auto-generated and refreshed on every `dia update` and on every document creation, by `ReadmeManager` ([`lib/diataxis/readme_manager.rb`](lib/diataxis/readme_manager.rb)). Both `handle_update` and `create_document_with_readme_update` call it ([`lib/diataxis/cli/command_handlers.rb`](lib/diataxis/cli/command_handlers.rb)).
- The README path is mandatory config: `.diataxis` carries a `"readme"` key, and `ReadmeManager#readme_path` assumes it exists.
- Per ADR-0017 the README is no longer the discovery surface — Obsidian's graph, backlinks, and tags are — so its continued generation is now a convenience, not a requirement.
- Removing it is reversible and low-risk: the README holds no information not derivable from the documents themselves (it is generated *from* their titles).

### What we think

- **Decided 2026-10-13: drop it** (see ADR-0020). Originally leaning toward **make it opt-in** rather than an outright drop (see [[#README fate options|the options]]): it removes the GitHub-era default without throwing away the generator for anyone who still wants a flat index. Unconfirmed — the decision is the point of this project.

## Next Actions

- [x] Decide the README's fate and record it in a follow-up ADR (dropped: [[0020-drop-readme-generation-so-dia-only-renames-documents-and-repoints-wiki-links|ADR-0020]]) — see [[#README fate options|README fate options]]
- [x] Remove README generation instead of making it conditional (`ReadmeManager` deleted; rename extracted into `DocumentRenamer`) — see [[#Making generation optional|making generation optional]]
- [x] Update specs and features that assume a README is always written (README assertions removed, `features/no_readme.feature` added) — see [[#Test fallout|test fallout]]

## Backlog

- Migrate or remove existing generated READMEs in each vault (the repo itself and `@INBOX`): they are now static snapshots, so leave or delete them per vault — see [[#Existing READMEs|existing READMEs]].

## Key Concepts

### README fate options

| Option | What it means | Cost | Keeps |
| --- | --- | --- | --- |
| Keep generating | Status quo, now emitting `[[wiki-links]]` per ADR-0017 | none | flat index for GitHub-era habits |
| Make opt-in | Generate only when explicitly configured/flagged; absent by default | small (a guard + config default) | the generator, off by default |
| Drop entirely | Remove `ReadmeManager` generation; rely on Obsidian | medium (delete code + tests) | nothing — simplest end state |

Recommendation: **make it opt-in** — it honours ADR-0017's "Obsidian is primary" without deleting a still-useful tool, and is the cheapest reversible step.

### Making generation optional

The two call sites that trigger generation both live behind `dia`'s command handlers, so a single guard (e.g. treat a missing/empty `"readme"` config key as "don't generate") would make the README absent by default without touching `ReadmeManager` itself.

**Code Location:** [`lib/diataxis/cli/command_handlers.rb`](lib/diataxis/cli/command_handlers.rb) (`handle_update`, `create_document_with_readme_update`)

### Existing READMEs

Vaults already carrying a generated README (this repo, and the `@INBOX` vault) need a one-time decision: leave the file as a static snapshot, or delete it. This is data, not code, so it is handled per-vault, not in the gem.

### Test fallout

`features/title_rename.feature` and the README assertions in the cucumber suite assume a README is always written and currently assert relative-Markdown link strings. Both the ADR-0017 wiki-link switch and any "absent by default" change will require updating these expectations.

## Background

- 2026-06-03 — Spun out of ADR-0017, which switched the index to wiki-links and demoted the README but explicitly deferred the question of dropping it.

- 2026-10-13 — Decided: drop it altogether rather than make it opt-in. The README code also owned the rename pass, so it was split out into `DocumentRenamer`; `dia update` now only renames and repoints wiki-links, and `dia <type> new` only creates. The default config was simplified to `default`, `adr`, `projects` (the `readme` and `wow` keys removed). Recorded in [[0020-drop-readme-generation-so-dia-only-renames-documents-and-repoints-wiki-links|ADR-0020]].

## Related Topics

- [[0017-obsidian-not-github-is-now-the-primary-reading-surface|ADR-0017]] — the decision that created this project.
- [[tools/puppet/repositories/gavindidrichsen/diataxis/docs/adr/0003-auto-generate-readme-with-document-links|ADR-0003]] — superseded; originally established README auto-generation.
- [[tools/puppet/repositories/gavindidrichsen/diataxis/docs/adr/0006-implement-automated-readme-link-management|ADR-0006]] — superseded; the relative-Markdown link format being replaced.
- `lib/diataxis/readme_manager.rb` — the generator that was removed in PR #62 (its rename step lives on as [`lib/diataxis/document_renamer.rb`](lib/diataxis/document_renamer.rb)).
