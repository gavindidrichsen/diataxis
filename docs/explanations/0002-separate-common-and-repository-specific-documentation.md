# 2. Separate Common and Repository-Specific Documentation

Date: 2025-03-05

## Status

Accepted

## Context

The project consists of a meta repository containing multiple sub-repositories, each with its own documentation needs. Currently, documentation is scattered across repositories, leading to:

1. Duplication of common documentation (e.g., authentication procedures)
2. Inconsistent locations for similar information
3. Difficulty in maintaining shared procedures
4. Potential confusion for developers about where to find or place documentation

## Decision

We will organize documentation following these principles:

1. Common Documentation (Meta Repository)
   - Place shared how-to guides, tutorials, and ADRs in the meta repository's `.diataxis` directory
   - Common documentation includes:
     - Authentication procedures
     - Environment setup
     - Shared development practices
     - Cross-repository architectural decisions

2. Repository-Specific Documentation (Sub-repositories)
   - Keep repository-specific documentation in each repository's `.diataxis` directory
   - Include:
     - Repository-specific ADRs
     - Component-specific how-to guides
     - Local implementation details
     - Repository-specific tutorials

3. Cross-References
   - Repository-specific documentation should reference common documentation using relative paths
   - Each repository's README should point to both common and specific documentation locations

## Consequences

### Positive

- Eliminates documentation duplication
- Provides clear guidance on documentation placement
- Simplifies maintenance of shared procedures
- Improves discoverability of common practices
- Maintains consistency with Diátaxis framework principles

### Negative

- Requires initial effort to reorganize existing documentation
- Developers need to consider documentation placement carefully
- May need to handle documentation versioning if common procedures vary by repository version
