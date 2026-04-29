---
estimated_steps: 134
estimated_files: 11
skills_used: []
---

# T04: Wire document_types.rb, delete 7 shell classes, update tests, and verify behavioral equivalence

---
estimated_steps: 8
estimated_files: 11
skills_used:
  - verify-before-complete
  - test
---

# T04: Wire document_types.rb, delete 7 shell classes, update tests, and verify behavioral equivalence

**Slice:** S02 — Registry DSL and template method pattern
**Milestone:** M001-3b7cia

## Description

This is the integration task where the refactor comes together. Wire `document_types.rb` into `diataxis.rb`, delete the 7 empty shell class files, update test files that reference deleted classes, and verify full behavioral equivalence.

This is the riskiest task because it makes the atomic switch: the old registration path (shell classes calling `register_type`) is replaced by the new path (`document_types.rb` configure block). Double registration must be avoided.

### Key changes to diataxis.rb

Current requires (lines 7-15):
```ruby
require_relative 'document/howto'
require_relative 'document/explanation'
require_relative 'document/tutorial'
require_relative 'document/adr'
require_relative 'document/handover'
require_relative 'document/five_why_analysis'
require_relative 'document/note'
require_relative 'document/project'
require_relative 'document/pr'
```

New requires:
```ruby
require_relative 'document/adr'
require_relative 'document/howto'
require_relative 'document_types'
```

ADR and HowTo must be required BEFORE document_types.rb because the registry references them as handler classes.

### Shell class deletion

Delete these 7 files:
- `lib/diataxis/document/explanation.rb`
- `lib/diataxis/document/tutorial.rb`
- `lib/diataxis/document/handover.rb`
- `lib/diataxis/document/five_why_analysis.rb`
- `lib/diataxis/document/note.rb`
- `lib/diataxis/document/project.rb`
- `lib/diataxis/document/pr.rb`

### Test updates

`spec/template_loader_spec.rb` references `Diataxis::Explanation`, `Diataxis::Handover`, and `Diataxis::ADR` by class constant name. After deletion:
- `Diataxis::Explanation` no longer exists as a named constant — it's an anonymous subclass in the registry. Tests that use `Diataxis::Explanation` must switch to `Diataxis::DocumentRegistry.lookup('explanation')`.
- `Diataxis::Handover` — same treatment.
- `Diataxis::ADR` — still exists as a named class, no change needed.

Specific test lines to update:
- Line 29: `described_class.load_template(Diataxis::Explanation, 'Test Topic')` → `described_class.load_template(Diataxis::DocumentRegistry.lookup('explanation'), 'Test Topic')`
- Line 41: Same pattern for Explanation
- Line 70: Same pattern for Explanation
- Line 82: `Diataxis::CLI.run(['explanation', 'new', 'Test Topic'])` — this uses CLI which looks up by command name, so it should work unchanged. But verify.
- Line 102: `Diataxis::CLI.run(['handover', 'new', 'Server Migration'])` — same, CLI lookup, should work unchanged.

Also check `spec/diataxis_spec.rb` for any class constant references to deleted types.

### Behavioral equivalence smoke test

After wiring, create a temp directory and run:
```ruby
require_relative 'lib/diataxis'
Diataxis::DocumentRegistry.command_names.sort.each do |cmd|
  puts "#{cmd}: #{Diataxis::DocumentRegistry.lookup(cmd).type_config[:template]}"
end
```
All 9 commands should be registered with correct template names.

Then create one document of each simple type and verify the output file exists with correct content structure.

## Steps

1. Update `lib/diataxis/diataxis.rb`: Replace the 9 require_relative lines (7-15) with 3 lines:
   ```ruby
   require_relative 'document/adr'
   require_relative 'document/howto'
   require_relative 'document_types'
   ```
   Keep all other requires unchanged.

2. Verify `lib/diataxis/document_types.rb` (created in T02) properly registers all 9 types. The `configure` block must NOT call `register_type` on ADR or HowTo again if they already self-register in their class files. Check: do `adr.rb` and `howto.rb` call `register_type` in their class bodies? YES they do (lines 8-15 in both files). So `document_types.rb` must either:
   - Skip registering ADR and HowTo (they self-register when required), OR
   - Clear the registry before the configure block and re-register everything including ADR/HowTo
   
   The cleanest approach: add a `DocumentRegistry.clear` method, call it at the start of `configure`, then register all 9 types. ADR and HowTo's `register_type` calls in their class files will have already run (they're required before document_types.rb), but `configure` clears and re-registers with the full config including template:/section_tag:. This also means the `template:` and `section_tag:` added to shell class register_type calls in T03 are moot — but they were useful as an intermediate safety net.

   Actually simpler: `document_types.rb` should only register the 7 simple types. ADR and HowTo already self-register in their class files (with template:/section_tag: added in T03). No clearing needed, no double registration. The configure block creates anonymous subclasses only for the 7 simple types.

3. Delete the 7 shell class files: `rm lib/diataxis/document/explanation.rb lib/diataxis/document/tutorial.rb lib/diataxis/document/handover.rb lib/diataxis/document/five_why_analysis.rb lib/diataxis/document/note.rb lib/diataxis/document/project.rb lib/diataxis/document/pr.rb`

4. Update `spec/template_loader_spec.rb`:
   - Line 29: Replace `Diataxis::Explanation` with `Diataxis::DocumentRegistry.lookup('explanation')`
   - Line 41: Same replacement
   - Line 70: Same replacement
   - Verify lines 82 and 102 (CLI.run calls) work without changes

5. Check `spec/diataxis_spec.rb` for references to deleted class names and update if needed.

6. Run `bundle exec rspec` — all tests must pass.

