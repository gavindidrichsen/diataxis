# 3. Auto-Generate README with Document Links

Date: 2025-02-20

## Status

Accepted

## Context

When using the Diataxis framework, documentation is split into multiple files across different categories (how-tos, tutorials, reference, explanation). This creates several challenges:

* Users need a central place to discover all available documentation
* Links to documents need to stay up-to-date as files are added, removed, or renamed
* Documents should be organized by their type for easy navigation
* Document titles in the index should match their actual content

We could:

* Require manual README maintenance
* Use a separate index file
* Auto-generate the README
* Use a documentation website generator

## Decision

We will automatically generate and update the README.md file with links to all documents. Specifically:

* Use HTML comments as section markers:
   ```markdown
   ### How-Tos
   <!-- howtolog -->
   * [How to do X](how-to/how_to_x.md)
   <!-- howtologstop -->
   ```

* Extract document titles from the first heading in each file
* Generate relative links that work both on GitHub and locally
* Preserve user-added content outside the marked sections
* Update links whenever files are added, removed, or renamed

## Consequences

### Positive

* Links are always up-to-date with actual files
* Document titles in README match their content
* No manual link maintenance required
* Works with GitHub's markdown rendering
* Non-documentation content in README is preserved
* Section markers make it clear which parts are auto-generated

### Negative

* Cannot customize the order of links (they're sorted alphabetically)
* Need to handle relative paths correctly
* Must ensure first heading in files is the correct title
* Section markers in README might confuse users
* Need to handle README creation vs. update differently
