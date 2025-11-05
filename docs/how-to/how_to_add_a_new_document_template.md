# How to add a new document template

## Description

This guide walks you through adding a new document template type to the Diataxis gem. You'll create all necessary files, update CLI commands, and ensure proper integration with existing functionality.

## Prerequisites

- Ruby development environment
- Access to the diataxis gem source code
- Understanding of Ruby classes and inheritance
- Familiarity with the existing document types (HowTo, Explanation, Tutorial, ADR)

## Key files to modify

- `templates/<newtype>.md` - Template file with {{variable}} placeholders
- `lib/diataxis/document/<newtype>.rb` - Document class implementing DocumentInterface methods
- `lib/diataxis/diataxis.rb` - Add require statement, e.g., `require_relative 'document/checklist'`
- `lib/diataxis/cli/command_router.rb` - Add command mapping and routing
- `lib/diataxis/cli/command_handlers.rb` - Add handler method and update config/document types

## Usage

### Step 1: Create the new document class file

Create a new Ruby file in `lib/diataxis/document/` following the naming convention:

```bash
# Example: creating a "checklist" document type
touch lib/diataxis/document/checklist.rb
```

### Step 2: Create the template file

Create a markdown template in the `templates/` directory:

```bash
# Create the template file
touch templates/checklist.md
```

Add the template content:

```markdown
# {{title}}

## Purpose

Brief description of what this checklist covers.

## Checklist Items

- [ ] Item 1
- [ ] Item 2  
- [ ] Item 3

## Notes

Additional context or instructions.
```

### Step 3: Implement the document class

Add the class definition implementing all DocumentInterface methods:

```ruby
# lib/diataxis/document/checklist.rb
require_relative '../document'
require_relative '../config'
require_relative '../template_loader'

module Diataxis
  class Checklist < Document
    # === DocumentInterface Implementation ===
    
    implements :pattern
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['checklists'] || 'docs/checklists'
      File.join(path, '**', 'checklist_*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      first_line = File.open(filepath, &:readline).strip
      return nil unless first_line.start_with?('# ')

      title = first_line[2..]
      slug = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
      "checklist_#{slug}.md"
    end

    implements :matches_filename_pattern?
    def self.matches_filename_pattern?(filename)
      filename.match?(/^checklist_.*\.md$/)
    end

    implements :readme_section_title
    def self.readme_section_title
      'Checklists'
    end

    implements :config_key
    def self.config_key
      'checklists'
    end

    implements :format_readme_entry
    def self.format_readme_entry(title, relative_path, _filepath)
      "* [#{title}](#{relative_path})"
    end

    implements :find_files
    def self.find_files(config_root = '.')
      search_pattern = File.expand_path(pattern(config_root), config_root)
      files = Dir.glob(search_pattern).sort
      Diataxis.logger.info "Found #{files.length} #{name.split('::').last} files matching #{search_pattern}"
      files
    end

    # === End DocumentInterface Implementation ===

    protected

    def content
      TemplateLoader.load_template(self.class, title)
    end
  end
end
```

### Step 4: Update the CLI infrastructure

Add the new document type to multiple CLI files:

**4a. Add to command routing (`lib/diataxis/cli/command_router.rb`):**

```ruby
# Add to COMMAND_MAP hash:
COMMAND_MAP = {
  # ... existing entries ...
  'checklist' => :checklist,  # Add this line
  'update' => :update
}.freeze

# Add to the case statement:
when :checklist
  CommandHandlers.handle_checklist(args)
```

**4b. Add handler method (`lib/diataxis/cli/command_handlers.rb`):**

```ruby
def self.handle_checklist(args)
  validate_document_args!(args, 'checklist')
  create_document_with_readme_update(args, Checklist, 'checklists', [HowTo, Tutorial, Explanation, Checklist])
end
```

**4c. Update default config and document types list:**

```ruby
# In default_config method:
{
  # ... existing config ...
  'checklists' => 'docs/checklists'  # Add this line
}

# In handle_update method:
document_types = [HowTo, Tutorial, Explanation, ADR, Checklist]  # Add Checklist
```

### Step 5: Update the main diataxis.rb file

Add the require statement for your new class:

```ruby
# lib/diataxis.rb
require_relative 'diataxis/document/checklist'  # Add this line
```

### Step 6: Test the implementation

```bash
# Initialize config if not already done
bundle exec dia init

# Test creating a new document
bundle exec dia checklist new "Project setup checklist"

# Verify the file was created
ls docs/checklists/

# Test the update functionality
bundle exec dia update .
```

## Appendix

### Sample usage output

```bash
$ bundle exec dia checklist new "Deployment checklist"
Created new checklist: /path/to/docs/checklists/checklist_deployment_checklist.md
Found 1 Checklist files matching /path/to/docs/checklists/**/checklist_*.md

$ bundle exec dia update .
Found 1 Checklist files matching /path/to/docs/checklists/**/checklist_*.md
Found 2 HowTo files matching /path/to/docs/how-to/**/how_to_*.md
...
```

### Template system benefits

- **External templates**: Easy to edit markdown files in `templates/` directory
- **Variable substitution**: Use `{{title}}`, `{{date}}`, and custom variables
- **AI-friendly**: Templates can be easily analyzed and improved by AI tools
- **Version controlled**: Template changes tracked with clear diffs
- **No code changes**: Template updates don't require Ruby code modifications
