# Project: Fix broken search for 5why docs

**@urgent** tasks:

- [ ] Task 1
- [ ] Task 2

## Context

The `dia` tool is not correctly searching and finding different document types. Specifically, it's not detecting 5why documents that exist in the project structure.

**Evidence:**

In the `bolt-121-rhel10-puppet-not-installing` project:

```bash
➜  bolt-121-rhel10-puppet-not-installing git:(development) ✗ find docs -type f  
docs/handover_bolt_rhel10_to_rhel9_tests_failing/handover_bolt_rhel10_to_rhel9_tests_failing.md
docs/handover_bolt_rhel10_to_rhel9_tests_failing/5why_puppet_not_installing_on_rhel10.md
docs/handover_bolt_rhel10_to_rhel9_tests_failing/handover_puppet_agent_install_not_installing_on_rhel10.md
docs/handover_bolt_rhel10_to_rhel9_tests_failing/failing_run.md
docs/handover_bolt_rhel10_to_rhel9_tests_failing/successful_run.md
```

The README.md shows only handover documents being listed:

```bash
➜  bolt-121-rhel10-puppet-not-installing git:(development) ✗ cat ./README.md
# bolt-121-rhel10-puppet-not-installing

## Description

## Usage

## Appendix

### Handovers

<!-- handoverlog -->
* [bolt rhel10 to rhel9 tests failing](docs/handover_bolt_rhel10_to_rhel9_tests_failing/handover_bolt_rhel10_to_rhel9_tests_failing.md)
* [puppet_agent install not installing on rhel10](docs/handover_bolt_rhel10_to_rhel9_tests_failing/handover_puppet_agent_install_not_installing_on_rhel10.md)
<!-- handoverlogstop -->
```

**Issue:** The 5why document `5why_puppet_not_installing_on_rhel10.md` exists in the filesystem but is not being found/listed by `dia`'s search functionality.


The `dia` tool is meant to help organize and navigate Diátaxis documentation. If it cannot correctly find and list all document types (handovers, 5why analyses, etc.), it undermines the core value of the tool and creates confusion when documents exist but aren't discoverable through the tool's search functionality.

Desired Outcome

- All document types (5why, handover, how-to, reference, etc.) are correctly identified and listed by `dia` search commands
- The 5why document `5why_puppet_not_installing_on_rhel10.md` is properly found and can be listed in the README.md appendix
- Search functionality consistently finds documents regardless of their type prefix
