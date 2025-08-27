# 7. Enable Recursive Document Discovery

Date: 2025-08-27

## Status

Accepted

## Context

As documentation projects grow, users often need to organize documents into subdirectories for better structure and readability. For example, complex explanations might benefit from being placed in dedicated subdirectories with supporting files:

```text
docs/explanations/
├── understanding_simple_concepts.md
└── understanding_complex_system/
    ├── understanding_complex_system.md
    ├── supporting_diagrams/
    └── additional_resources/
```

However, the original diataxis implementation only searched for documents directly within configured directories using non-recursive glob patterns like `docs/explanations/understanding_*.md`. This meant that when users moved documents into subdirectories for better organization, the tool would:

1. No longer find the moved documents
2. Remove them from README.md links entirely
3. Fail to update filenames when titles changed
4. Not include them in bulk operations

This limitation forced users to keep all documents in flat directory structures, which doesn't scale well for complex documentation projects.

## Decision

We will enable recursive document discovery by:

1. **Updating all document type patterns** to include recursive search:
   - `HowTo`: `how_to_*.md` → `**/how_to_*.md`
   - `Tutorial`: `tutorial_*.md` → `**/tutorial_*.md`
   - `Explanation`: `understanding_*.md` → `**/understanding_*.md`
   - `ADR`: `[0-9][0-9][0-9][0-9]-*.md` → `**/[0-9][0-9][0-9][0-9]-*.md`

2. **Preserving subdirectory structure** during filename updates:
   - Files remain in their original subdirectory when renamed
   - Target directory calculation respects the relative path structure
   - No unwanted file moves to parent directories

3. **Maintaining correct relative paths** in README links:
   - Calculate proper relative paths from README location to subdirectory files
   - Ensure links work regardless of document depth

4. **Supporting both flat and nested structures**:
   - Documents can exist directly in configured directories
   - Documents can exist in any subdirectory depth
   - Mixed organization approaches are supported

## Consequences

### What becomes easier

1. **Better Organization**: Users can organize complex topics into dedicated subdirectories with supporting materials
2. **Scalability**: Documentation projects can grow without being constrained to flat structures
3. **Flexibility**: Teams can choose the organization approach that best fits their content
4. **Migration**: Existing flat structures continue to work unchanged
5. **Discoverability**: README links automatically include documents regardless of location depth

### What becomes more complex

1. **Search Performance**: Recursive glob patterns may be slightly slower on very large directory trees
2. **Path Resolution**: More complex logic needed to calculate correct relative paths and target directories
3. **Debugging**: File location issues may be harder to diagnose in deeply nested structures

### Neutral impacts

1. **Backward Compatibility**: Existing flat directory structures continue to work unchanged
2. **Configuration**: No changes needed to existing `.diataxis` configuration files
3. **User Interface**: All commands work identically regardless of document organization
