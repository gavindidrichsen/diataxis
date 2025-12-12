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

## Setup

Before running any tests, configure diataxis to use test_docs instead of docs:

```bash
# Update .diataxis to use test_docs for all paths
cat > .diataxis << 'EOF'
{
  "default": "test_docs",
  "readme": "test_docs/README.md",
  "adr": "test_docs/adr",
  "projects": "test_docs/_gtd"
}
EOF

# Start clean to test custom configuration behavior
rm -rf test_docs
```

This ensures all test documents are created in test_docs/ instead of docs/, keeping your actual documentation separate.

### Test 1: Configuration Management + Initial Document Creation + README Generation

```bash
# Test that custom .diataxis configuration works
bundle exec dia howto new "Configure System"

# Expected:
# Verify document creation: Uses correct template and filename normalization  

# Verify custom configuration: Creates test_docs/how-to/how_to_configure_system.md (not docs/)
ls test_docs/how_to_configure_system.md

# Verify README content
# ✅ README generation: Creates new README.md with standard structure
# ✅ Dynamic sections: Only shows "HowTos" section in README (has content)
# ✅ Link format: README contains correct link, [How to configure System](how-to/how_to_configure_system.md)
cat test_docs/README.md
```

### Test 2: Multiple Document Types + Dynamic Section Management

```bash
# Add different document types to test dynamic section appearance
bundle exec dia tutorial new "Getting Started"
bundle exec dia explanation new "System Architecture"

# Add 2 ADRs
bundle exec dia adr new "Use PostgreSQL Database"
bundle exec dia adr new "Use CLI front end"

# Expected:
# ✅ Document creation: All 4 document types created with correct templates
# ✅ Dynamic sections: All 4 sections now appear in README (HowTos, Tutorials, Explanations, Design Decisions)
# ✅ Section order: Correct order maintained
# ✅ ADR numbering: ADR gets 0001- and 0002 prefixes
# ✅ Explanation prefix: Gets "Understanding" prefix in title
# ✅ Link formats: Each type uses correct link format

# Verify all sections appeared
cat test_docs/README.md

# Verify expected file structure:
find test_docs -type f
# test_docs/explanations/understanding_system_architecture.md
# test_docs/adr/0001-use-postgresql-database.md
# test_docs/adr/0002-use-cli-front-end.md
# test_docs/how-to/how_to_configure_system.md
# test_docs/README.md
# test_docs/tutorials/tutorial_getting_started.md
```

### Test 3: Title Changes + Filename Updates + README Updates

```bash
# Test title changes and filename synchronization
sed -i '' '1c\
# Understanding Advanced System Design' test_docs/understanding_system_architecture.md

bundle exec dia update .

# Expected:
# ✅ Filename update: File renamed to understanding_advanced_system_design.md
# ✅ README update: Link text and path updated in README
# ✅ Same directory: File stays in same directory
# ✅ Prefix preservation: "Understanding" prefix maintained

# Verify the file was renamed and README updated
ls test_docs/explanations/
cat test_docs/README.md | grep "Advanced System Design"
```

### Test 4: Section Removal + README Cleanup

```bash
# Test section removal by deleting all tutorials
rm test_docs/tutorial_getting_started.md
bundle exec dia update .

# Expected:
# ✅ Section removal: "Tutorials" section completely removed from README
# ✅ Clean removal: No empty section headers or comment tags remain
# ✅ Other sections: All other sections remain intact with correct links

# Verify tutorials section was completely removed
cat test_docs/README.md
```

### Test 5: Subdirectory Organization + Recursive Discovery

```bash
# Test moving documents to subdirectories
mkdir -p test_docs/explanations/advanced
mv test_docs/understanding_advanced_system_design.md \
   test_docs/explanations/advanced/understanding_advanced_system_design.md

bundle exec dia update .

# Expected:
# ✅ Recursive discovery: Both documents found in subdirectories
# ✅ README links: Links updated with correct subdirectory paths
# ✅ Path resolution: Relative paths work from README location

# Verify subdirectory documents appear in README with correct paths
cat test_docs/README.md
```

### Test 6: Filename Updates in Subdirectories

```bash
### Test 6: Filename Updates in Subdirectories + README Sync

```bash
# Test filename updates work in subdirectories
sed -i '' '1s/.*/# Understanding Super Duper Advanced Data Structures/' test_docs/explanations/advanced/understanding_advanced_system_design.md
bundle exec dia update .

ls test_docs/explanations/advanced
cat test_docs/README.md
```

## Cleanup

After completing all tests, clean up the test directory:

```bash
# Remove all test documents
rm -rf test_docs

# restore default configuration
bundle exec dia init

cat .diataxis
cat .diataxis | grep "docs/README.md"
```
