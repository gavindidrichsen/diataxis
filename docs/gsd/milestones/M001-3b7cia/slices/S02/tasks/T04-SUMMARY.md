---
id: T04
parent: S02
milestone: M001-3b7cia
key_files:
  - lib/diataxis/diataxis.rb
  - spec/template_loader_spec.rb
key_decisions:
  - document_types.rb configure block clears @types={} then re-registers all 9 types — no double-registration concern even though ADR/HowTo self-register in their class files
  - Replaced Diataxis::Explanation constant references with DocumentRegistry.lookup('explanation') in tests since Explanation is now an anonymous subclass
duration: 
verification_result: passed
completed_at: 2026-04-29T17:38:22.640Z
blocker_discovered: false
---

# T04: Wire document_types.rb into diataxis.rb, delete 7 shell class files, and update tests to use registry lookup for full behavioral equivalence

**Wire document_types.rb into diataxis.rb, delete 7 shell class files, and update tests to use registry lookup for full behavioral equivalence**

## What Happened

This task completed the atomic switch from individual shell class files to the centralized registry DSL in document_types.rb.\n\n1. **Updated diataxis.rb requires**: Replaced 9 require_relative lines (for all document subclasses) with 3 lines: adr.rb, howto.rb, and document_types.rb. ADR and HowTo are required before document_types.rb because they are named handler classes referenced in the configure block.\n\n2. **Deleted 7 shell class files**: Removed explanation.rb, tutorial.rb, handover.rb, five_why_analysis.rb, note.rb, project.rb, and pr.rb from lib/diataxis/document/. These were empty shell classes whose only purpose was calling register_type — now handled by document_types.rb's configure block which creates anonymous Document subclasses.\n\n3. **Updated spec/template_loader_spec.rb**: Replaced 3 references to `Diataxis::Explanation` (a now-deleted named constant) with `Diataxis::DocumentRegistry.lookup('explanation')`. CLI.run-based tests needed no changes since they use string command names resolved through the registry.\n\n4. **No double-registration issue**: The configure block in document_types.rb clears `@types = {}` at the start, then re-registers all 9 types (7 anonymous + 2 handler-backed). ADR and HowTo self-register in their class files, but configure's clear+rebuild means the final state is correct regardless of load order.\n\nNo changes needed to spec/diataxis_spec.rb — it uses CLI.run with string commands throughout, with no direct class constant references to deleted types.

## Verification

- `bundle exec rspec`: 37 examples, 0 failures (0.19s)\n- `bundle exec cucumber`: 6 scenarios, 39 steps, all passing (1.6s)\n- `ls lib/diataxis/document/`: outputs exactly adr.rb and howto.rb\n- Registry check: all 9 command names registered (5why, adr, explanation, handover, howto, note, pr, project, tutorial)\n- Template check: all 9 types have non-nil template names

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bundle exec rspec` | 0 | ✅ pass | 193ms |
| 2 | `bundle exec cucumber` | 0 | ✅ pass | 1586ms |
| 3 | `ls lib/diataxis/document/ | wc -l` | 0 | ✅ pass (2 files) | 50ms |
| 4 | `ruby -e "require_relative 'lib/diataxis'; puts Diataxis::DocumentRegistry.command_names.length"` | 0 | ✅ pass (9 types) | 100ms |
| 5 | `ruby -e "require_relative 'lib/diataxis'; Diataxis::DocumentRegistry.all.each { |c| raise 'nil' unless c.type_config[:template] }"` | 0 | ✅ pass (9 templates) | 100ms |

## Deviations

None

## Known Issues

None

## Files Created/Modified

- `lib/diataxis/diataxis.rb`
- `spec/template_loader_spec.rb`
