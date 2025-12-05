<!--
GTD Philosophy Overview

Getting Things Done (GTD) is a productivity methodology by David Allen designed to reduce 
stress and improve clarity by organizing tasks and commitments into actionable lists.

Core Principles:

1. Capture Everything
   Collect all tasks, ideas, and commitments into a trusted system so nothing stays in your head.

2. Clarify & Organize
   Decide what each item means and where it belongs:
   - Is it actionable?
   - If yes, what's the Next Action?
   - If no, trash it, incubate it, or file it as reference.

3. Next Action Thinking
   Break projects into the very next physical, visible step you can take to move it forward.
   Example: Instead of "Plan website redesign," write "Email designer to schedule kickoff."

4. Project Definition
   A project in GTD is any outcome requiring more than one action. Define:
   - Purpose (Why this matters)
   - Desired Outcome (What "done" looks like)
   - Next Actions (What to do now)

5. Contextual Lists
   Organize actions by context or state:
   - @waiting – tasks dependent on others
   - @backlog – deferred tasks
   - @someday – ideas for the future

6. Review Regularly
   Weekly review ensures clarity and trust in your system.
-->
<!--
**Style Guidelines:**

- Use bulleted lists with `-` instead of numbered lists for easy reordering
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`)
- Keep headings descriptive so steps can be rearranged without renumbering
- Use `####` subheadings for troubleshooting subsections instead of bold text with numbers

When referencing code or documentation:
- **Code**: Link to GitHub with line numbers: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)
- **Docs**: Link to official documentation: [Ruby Logger Documentation](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html)
- **Local**: Link to local docs: [Related How-to](../how_to_other_guide.md)
-->

# Project: Fix dia behavriour when no .diataxis file is present

**@urgent** tasks:

- [x] Investigate root cause
- [x] Implement fail-fast behavior
- [x] Add tests for missing config scenario
- [x] Verify all tests pass
- [ ] Remove obsolete directory walk-up logic from `Config.find_config`

## Context

When running `dia project new` in a directory without a `.diataxis` config file, the command doesn't fail as expected. Instead, it appears to create the project in an old/unexpected directory path.

**Observed behavior:**

```bash
➜  @troubleshooting git:(development) ✗ history | grep "dia project new" | grep Fix
...
...
10336  dia project new "Fix dia behavriour when no .diataxis file is present"

➜  @troubleshooting git:(development) ✗ cat .diataxis
cat: .diataxis: No such file or directory

➜  @troubleshooting git:(development) ✗ find docs -type f
docs/references/five_why_analyses/5why_windows_ruby_3_2_bundle_install_failing_with_gcc_15_incompatible_pointer_types.md
docs/README.md
➜  @troubleshooting git:(development) ✗
```

**Expected behavior:**

The command should either:

1. **Fail gracefully** with a clear error message when no `.diataxis` file is present, OR
2. **Use default diataxis structure:**

   ```json
   {
     "default": "docs",
     "readme": "README.md",
     "adr": "docs/adr",
     "projects": "docs/_gtd"
   }
   ```

**Questions to answer:**

- Why is the command using an old directory path?
- Where is the config being read from?
- What's the proper fix?

## Other Lists

These hold my other actions so I can know they're recorded but "forget" about them to reduce cognitive load.

**@waiting** for these tasks:

- [ ] Waiting task 1

**@backlog** tasks for later:

- [ ] Backlog task 1

**@someday** ideas to revisit:

- [ ] Someday idea 1

## Project Purpose

**Why does this project matter?**

Users should get predictable, clear behavior from the `dia` tool. When there's no `.diataxis` config file:

- The tool should either fail fast with a helpful error message
- Or fall back to sensible defaults
- It should NOT use old/stale directory paths from unknown sources

This improves user experience and prevents confusion.

## Desired Outcome

**What does "done" looks like?**

When running `dia project new` in a directory without a `.diataxis` file:

- The command either fails with a clear error message (e.g., "No .diataxis config file found in current directory or parent directories")
- OR uses the documented default structure consistently
- No unexpected directory paths are used
- Behavior is well-documented and tested

## Background

### Root Cause Analysis

**The Issue:**

