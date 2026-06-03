# Drop the README altogether

## Problem

**Problem:** [[0017-obsidian-not-github-is-now-the-primary-reading-surface|ADR-0017]] demoted the README from "the index" to a convenience file, but left open whether `dia` should keep generating it at all.

**Done looks like:** A decision recorded in a follow-up ADR — keep / make opt-in / drop — and the code, tests, and any existing READMEs brought in line with it.

### What we know

- The README is auto-generated and refreshed on every `dia update` and on every document creation, by `ReadmeManager` ([`lib/diataxis/readme_manager.rb`](lib/diataxis/readme_manager.rb)). Both `handle_update` and `create_document_with_readme_update` call it ([`lib/diataxis/cli/command_handlers.rb`](lib/diataxis/cli/command_handlers.rb)).
- The README path is mandatory config: `.diataxis` carries a `"readme"` key, and `ReadmeManager#readme_path` assumes it exists.
- Per ADR-0017 the README is no longer the discovery surface — Obsidian's graph, backlinks, and tags are — so its continued generation is now a convenience, not a requirement.
- Removing it is reversible and low-risk: the README holds no information not derivable from the documents themselves (it is generated *from* their titles).

### What we think

- Leaning toward **make it opt-in** rather than an outright drop (see [[#README fate options|the options]]): it removes the GitHub-era default without throwing away the generator for anyone who still wants a flat index. Unconfirmed — the decision is the point of this project.

## Next Actions

- [ ] Decide the README's fate and record it in a follow-up ADR — see [[#README fate options|README fate options]]
- [ ] Make README generation conditional so it is absent by default — see [[#Making generation optional|making generation optional]]
- [ ] Migrate or remove existing generated READMEs — see [[#Existing READMEs|existing READMEs]]
- [ ] Update specs and features that assume a README is always written — see [[#Test fallout|test fallout]]

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

## Related Topics

- [[0017-obsidian-not-github-is-now-the-primary-reading-surface|ADR-0017]] — the decision that created this project.
- [[0003-auto-generate-readme-with-document-links|ADR-0003]] — superseded; originally established README auto-generation.
- [[0006-implement-automated-readme-link-management|ADR-0006]] — superseded; the relative-Markdown link format being replaced.
- [`lib/diataxis/readme_manager.rb`](lib/diataxis/readme_manager.rb) — the generator under discussion.
