---
id: S02
parent: M001-3b7cia
milestone: M001-3b7cia
provides:
  - (none)
requires:
  []
affects:
  []
key_files:
  - ["lib/diataxis/document.rb", "lib/diataxis/document_types.rb", "lib/diataxis/template_loader.rb", "lib/diataxis/readme_manager.rb", "lib/diataxis/document/adr.rb", "lib/diataxis/document/howto.rb"]
key_decisions:
  - ["Used RegistryBuilder pattern for DocumentRegistry.configure — block collects registrations then applies", "Template method hooks placed as protected no-op defaults (customize_title, customize_filename, customize_content, customize_readme_entry)", "ADR and HowTo remain as named handler classes; 7 simple types use anonymous Document subclasses", "Safe navigation (&.) at all class-name derivation sites for anonymous subclass resilience", "Kept HowTo initialize override as-is — forcing through customize_title adds complexity for no benefit"]
patterns_established:
  - ["Registry DSL: DocumentRegistry.configure block with RegistryBuilder for type registration", "Config-key fallback: type_config[:template] and type_config[:section_tag] preferred over class name derivation", "Template method hooks: no-op defaults in base class, overridden only by handler classes"]
observability_surfaces:
  - none
drill_down_paths:
  []
duration: ""
verification_result: passed
completed_at: 2026-04-29T20:01:55.905Z
blocker_discovered: false
---

# S02: Registry DSL and template method pattern

**Replaced 7 shell class files with a pure Ruby registry DSL in document_types.rb, added 4 template method hooks to Document base class, and fixed the ADR pattern config bug**

## What Happened

S02 executed the core refactor in 4 tasks:\n\n**T01** added 4 template method hooks (customize_title, customize_filename, customize_content, customize_readme_entry) to Document base class with no-op defaults. All hooks wired into initialize and content methods.\n\n**T02** created the registry DSL in document_types.rb with a RegistryBuilder pattern inside DocumentRegistry.configure. Also made TemplateLoader, ReadmeManager, and Document resilient to anonymous subclasses by preferring type_config[:template] and type_config[:section_tag] over class name derivation (safe navigation at all 4 sites).\n\n**T03** fixed the ADR pattern bug (Config.path_for→Config.load) and added template:/section_tag: keys to all 9 document subclass register_type calls as an intermediate safety net.\n\n**T04** wired document_types.rb into diataxis.rb, deleted the 7 shell class files, updated spec/template_loader_spec.rb to use DocumentRegistry.lookup instead of deleted class constants, and verified full behavioral equivalence: 37 rspec examples pass, 6 cucumber scenarios pass, 9 document types registered correctly.

## Verification

- bundle exec rspec: 37 examples, 0 failures\n- bundle exec cucumber: 6 scenarios, 39 steps, all passing\n- ls lib/diataxis/document/: exactly adr.rb and howto.rb\n- All 9 command names registered in DocumentRegistry\n- All 9 types have non-nil template names\n- ADR auto-numbering works correctly\n- HowTo title normalization works correctly

## Requirements Advanced

None.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

None.

## Known Limitations

None.

## Follow-ups

None.

## Files Created/Modified

None.