When `dia project new` is run without a `.diataxis` file, the command succeeds instead of failing. The problem is in [`lib/diataxis/config.rb`](https://github.com/gavindidrichsen/diataxis/blob/development/lib/diataxis/config.rb#L17-L26):

```ruby
def self.load(directory = '.')
  config_path = find_config(directory)
  if config_path
    user_config = JSON.parse(File.read(config_path))
    DEFAULT_CONFIG.merge(user_config)
  else
    DEFAULT_CONFIG  # Returns default config even when no .diataxis file exists!
  end
end
```

**Current behavior:**

1. `Config.find_config(directory)` searches up the directory tree for `.diataxis`
2. If not found, it returns `nil`
3. `Config.load` then returns `DEFAULT_CONFIG` as a fallback
4. The command proceeds using default paths

**Why it uses old directory paths:**

The command is likely finding an old `.diataxis` file in a parent directory during the search (see line 35-43 in `config.rb`). The `find_config` method walks up the directory tree until it reaches `/`, so if there's a `.diataxis` file anywhere in the parent path, it will use that.

### Solution Options

**Option 1: Fail fast (Recommended)** ✅ **IMPLEMENTED**

Require `.diataxis` file to exist in the current directory. If not found, provide clear error message instructing user to run `dia init`.

**Option 2: Use defaults with warning**

Allow operation without `.diataxis` but warn user that defaults are being used.

**Option 3: Prompt for initialization**

Ask user if they want to initialize the directory when no config is found.

### Implementation

**Changes made:**

1. **Added config validation** in [`lib/diataxis/cli/command_handlers.rb`](https://github.com/gavindidrichsen/diataxis/blob/development/lib/diataxis/cli/command_handlers.rb):
   - Added `ensure_config_exists!` private method to check for `.diataxis` file
   - Calls this check at the start of `create_document_with_readme_update`
   - Raises `ConfigurationError` with helpful message if config not found

2. **Added test coverage** in [`spec/diataxis_spec.rb`](https://github.com/gavindidrichsen/diataxis/blob/development/spec/diataxis_spec.rb):
   - Added "without configuration file" context
   - Tests that document creation fails with proper error
   - Tests that error message suggests running `dia init`

**Verification:**

```bash
# Test 1: Command fails without .diataxis file
cd @troubleshooting
dia project new "Test"
# Output: Error: No .diataxis configuration file found...
#         Please run 'dia init' to create a configuration file.

# Test 2: Command works with .diataxis file
cd diataxis
dia project new "Test Fix Verification"
# Output: Created new project: docs/_gtd/project_test_fix_verification.md

# Test 3: All tests pass
bundle exec rspec
# Output: 37 examples, 0 failures
```

### Status: 🔄 IN PROGRESS

**Date started:** 5 December 2025

**Summary:** The core issue has been fixed with fail-fast validation. Now need to remove obsolete directory walk-up code that conflicts with the new explicit config requirement.

**Completed:**

- ✅ Added config validation that requires `.diataxis` in current directory
- ✅ Clear error message directing users to run `dia init`
- ✅ Comprehensive test coverage (37 examples, 0 failures)

**Remaining work:**

- ⏳ Remove directory walk-up logic from `Config.find_config` method

### Next Action: Remove Directory Walk-Up Logic

**Why this is needed:**

Now that we enforce `.diataxis` must exist in the current working directory (via `ensure_config_exists!`), the directory walk-up logic in `Config.find_config` is:

1. **Obsolete** - We never walk up the tree anymore since we fail-fast if config isn't in current dir
2. **Misleading** - Code suggests we search parent directories, but we don't
3. **Potential bug source** - If someone removes `ensure_config_exists!` check, walk-up behavior returns

**Files to modify:**

1. **`lib/diataxis/config.rb`** - Simplify `find_config` method

**Current implementation:**

```ruby
def self.find_config(start_dir)
  current_dir = File.expand_path(start_dir)
  while current_dir != '/'
    config_path = File.join(current_dir, CONFIG_FILE)
    return config_path if File.exist?(config_path)

    current_dir = File.dirname(current_dir)
  end
  nil
end
```

**Simplified implementation:**

```ruby
def self.find_config(start_dir)
  config_path = File.join(File.expand_path(start_dir), CONFIG_FILE)
  File.exist?(config_path) ? config_path : nil
end
```

**Testing:**

The existing test suite should pass without changes since:

- Document creation commands call `ensure_config_exists!` first (which checks current dir only)
- `Config.load` still works the same way - just doesn't walk up anymore
- All 37 existing tests should still pass

**Verification steps:**

```bash
# 1. Make the change to lib/diataxis/config.rb
# 2. Run tests
bundle exec rspec
# Expected: 37 examples, 0 failures

# 3. Manual test - should fail without config
cd /tmp/test_dir
dia project new "Test"
# Expected: Error: No .diataxis configuration file found

# 4. Manual test - should work with config
dia init
dia project new "Test"  
# Expected: Success
```
