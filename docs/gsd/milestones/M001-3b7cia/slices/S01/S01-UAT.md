# S01: Common metadata template injection — UAT

**Milestone:** M001-3b7cia
**Written:** 2026-04-29T04:57:54.452Z

# S01 UAT: Common Metadata Template Injection

## Preconditions
- Ruby environment with bundler installed
- diataxis gem source checked out on `development` branch
- Clean working directory (no uncommitted changes unrelated to S01)

## Test Cases

### TC1: Common metadata file exists and contains correct content
1. Verify `templates/common.metadata` exists
2. Verify it contains `**Style Guidelines (Strict):**` header
3. Verify it contains exactly 6 bullet points starting with `- `
4. Verify it does NOT contain `<!--` or `-->` HTML comment delimiters
5. Verify it does NOT contain `# Common Guidelines` section header

**Expected:** File exists with raw guideline content only, no wrapper markup.

### TC2: Explanation document renders with injected metadata
1. Create a temp directory, add `.diataxis` config: `{"readme": "docs/README.md"}`
2. Run `dia new explanation "Test Topic"`
3. Open the generated file in `docs/understanding_test_topic.md`
4. Verify the HTML comment block contains `# Common Guidelines` followed by the 6 Style Guidelines bullets
5. Verify the HTML comment block contains `# Template-Specific Guidelines` followed by explanation-specific metadata
6. Verify the document body contains `# Understanding Test Topic` and expected sections (Purpose, Background, Key Concepts)

**Expected:** Common metadata injected inside template-owned section structure; document body intact.

### TC3: Handover document renders with injected metadata
1. In same temp directory, run `dia new handover "Test Handover"`
2. Open `docs/handover_test_handover.md`
3. Verify `# Common Guidelines` section with Style Guidelines bullets
4. Verify `# Template-Specific Guidelines` with handover-specific Linking Rules
5. Verify document body has Problem Summary, What Do We Know, etc.

**Expected:** Handover uses same common metadata but different type-specific content.

### TC4: ADR document renders without metadata (no placeholder)
1. Run `dia new adr "Test Decision"`
2. Open the generated ADR file
3. Verify it does NOT contain `# Common Guidelines` or Style Guidelines bullets
4. Verify it does NOT contain `{{common.metadata}}` literal text

**Expected:** Templates without the placeholder are unaffected by the injection system.

### TC5: Custom config directories work correctly
1. Create temp directory with `.diataxis`: `{"readme": "test_docs/README.md", "howtos": "test_docs/how-to"}`
2. Run `dia howto new "Configure System"`
3. Verify `test_docs/how-to/how_to_configure_system.md` exists
4. Verify `test_docs/README.md` contains `### How-To Guides`
5. Verify `test_docs/README.md` contains `How to configure System`
6. Verify `test_docs/README.md` contains `how-to/how_to_configure_system.md`

**Expected:** Document#pattern respects type-specific config directories; README sections generated correctly.

### TC6: All RSpec tests pass
1. Run `bundle exec rspec`
**Expected:** 37 examples, 0 failures

### TC7: All Cucumber scenarios pass
1. Run `bundle exec cucumber`
**Expected:** 6 scenarios, 39 steps — all passed

### TC8: TemplateLoader unit tests pass
1. Run `bundle exec rspec spec/template_loader_spec.rb`
**Expected:** 6 examples, 0 failures (placeholder resolution, ordering, no-placeholder, missing file error, behavioral equivalence x2)

### Edge Cases

### EC1: Missing common.metadata file
1. Temporarily rename `templates/common.metadata` to `templates/common.metadata.bak`
2. Attempt `dia new explanation "Test"` 
3. Verify it raises a TemplateError with message containing "common.metadata"
4. Restore `templates/common.metadata.bak` to `templates/common.metadata`

**Expected:** Clear error message when common metadata file is missing.

### EC2: PR template has different type-specific content
1. Run `dia new pr "Test PR"`
2. Verify PR template has PR-specific metadata (Change section headings, Changes Section Requirement, What Did NOT Change) after `# Template-Specific Guidelines`
3. Verify common metadata bullets are identical to explanation/tutorial/howto

**Expected:** Each template type has its own type-specific metadata while sharing the common block.
