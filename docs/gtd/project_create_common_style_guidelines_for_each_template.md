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

# Project: Create common style guidelines for each template

**@urgent** tasks:

- [ ] Create `style_guidelines.yaml` data structure for common and document-specific guidelines
- [ ] Extract style guidelines from project template to shared location
- [ ] Update template generator to inject style guidelines from YAML
- [ ] Add document-type-specific guidelines (projects, how-tos, references, explanations)

## Context

Currently, style guidelines are embedded directly in individual templates (e.g., `project.md.erb`). This creates several issues:

- **Duplication**: Same guidelines repeated across multiple templates
- **Inconsistency**: Guidelines can drift between templates
- **Maintenance burden**: Updating guidelines requires editing multiple files
- **No flexibility**: Can't have common guidelines + document-specific guidelines

One thing to consider here is that there seem to be emerging standards for specifying context for AI.  See [spec-kit](https://github.com/github/spec-kit?tab=readme-ov-file#-get-started) for some examples (I think...).  Basically I'm talking about the hierarchy of context markdown files and directories that I've seen used for Claude Code and CoPilot.

### Current Implementation

Style guidelines are hardcoded in template comments:

```markdown
<!--
**Style Guidelines:**

- Use bulleted lists with `-` instead of numbered lists for easy reordering
- Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`)
- Keep headings descriptive so steps can be rearranged without renumbering

