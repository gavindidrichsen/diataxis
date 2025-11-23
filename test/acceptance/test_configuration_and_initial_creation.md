# Test: Configuration Management + Initial Document Creation + README Generation

This test verifies that:

- Custom `.diataxis` configuration is respected
- Documents are created in the configured directory (not defaults)
- README is automatically generated with correct structure
- Links in README use proper format and paths

## Setup

Setup clean test environment:

  $ cd "$TESTDIR/../.."
  $ cat > .diataxis << 'EOF'
  > {
  >   "readme": "test_docs/README.md",
  >   "howtos": "test_docs/how-to",
  >   "tutorials": "test_docs/tutorials",
  >   "explanations": "test_docs/explanations",
  >   "adr": "test_docs/adr"
  > }
  > EOF
  $ rm -rf test_docs

## Create Document

Test that custom `.diataxis` configuration works:

  $ bundle exec dia howto new "Configure System"
  Created new howto: * (glob)
  Found 1 HowTo files matching * (glob)
  Found 0 Tutorial files matching * (glob)
  Found 0 Explanation files matching * (glob)
  Created new README.md in * (glob)

## Verify Document Creation

Verify custom configuration creates document in `test_docs` (not `docs`):

  $ ls test_docs/how-to/how_to_configure_system.md
  test_docs/how-to/how_to_configure_system.md

## Verify README Generation

Verify README was generated:

  $ test -f test_docs/README.md && echo "README exists"
  README exists

Verify README contains How-To Guides section with correct link:

  $ grep "### How-To Guides" test_docs/README.md
  ### How-To Guides
  $ grep "How to configure System" test_docs/README.md
  * [How to configure System](how-to/how_to_configure_system.md)

## Cleanup

  $ rm -rf test_docs
  $ bundle exec dia init > /dev/null 2>&1
