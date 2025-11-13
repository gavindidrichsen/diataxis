# Test: Configuration Management with BashTest

This test verifies configuration and document creation.

## Setup

```bash
cat > .diataxis << 'EOF'
{
  "readme": "test_docs/README.md",
  "howtos": "test_docs/how-to",
  "tutorials": "test_docs/tutorials",
  "explanations": "test_docs/explanations",
  "adr": "test_docs/adr"
}
EOF
rm -rf test_docs
```

## Create Document

```bash
bundle exec dia howto new "Configure System"
```
```output
Created new howto: /Users/gavin.didrichsen/@REFERENCES/github/app/development/languages/ruby/libraries/diataxis/test_docs/how-to/how_to_configure_system.md
Found 1 HowTo files matching /Users/gavin.didrichsen/@REFERENCES/github/app/development/languages/ruby/libraries/diataxis/test_docs/how-to/**/how_to_*.md
Found 0 Tutorial files matching /Users/gavin.didrichsen/@REFERENCES/github/app/development/languages/ruby/libraries/diataxis/test_docs/tutorials/**/tutorial_*.md
Found 0 Explanation files matching /Users/gavin.didrichsen/@REFERENCES/github/app/development/languages/ruby/libraries/diataxis/test_docs/explanations/**/understanding_*.md
Created new README.md in /Users/gavin.didrichsen/@REFERENCES/github/app/development/languages/ruby/libraries/diataxis
```

## Verify Document

```bash
test -f test_docs/how-to/how_to_configure_system.md && echo "File exists"
```
```output
File exists
```

## Cleanup

```bash
rm -rf test_docs
bundle exec dia init > /dev/null 2>&1
```
