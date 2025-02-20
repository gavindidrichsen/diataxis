# 1. Adopt Diataxis Documentation Framework

Date: 2025-02-20

## Status

Accepted

## Context

Documentation in software projects often suffers from several problems:

* Mixed concerns - tutorials mixed with reference material
* Unclear purpose - readers can't find what they need
* Missing context - documentation doesn't address why something should be done
* Inconsistent structure - each document follows its own format
* Maintenance burden - no clear guidelines on what to document or how

We need a systematic approach that:

* Serves different user needs (learning, problem-solving, understanding)
* Provides clear organization principles
* Scales with project growth
* Is easy for contributors to follow

## Decision

We will adopt the [Diataxis Framework](https://diataxis.fr/) which organizes documentation into four distinct types:

* Tutorials (Learning-oriented)
  * Hands-on introduction to the system
  * Learning by doing
  * Carefully structured sequence of steps

* How-to Guides (Task-oriented)
  * Practical step-by-step guides
  * Problem-solving approach
  * Real-world use cases

* Reference (Information-oriented)
  * Technical descriptions
  * Accurate and complete information
  * Structured access to facts

* Explanation (Understanding-oriented)
  * Background and context
  * Clarifies concepts
  * Discusses alternatives and history

We will:

* Create separate directories for each documentation type
* Use consistent naming patterns (e.g., `how_to_*.md`, `tutorial_*.md`)
* Provide templates for each type
* Automatically organize documents by type in the README

## Consequences

### Positive

* Clear organization makes documentation more discoverable
* Separation of concerns improves maintainability
* Templates make it easier to write documentation
* Consistent structure helps readers know what to expect
* Framework provides clear guidance on what belongs where
* Each document type can be optimized for its purpose

### Negative

* More initial setup required
* Need to train contributors on the framework
* Some content might not clearly fit one category
* More complex directory structure
* May need to refactor existing documentation
