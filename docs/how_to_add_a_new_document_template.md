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
      path = Config.path_for('checklists')
      File.join(path, '**', 'checklist_*.md')
    end

    implements :generate_filename_from_file
    def self.generate_filename_from_file(filepath)
      # Extract title from file content, skipping YAML front matter and HTML comments
      title = MarkdownUtils.extract_title(filepath)
      return nil if title.nil?

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

# Add to HANDLER_MAP hash:
HANDLER_MAP = {
  # ... existing entries ...
  checklist: ->(args) { CommandHandlers.handle_checklist(args) },  # Add this line
  update: ->(args) { CommandHandlers.handle_update(args) }
}.freeze
```

**4b. Add handler method (`lib/diataxis/cli/command_handlers.rb`):**

```ruby
def self.handle_checklist(args)
  validate_document_args!(args, 'checklist')
  create_document_with_readme_update(args, Checklist, 'checklists', [HowTo, Tutorial, Explanation, Checklist])
end
```

**4c. Update Config::DEFAULT_CONFIG and document types list:**

Below is the default document structure.  All document types except for `adr` and `readme` will be placed beneathe the `default` directory:

```ruby
# In lib/diataxis/config.rb, add to DEFAULT_CONFIG:
DEFAULT_CONFIG = {
  'default' => 'docs',
  'readme' => 'README.md',
  'adr' => 'docs/adr',
}.freeze

# In lib/diataxis/cli/command_handlers.rb handle_update method:
document_types = [HowTo, Tutorial, Explanation, ADR, Checklist]  # Add Checklist
```

If, however, you want all `checklists` by default to go to a different directory, then you can either make this customzation by hand in the `.diataxis` or more permanently in this `DEFAULT_CONFIG`.  Favour intermittent changes in the `.diataxis`.  If, on the other hand, you find yourself always placing a new document in another specific directory, then consider updating the default `DEFAULT_CONFIG`

### Step 5: Update the main diataxis.rb file

Add the require statement for your new class:

```ruby
# lib/diataxis/diataxis.rb
require_relative 'document/checklist'  # Add this line
```

### Step 6: Update the help text

Add the new command to the CLI help output in `lib/diataxis/cli/usage_display.rb`:

```ruby
# In the build_usage_text method, add to the Commands section:
Commands:
  init                  - Initialize .diataxis config file
  howto new "Title"     - Create a new how-to guide
  tutorial new "Title"  - Create a new tutorial
  adr new "Title"      - Create a new architectural decision record
  explanation new "Title" - Create a new explanation document
  checklist new "Title" - Create a new checklist document  # Add this line
  update <directory>    - Update document filenames and README.md
```

### Step 7: Add tests for the new document type

Update the test suite in `spec/diataxis_spec.rb` to include your new document type:

**7a. Update test configuration:**

```ruby
# In the before block, add to the config hash:
config = {
  'readme' => 'docs/README.md',
  'howtos' => 'docs/how-to', 
  'tutorials' => 'docs/tutorials',
  'explanations' => 'docs/explanations',
  'adr' => 'docs/exp/adr',
  'checklists' => 'docs/checklists'  # Add this line
}
```

**7b. Add test paths:**

```ruby
# In the docs_paths let block:
let(:docs_paths) do
  {
    docs: File.join(test_dir, 'docs'),
    howto: File.join(test_dir, 'docs/how-to'),
    # ... existing paths ...
    checklist: File.join(test_dir, 'docs/checklists'),  # Add this line
    readme: File.join(test_dir, 'docs/README.md')
  }
end
```

**7c. Add document creation test:**

```ruby
context 'creating checklist' do
  it 'creates checklist with correct template and updates README' do
    Dir.chdir(test_dir) do
      Diataxis::CLI.run(['checklist', 'new', 'Deployment Checklist'])
    end

    checklist_path = File.join(docs_paths[:checklist], 'checklist_deployment_checklist.md')
    expect(File).to exist(checklist_path)

    content = File.read(checklist_path)
    aggregate_failures do
      expect(content).to include('# Deployment Checklist')
      expect(content).to include('## Purpose') 
      expect(content).to include('## Checklist Items')
    end

    readme_content = File.read(docs_paths[:readme])
    expect(readme_content).to include('[Deployment Checklist]')
    expect(readme_content).to include('### Checklists')
  end
end
```

**Note:** Use `aggregate_failures` when checking multiple template sections to avoid RuboCop's `RSpec/MultipleExpectations` warning (limit is 4 expectations per test).

**7d. Update help text test:**

```ruby
# Add to the help text test:
it 'includes remaining document types in help text' do
  Diataxis::CLI.run([])
rescue Diataxis::UsageError => e
  expect(e.usage_message).to include('adr new "Title"')
  expect(e.usage_message).to include('explanation new "Title"')
  expect(e.usage_message).to include('checklist new "Title"')  # Add this line
end
```

### Step 8: Test the implementation

```bash
# Run the test suite to verify integration
bundle exec rspec

# Verify help shows the new command
bundle exec dia --help

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
