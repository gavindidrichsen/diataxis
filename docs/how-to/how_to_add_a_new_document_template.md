# How to add a new document template

## Description

This guide walks you through adding a new document template type to the Diataxis gem. You'll create all necessary files, update CLI commands, and ensure proper integration with existing functionality.

## Prerequisites

- Ruby development environment
- Access to the diataxis gem source code
- Understanding of Ruby classes and inheritance
- Familiarity with the existing document types (HowTo, Explanation, Tutorial, ADR)

## Usage

### Step 1: Create the new document class file

Create a new Ruby file in `lib/diataxis/document/` following the naming convention:

```bash
# Example: creating a "checklist" document type
touch lib/diataxis/document/checklist.rb
```

### Step 2: Implement the document class

Add the class definition with required methods:

```ruby
# lib/diataxis/document/checklist.rb
require_relative '../document'
require_relative '../config'

module Diataxis
  class Checklist < Document
    def self.pattern(config_root = '.')
      config = Config.load(config_root)
      path = config['checklists'] || '.'
      File.join(path, '**', 'checklist_*.md')
    end

    protected

    def content
      <<~CONTENT
        # #{title}

        ## Purpose
        
        Brief description of what this checklist covers.

        ## Checklist Items

        - [ ] Item 1
        - [ ] Item 2
        - [ ] Item 3

        ## Notes

        Additional context or instructions.
      CONTENT
    end
  end
end
```

### Step 3: Update the main diataxis.rb file

Add the require statement for your new class:

```ruby
# lib/diataxis/diataxis.rb
require_relative 'document/checklist'  # Add this line
```

### Step 4: Update CLI command definitions

Edit the CLI file to add the new command:

```ruby
# bin/diataxis (or wherever CLI commands are defined)
# Add to the case statement or command definitions:
when 'checklist'
  case ARGV[1]
  when 'new'
    title = ARGV[2]
    if title
      doc = Diataxis::Checklist.new(title, directory)
      doc.create
    else
      puts "Usage: diataxis checklist new \"Title\""
      exit 1
    end
  end
```

### Step 5: Update help text and usage information

Add your new document type to help output:

```ruby
# In the help/usage section:
puts "  checklist new \"Title\" - Create a new checklist document"
```

### Step 6: Update configuration handling

If your document type needs custom directory configuration, update the config template:

```ruby
# In config initialization or documentation:
'checklists' => 'docs/checklists'
```

### Step 7: Update ReadmeManager for proper section handling

Add your document type to the section mapping:

```ruby
# lib/diataxis/readme_manager.rb
def get_doc_dir_config(doc_type)
  case doc_type.name.split('::').last.downcase
  when 'checklist' then @config['checklists']  # Add this line
  # ... existing cases
  end
end
```

### Step 8: Test the implementation

```bash
# Test creating a new document
bundle exec dia checklist new "Project setup checklist"

# Verify the file was created
ls docs/checklists/

# Test the update functionality
bundle exec dia update .
```

### Step 9: Add to document types array

Update any arrays that list all document types:

```ruby
# Usually in the main module or CLI handler
DOCUMENT_TYPES = [HowTo, Tutorial, Explanation, ADR, Checklist]
```

## Appendix

### Sample usage output

```bash
$ bundle exec dia checklist new "Deployment checklist"
Created new checklist: /path/to/docs/checklists/checklist_deployment_checklist.md
Found 1 files matching /path/to/docs/checklists/**/checklist_*.md

$ bundle exec dia update .
Found 1 files matching /path/to/docs/checklists/**/checklist_*.md
Found 2 files matching /path/to/docs/how-to/**/how_to_*.md
...
```

### Key files to modify

1. `lib/diataxis/document/<newtype>.rb` - New document class
2. `lib/diataxis/diataxis.rb` - Add require statement
3. `bin/diataxis` - Add CLI command handling
4. `lib/diataxis/readme_manager.rb` - Add section handling
5. Configuration files - Add directory mapping
6. Help text - Add usage information