When referencing code or documentation:
- **Code**: Link to GitHub with line numbers: [`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)
- **Docs**: Link to official documentation: [Ruby Logger Documentation](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html)
- **Local**: Link to local docs: [Related How-to](../how_to_other_guide.md)
-->
```

This was discovered while working on automating NuGet installation in [`project_automate_the_nuget_installation.md`](../project_automate_the_nuget_installation.md), where applying style guidelines required manual reference to the embedded comment.

## Solution Design

### Hierarchical Style Guidelines System

Create a Hiera-like data structure that allows:

- **Common guidelines**: Apply to all document types
- **Document-type guidelines**: Specific to projects, how-tos, references, or explanations
- **Template-specific guidelines**: Unique to individual templates

### Proposed File Structure

```text
diataxis/
├── data/
│   └── style_guidelines.yaml
├── lib/
│   └── diataxis/
│       └── style_guidelines.rb
└── templates/
    ├── project.md.erb
    ├── how_to.md.erb
    ├── reference.md.erb
    └── explanation.md.erb
```

### Data Structure (`style_guidelines.yaml`)

```yaml
# Common guidelines for all document types
common:
  formatting:
    - "Use bulleted lists with `-` instead of numbered lists for easy reordering"
    - "Create headings without numbers (e.g., `### Install Package` not `### Step 1: Install Package`)"
    - "Keep headings descriptive so steps can be rearranged without renumbering"
    - "Use `####` subheadings for troubleshooting subsections instead of bold text with numbers"
  
  linking:
    code:
      description: "Link to GitHub with line numbers"
      example: "[`filename:line`](https://github.com/org/repo/blob/main/path/file.rb#L123)"
    docs:
      description: "Link to official documentation"
      example: "[Ruby Logger Documentation](https://ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger.html)"
    local:
      description: "Link to local docs"
      example: "[Related How-to](../how_to_other_guide.md)"

# Document-type specific guidelines
projects:
  task_management:
    - "Break work into actionable tasks with clear completion criteria"
    - "Use @urgent, @waiting, @backlog, @someday tags for task prioritization"
  
  structure:
    - "Always include Context, Purpose, Desired Outcome, and Background sections"
    - "Link to related code with GitHub URLs including line numbers"
  
  testing:
    - "Use descriptive headings for testing steps (e.g., `### Uninstall Package`, not `### Step 1`)"
    - "Include verification criteria in bullet points"

how_tos:
  structure:
    - "Start with prerequisites and end with verification"
    - "Each step should be independently executable"
  
  formatting:
    - "Use command blocks with clear shell prompts"
    - "Include expected output where relevant"

references:
  structure:
    - "Organize alphabetically or by logical grouping"
    - "Include examples for each API or command"
  
  linking:
    - "Link to source code for implementation details"
    - "Cross-reference related reference documents"

explanations:
  structure:
    - "Start with high-level concept before diving into details"
    - "Use diagrams and examples to illustrate concepts"
  
  formatting:
    - "Avoid step-by-step instructions (use how-tos for that)"
    - "Focus on 'why' and 'how it works' rather than 'how to do it'"
```

## Implementation Steps

### Create Style Guidelines Module

Create `lib/diataxis/style_guidelines.rb`:

```ruby
require 'yaml'

module Diataxis
  class StyleGuidelines
    attr_reader :data

    def initialize(yaml_path = nil)
      yaml_path ||= File.join(__dir__, '../../data/style_guidelines.yaml')
      @data = YAML.load_file(yaml_path)
    end

    # Get all guidelines for a document type
    def for_type(doc_type)
      common = @data['common'] || {}
      specific = @data[doc_type.to_s] || {}
      
      {
        common: common,
        specific: specific
      }
    end

    # Render guidelines as markdown comment
    def render_comment(doc_type)
      guidelines = for_type(doc_type)
      output = ["<!--", "**Style Guidelines:**", ""]
      
      # Render common guidelines
      if guidelines[:common]['formatting']
        guidelines[:common]['formatting'].each { |g| output << "- #{g}" }
        output << ""
      end
      
      # Render linking guidelines
      if guidelines[:common]['linking']
        output << "When referencing code or documentation:"
        guidelines[:common]['linking'].each do |type, details|
          output << "- **#{type.capitalize}**: #{details['description']}: #{details['example']}"
        end
        output << ""
      end
      
      # Render document-specific guidelines
      if guidelines[:specific].any?
        output << "**#{doc_type.capitalize}-specific:**"
        output << ""
        guidelines[:specific].each do |section, items|
          output << "#{section.capitalize}:"
          items.each { |item| output << "- #{item}" }
          output << ""
        end
      end
      
      output << "-->"
      output.join("\n")
    end
  end
end
```

### Update Template Generator

Modify template generation to inject style guidelines:

```ruby
# In lib/diataxis/commands/new.rb or similar

def generate_document(type, title)
  style_guidelines = StyleGuidelines.new
  template_content = File.read("templates/#{type}.md.erb")
  
  # Make style guidelines available to ERB template
  erb = ERB.new(template_content)
  erb.result(binding)
end
```

### Update Templates

Modify `templates/project.md.erb`:

```erb
<%= Diataxis::StyleGuidelines.new.render_comment('projects') %>

# Project: <%= title %>

**@urgent** tasks:

- [ ] Task 1

## Context
...
```

## Other Lists

**@waiting** for these tasks:

- [ ] Review YAML structure with team
- [ ] Decide on guideline categories and naming conventions

**@backlog** tasks for later:

- [ ] Add CLI command to preview guidelines: `dia guidelines show projects`
- [ ] Create validator to check documents against guidelines
- [ ] Add configuration file support for custom guideline locations
- [ ] Support organization-specific guideline overrides

**@someday** ideas to revisit:

- [ ] Auto-formatter to apply guidelines to existing documents
- [ ] VS Code extension to show inline guideline hints
- [ ] AI-powered guideline suggestions based on document content

## Project Purpose

**Why does this project matter?**

- **Consistency**: Ensures all documentation follows the same standards
- **Maintainability**: Single source of truth for guidelines reduces drift
- **Flexibility**: Supports both common and document-specific conventions
- **Discoverability**: New users can quickly understand documentation standards
- **Automation**: Enables tooling to validate and enforce guidelines

## Desired Outcome

**What does "done" look like?**

The diataxis gem will:

- Load style guidelines from `data/style_guidelines.yaml`
- Inject appropriate guidelines into generated documents based on type
- Support hierarchical guidelines (common → document-type → template-specific)
- Render guidelines as HTML comments in generated markdown
- Allow users to override guidelines via configuration

Example usage:

```bash
# Generate project with style guidelines
dia project new "My Project"

# Preview guidelines for a document type
dia guidelines show projects

# Validate document against guidelines
dia validate docs/references/projects/my_project.md
```

## Background

**2025-12-04**: Initial design based on experience with `project_automate_the_nuget_installation.md`. Discovered that style guidelines embedded in templates are hard to maintain and apply consistently. Decided on YAML-based approach similar to Hiera for hierarchical data lookups.

Key decisions:

- **YAML over JSON**: More human-readable, supports comments
- **Hierarchical structure**: Common → document-type → template allows maximum flexibility
- **Rendered as comments**: Guidelines stay with document but don't appear in rendered output
- **Extensible**: Organizations can add custom guideline files without modifying gem
