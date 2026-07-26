# 0018. Prompt on DIATAXIS_ROOT and local .diataxis conflict

Date: 2026-07-26

## Status

Accepted

## Context

Most of the time, `dia` should route new documents to a single central knowledge store: `DIATAXIS_ROOT` pointed at a personal Obsidian vault, so day-to-day notes, explanations, and project docs accumulate in one searchable place. But that's not the only real use case. There are genuine occasions when working inside a specific repository where a document -- a design doc, an ADR, a how-to for that codebase -- should live *with the code it describes*, in that repo's own `docs/`. And there are also times, while sitting in that same repo, when a document is still better routed to the central vault rather than the repo.

Before this change, `DIATAXIS_ROOT` was a blunt global override (ADR-0015): when set, it silently won over any local `.diataxis`, full stop. The only way to route a specific document to the repo instead was the cumbersome `DIATAXIS_ROOT=$PWD dia explanation new "Title"` incantation -- an override to escape the override. This friction discouraged per-repo documentation and, worse, made it easy to forget `DIATAXIS_ROOT` was set in a shell profile and have documents silently land in the wrong place (a risk ADR-0015 already flagged as a known consequence).

Separately, `ensure_config_exists!` (added to guard against silently writing into an unconfigured directory) hard-failed with `ConfigurationError` whenever `DIATAXIS_ROOT` pointed at a directory with no `.diataxis` of its own, and whenever neither `DIATAXIS_ROOT` nor a local `.diataxis` were present at all -- even though both are recoverable, unambiguous situations.

See [`project_simplify_diataxis_cli_output_routing_behaviour.md`](../_gtd/project_simplify_diataxis_cli_output_routing_behaviour.md) for the fuller investigation and routing-model options considered (local-first, CWD-default, global config, flag override, interactive prompt).

## Decision

Route each `dia <type> new` invocation by asking two questions: is `DIATAXIS_ROOT` set to somewhere *other than* the current directory, and does a local `.diataxis` govern the current directory (found by the same upward walk `Config.find_config` already performs)? See [`destination_resolver.rb`](../../lib/diataxis/cli/destination_resolver.rb).

| DIATAXIS_ROOT | local .diataxis | Behaviour |
|---|---|---|
| unset (or same dir as CWD) | absent | Write the document straight into the current directory -- no `docs/` subdirectory, no README management. Nothing to fail on, nothing to ask about. |
| unset (or same dir as CWD) | present | Unchanged: use the local config as today. |
| set, distinct from CWD | absent | Publish to `DIATAXIS_ROOT`, falling back to `Config::DEFAULT_CONFIG` if `DIATAXIS_ROOT` has no `.diataxis` of its own -- no hard-fail. |
| set, distinct from CWD | present | **Genuine conflict** -- both signals disagree about where this document belongs. Ask interactively: *"Save this document in this directory, or your DIATAXIS_ROOT central knowledge store?"* |

The interactive prompt only fires for that last, truly ambiguous case; every other combination is resolved silently. Two escape hatches exist for the conflict case:

- `--here` / `--root` flags force the outcome for a single invocation without prompting. This is what lets a human -- or a scripted/agent-driven session creating several documents in one sitting, some destined for the repo and some for the central vault -- decide per-document without being blocked on a terminal prompt each time.
- If stdin isn't a TTY (CI, a spawned subprocess, a non-interactive script) and neither flag was given, `dia` raises a `ConfigurationError` telling the caller to pass `--here` or `--root`, rather than blocking on `$stdin.gets` forever or silently guessing.

`--here` and `--root` don't just suppress the prompt -- they express the same routing intent as if that signal had won outright, so `--here` still uses a local `.diataxis` if one applies (config-driven, README managed), and only writes standalone if the current directory truly has no config of its own.

## Consequences

**Positive:**

- The common case (`DIATAXIS_ROOT` set, no local `.diataxis`, or vice versa) needs zero ceremony and never fails.
- The old blind "`DIATAXIS_ROOT` always wins" precedence -- which could silently misfile a document if the env var was set and forgotten -- is replaced by an explicit decision exactly when it matters.
- `--here`/`--root` give scripts, CI, and AI-agent sessions a non-interactive way to route each document individually, matching how a single sitting might produce multiple documents with different destinations.
- Running `dia` with no `DIATAXIS_ROOT` and no `.diataxis` anywhere now works (flat write, no README) instead of hard-failing with `ConfigurationError`.

**Negative:**

- One more concept to learn: the conflict case and its resolution (prompt or flag).
- The interactive prompt is a new code path that must stay non-interactive-safe (TTY detection) as the CLI evolves.
- `dia update`'s directory-resolution scope intentionally was *not* changed by this decision -- it still resolves purely from `DIATAXIS_ROOT`/an explicit argument, without the local-conflict check `new` now has. If `update`'s scope needs to track `new`'s routing model later, that's a follow-up, not implied here.

## References

- [ADR-0015: Support environment variable configuration with DIATAXIS_ROOT and DIATAXIS_TAGS](./0015-support-environment-variable-configuration-with-diataxis-root-and-diataxis-tags.md) -- the precedence model this decision refines for document creation
- [`project_simplify_diataxis_cli_output_routing_behaviour.md`](../_gtd/project_simplify_diataxis_cli_output_routing_behaviour.md) -- the investigation and options considered
- [`destination_resolver.rb`](../../lib/diataxis/cli/destination_resolver.rb) -- implementation
- [`destination_resolver_spec.rb`](../../spec/destination_resolver_spec.rb) -- routing-matrix test coverage