7. Run `bundle exec cucumber` — all scenarios must pass.

8. Verify:
   - `ls lib/diataxis/document/` shows only `adr.rb` and `howto.rb`
   - `ruby -e "require_relative 'lib/diataxis'; puts Diataxis::DocumentRegistry.command_names.sort.join(', ')"` prints all 9 commands
   - `ruby -e "require_relative 'lib/diataxis'; Diataxis::DocumentRegistry.all.each { |c| puts c.type_config[:template] }"` prints 9 template names

## Must-Haves

- [ ] `diataxis.rb` requires only adr.rb, howto.rb, and document_types.rb (not the 7 shell classes)
- [ ] 7 shell class files deleted from lib/diataxis/document/
- [ ] `spec/template_loader_spec.rb` updated to use registry lookup instead of deleted class constants
- [ ] All 9 document types registered and functional via `DocumentRegistry`
- [ ] `bundle exec rspec` passes with 0 failures
- [ ] `bundle exec cucumber` passes with 0 failures
- [ ] README section tags preserved exactly (no existing README sections broken)

## Failure Modes

| Dependency | On error | On timeout | On malformed response |
|------------|----------|-----------|----------------------|
| document_types.rb configure block | Registration fails — check error message for missing handler class or duplicate command | N/A | N/A |
| Deleted class references in tests | NameError: uninitialized constant — update test to use registry lookup | N/A | N/A |

## Verification

- `bundle exec rspec` — all examples pass, 0 failures
- `bundle exec cucumber` — 6 scenarios, 39 steps, all passing
- `ls lib/diataxis/document/ | sort` — outputs exactly `adr.rb` and `howto.rb`
- `ruby -e "require_relative 'lib/diataxis'; names = Diataxis::DocumentRegistry.command_names.sort; puts names.length; puts names.join(',')"` — prints 9 and all command names
- `ruby -e "require_relative 'lib/diataxis'; Diataxis::DocumentRegistry.all.each { |c| t = c.type_config[:template]; raise 'nil template' unless t; puts t }"` — prints 9 template names, no nil

## Inputs

- `lib/diataxis/diataxis.rb` — main require file to rewire
- `lib/diataxis/document_types.rb` — T02 output, registry DSL file to wire in
- `lib/diataxis/document/adr.rb` — T03 output, kept as handler class
- `lib/diataxis/document/howto.rb` — T03 output, kept as handler class
- `lib/diataxis/document/explanation.rb` — T03 output, to be deleted
- `lib/diataxis/document/tutorial.rb` — T03 output, to be deleted
- `lib/diataxis/document/handover.rb` — T03 output, to be deleted
- `lib/diataxis/document/five_why_analysis.rb` — T03 output, to be deleted
- `lib/diataxis/document/note.rb` — T03 output, to be deleted
- `lib/diataxis/document/project.rb` — T03 output, to be deleted
- `lib/diataxis/document/pr.rb` — T03 output, to be deleted
- `spec/template_loader_spec.rb` — test file referencing deleted class constants
- `spec/diataxis_spec.rb` — test file to check for deleted class references

## Expected Output

- `lib/diataxis/diataxis.rb` — modified: requires only adr.rb, howto.rb, document_types.rb
- `lib/diataxis/document/explanation.rb` — deleted
- `lib/diataxis/document/tutorial.rb` — deleted
- `lib/diataxis/document/handover.rb` — deleted
- `lib/diataxis/document/five_why_analysis.rb` — deleted
- `lib/diataxis/document/note.rb` — deleted
- `lib/diataxis/document/project.rb` — deleted
- `lib/diataxis/document/pr.rb` — deleted
- `spec/template_loader_spec.rb` — modified: uses registry lookup instead of deleted class constants

## Inputs

- ``lib/diataxis/diataxis.rb` — main require file to rewire`
- ``lib/diataxis/document_types.rb` — T02 output, registry DSL to wire in`
- ``lib/diataxis/document/adr.rb` — T03 output, handler class to keep`
- ``lib/diataxis/document/howto.rb` — T03 output, handler class to keep`
- ``lib/diataxis/document/explanation.rb` — shell class to delete`
- ``lib/diataxis/document/tutorial.rb` — shell class to delete`
- ``lib/diataxis/document/handover.rb` — shell class to delete`
- ``lib/diataxis/document/five_why_analysis.rb` — shell class to delete`
- ``lib/diataxis/document/note.rb` — shell class to delete`
- ``lib/diataxis/document/project.rb` — shell class to delete`
- ``lib/diataxis/document/pr.rb` — shell class to delete`
- ``spec/template_loader_spec.rb` — test file to update`
- ``spec/diataxis_spec.rb` — test file to check for deleted class references`

## Expected Output

- ``lib/diataxis/diataxis.rb` — requires adr.rb, howto.rb, document_types.rb only`
- ``spec/template_loader_spec.rb` — uses DocumentRegistry.lookup instead of deleted class constants`
- ``lib/diataxis/document/explanation.rb` — deleted`
- ``lib/diataxis/document/tutorial.rb` — deleted`
- ``lib/diataxis/document/handover.rb` — deleted`
- ``lib/diataxis/document/five_why_analysis.rb` — deleted`
- ``lib/diataxis/document/note.rb` — deleted`
- ``lib/diataxis/document/project.rb` — deleted`
- ``lib/diataxis/document/pr.rb` — deleted`

## Verification

bundle exec rspec && bundle exec cucumber && test $(ls lib/diataxis/document/ | wc -l | tr -d ' ') -eq 2 && ruby -e "require_relative 'lib/diataxis'; raise 'wrong count' unless Diataxis::DocumentRegistry.command_names.length == 9"
