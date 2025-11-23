# How to run cram tests

## Description

This guide explains how to run Cram tests for the diataxis CLI. Cram is a functional testing framework that executes command-line examples embedded in Markdown files.

## Prerequisites

- Python virtual environment setup (`.venv/`)
- Cram installed via `requirements.txt`
- Test files in `.md` format with executable code blocks

## Usage

### Activate the virtual environment

```bash
source .venv/bin/activate
```

### Run a single test file

```bash
cram test/acceptance/test_configuration_and_initial_creation.md
```

### Run all test files in a directory

```bash
cram test/acceptance/*.md
```

### Run all tests recursively

```bash
cram test/
```

### Run with verbose output

```bash
cram -v test/acceptance/test_configuration_and_initial_creation.md
```

### Clean up before running tests

```bash
rm -rf test_docs && cram test/acceptance/test_configuration_and_initial_creation.md
```

## Appendix

### Sample usage output

Successful test run:

```bash
$ cram test/acceptance/test_configuration_and_initial_creation.md
.
# Ran 1 tests, 0 skipped, 0 failed.
```

Failed test run:

```bash
$ cram test/acceptance/test_configuration_and_initial_creation.md
!
--- test/acceptance/test_configuration_and_initial_creation.md
+++ test/acceptance/test_configuration_and_initial_creation.md.err
@@ -17,7 +17,8 @@
...
# Ran 1 tests, 0 skipped, 1 failed.
```

### Troubleshooting: Virtual environment not activated

If you see `command not found: cram`:

#### Missing cram command

Symptoms: Shell cannot find the `cram` executable

Solution:

- Activate the virtual environment: `source .venv/bin/activate`
- Verify installation: `cram --version`
- Reinstall if needed: `pip install -r requirements.txt`
