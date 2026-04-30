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

# Project: Error handle new document failures

## Context

When attempting to create a new "project" document in a repository with an old `.diataxis` config file that doesn't contain the new `"projects"` key, the CLI crashes with a `TypeError`:

```ruby
/lib/diataxis/cli/command_handlers.rb:97:in `join': no implicit conversion of nil into String (TypeError)
        document_dir = File.join(directory, config[config_key])
```

This happens because `config[config_key]` returns `nil` when the key doesn't exist, and `File.join` cannot convert `nil` to a string.

## Outstanding Tasks

These are my most pressing **Next Actions**:

**@urgent** tasks:

- [x] Add validation check in `create_document_with_readme_update` to verify config key exists
- [ ] Test the fix works with missing config keys
- [ ] Consider adding a helpful error message suggesting which key to add

## Other Lists

These hold my other actions so I can know they’re recorded but “forget” about them to reduce cognitive load.

### @waiting

- [ ] User feedback on error message clarity

### @backlog

- [ ] Add similar validation for other document types (if needed)
- [ ] Create migration guide for updating old .diataxis files
- [ ] Add `dia config validate` command to check for missing keys

### @someday

- [ ] Auto-migration tool that adds missing keys to .diataxis files
- [ ] Warning system when config schema is outdated
