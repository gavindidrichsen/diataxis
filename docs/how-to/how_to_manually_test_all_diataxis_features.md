# How to Manually Test All Diataxis Features

## Description

The diataxis gem provides several key features that need testing:

* Configuration management via `.diataxis` file
* Document creation (how-tos, tutorials, ADRs)
* Document renaming based on title changes
* README generation and updates
* Directory structure maintenance

This guide provides a systematic approach to manually test each feature. The test cases are designed to be easily translatable into automated tests.

## Prerequisites

* Ruby installed (version 2.7 or higher)
* Bundler installed
* diataxis gem installed or available locally
* Clean test directory

## Test Cases

### 1. Configuration Management

#### Test Initial Configuration

```bash
# Verify default configuration
rm -f .diataxis
bundle exec dia howto new "Test Document"

# Expected: Creates docs/how-to/how_to_test_document.md
```

#### Test Custom Configuration

```bash
# Create custom configuration
cat > .diataxis << 'EOF'
{
  "readme": "custom/README.md",
  "howtos": "custom/howtos",
  "tutorials": "custom/learn",
  "adr": "custom/decisions"
}
EOF

# Create documents with custom paths
bundle exec dia howto new "Test Custom Path"

# Expected: Creates custom/howtos/how_to_test_custom_path.md
```

### 2. Document Creation

#### Test How-to Creation

```bash
bundle exec dia howto new "Configure System"

# Expected:
# - Creates how_to_configure_system.md
# - Updates README.md with link
# - Uses correct template
```

#### Test Tutorial Creation

```bash
bundle exec dia tutorial new "Getting Started"

# Expected:
# - Creates tutorial_getting_started.md
# - Updates README.md with link
# - Uses correct template
```

#### Test ADR Creation

```bash
bundle exec dia adr new "Use PostgreSQL Database"

# Expected:
# - Creates 0001-use-postgresql-database.md
# - Updates README.md with link
# - Uses correct template and numbering
```

### 3. Document Title Changes

#### Test How-to Title Update

```bash
# Create test document
bundle exec dia howto new "Original Title"

# Edit title in file
sed -i '' '1c\
# How to Updated Title' docs/how-to/how_to_original_title.md

# Update files
bundle exec dia update .

# Expected:
# - Renames file to how_to_updated_title.md
# - Updates README.md link
# - Keeps file in same directory
```

### 4. README Management

#### Test README Creation

```bash
# Remove existing README
rm -f docs/README.md

# Create new document
bundle exec dia howto new "Test README Creation"

# Expected:
# - Creates new README.md
# - Includes standard sections
# - Includes link to new document
```

#### Test README Updates

```bash
# Add custom content to README
echo "Custom project description" >> docs/README.md

# Create new document
bundle exec dia tutorial new "Test README Update"

# Expected:
# - Preserves custom content
# - Adds new document link
# - Maintains existing links
```

### 5. Error Handling

#### Test Invalid Configuration

```bash
# Create invalid JSON
echo "{invalid json}" > .diataxis

# Try to create document
bundle exec dia howto new "Test Error"

# Expected: Clear error message about invalid configuration
```

#### Test Missing Directories

```bash
# Remove docs directory
rm -rf docs

# Create new document
bundle exec dia howto new "Test Missing Directory"

# Expected:
# - Creates necessary directories
# - Creates document successfully
```

## Verification

After running each test case:

1. Check file existence and location
2. Verify file content and formatting
3. Confirm README updates
4. Validate directory structure
5. Check error messages (for error cases)

## Converting to Automated Tests

These manual tests can be automated by:

1. Creating a test fixture directory
2. Using Ruby's FileUtils to set up test conditions
3. Implementing each test case as a separate RSpec example
4. Using file comparison to verify results
5. Capturing and verifying command output

Example test structure:

```ruby
RSpec.describe Diataxis::CLI do
  let(:test_dir) { Dir.mktmpdir }
  after { FileUtils.remove_entry test_dir }

  context "document creation" do
    it "creates how-to with default config" do
      # Test implementation
    end
  end

  context "README management" do
    it "preserves custom content" do
      # Test implementation
    end
  end
end
```
