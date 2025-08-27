# How to manually test all diataxis features

## Description

The diataxis gem provides several key features that need testing:

* Configuration management via `.diataxis` file
* Document creation (how-tos, tutorials, explanations, ADRs)
* Document renaming based on title changes
* README generation and updates
* Directory structure maintenance
* **Subdirectory organization support** - documents can be organized in nested subdirectories
* **Recursive document discovery** - finds documents at any depth within configured directories

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

#### Test Explanation Creation

```bash
# Test basic creation
bundle exec dia explanation new "Testing in Facts Module"

# Expected:
# - Creates understanding_testing_in_facts_module.md
# - Title starts with "Understanding"
# - Updates README.md with link
# - Uses correct template with Purpose, Background, Key Concepts sections

# Test with existing 'Understanding' prefix
bundle exec dia explanation new "Understanding Configuration Management"

# Expected:
# - Creates understanding_configuration_management.md (no double prefix)
# - Keeps "Understanding" prefix in title
# - Updates README.md with link

# Test title changes
sed -i '' $'1c\\n# Understanding Advanced Configuration Patterns' docs/explanations/understanding_configuration_management.md
bundle exec dia update .

# Expected:
# - Renames file to understanding_advanced_configuration_patterns.md
# - Updates README.md link to match new title
# - Preserves 'Understanding' prefix in both filename and title
# - Maintains correct document structure and content
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

### 5. Subdirectory Organization

#### Test Moving Documents to Subdirectories

```bash
# Create a document first
bundle exec dia explanation new "Complex System Architecture"

# Verify it's in the README
cat docs/README.md | grep "Complex System Architecture"

# Create a subdirectory and move the document
mkdir -p docs/explanations/understanding_complex_system_architecture
mv docs/explanations/understanding_complex_system_architecture.md \
   docs/explanations/understanding_complex_system_architecture/understanding_complex_system_architecture.md

# Update and verify the README is updated correctly
bundle exec dia update .

# Expected:
# - README link updates to new subdirectory path
# - Document is not removed from README
# - Link points to: explanations/understanding_complex_system_architecture/understanding_complex_system_architecture.md
```

#### Test Creating Documents in Existing Subdirectories

```bash
# Create subdirectory structure
mkdir -p docs/how-to/advanced_topics

# Create document normally (will be placed in standard location)
bundle exec dia howto new "Advanced Configuration"

# Move to subdirectory to test recursive discovery
mv docs/how-to/how_to_advanced_configuration.md \
   docs/how-to/advanced_topics/how_to_advanced_configuration.md

# Edit the title to test filename updates in subdirectories
sed -i '' '1c\
# How to Master Advanced Configuration' docs/how-to/advanced_topics/how_to_advanced_configuration.md

# Update and verify
bundle exec dia update .

# Expected:
# - File is renamed within the subdirectory (not moved to parent)
# - New filename: how_to_master_advanced_configuration.md
# - README link updates to reflect new title and location
# - Path in README: how-to/advanced_topics/how_to_master_advanced_configuration.md
```

#### Test Mixed Directory Structures

```bash
# Create documents in both flat and nested structures
bundle exec dia tutorial new "Basic Tutorial"
bundle exec dia tutorial new "Advanced Tutorial"

# Create subdirectory for advanced content
mkdir -p docs/tutorials/advanced
mv docs/tutorials/tutorial_advanced_tutorial.md \
   docs/tutorials/advanced/tutorial_advanced_tutorial.md

# Add supporting files to demonstrate organization
mkdir -p docs/tutorials/advanced/examples
echo "# Example Code" > docs/tutorials/advanced/examples/sample.md

# Update and verify both are found
bundle exec dia update .

# Expected:
# - Both tutorials appear in README
# - Flat structure tutorial: tutorials/tutorial_basic_tutorial.md
# - Nested structure tutorial: tutorials/advanced/tutorial_advanced_tutorial.md
# - Supporting files are ignored (not markdown with correct prefix)
```

### 6. Error Handling

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
6. **Verify subdirectory support**: Ensure documents in subdirectories are discovered and linked correctly
7. **Confirm path resolution**: Check that relative paths in README links work correctly
