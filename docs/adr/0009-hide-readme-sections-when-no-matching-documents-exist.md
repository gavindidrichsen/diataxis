# 9. Hide README sections when no matching documents exist

Date: 2025-11-04

## Status

Proposed

## Context

The README.md generation was creating sections for all document types (HowTos, Tutorials, Explanations, ADRs, Checklists) regardless of whether any documents of that type actually existed. This resulted in:

1. **Visual Clutter**: Empty sections with only comment tags (`<!-- tutoriallog --><!-- tutoriallogstop -->`) appeared in the README
2. **Poor User Experience**: Readers saw incomplete or placeholder sections that provided no value
3. **Maintenance Overhead**: Empty sections suggested missing documentation that may not be relevant to the project
4. **Inconsistent Presentation**: Projects with different documentation needs showed identical section structures

For example, a project focused only on ADRs and how-to guides would still show empty Tutorial and Explanation sections, creating confusion about the project's documentation scope.

## Decision

Modify the ReadmeManager to implement dynamic section visibility based on content availability:

1. **Update `update_existing_readme` method**: Check if sections have content before including them, and remove empty sections entirely
2. **Add `remove_section` method**: Cleanly remove sections (including headings) when they become empty
3. **Modify `create_new_readme` method**: Use `filter_map` to only generate sections that contain actual documents
4. **Preserve comment tags**: Maintain the tagging system for sections that do exist to enable future updates

The implementation ensures sections appear dynamically:

- When documents are added → section automatically appears in README
- When documents are removed → section automatically disappears from README
- Existing sections with content remain unchanged

## Consequences

### What becomes easier

1. **Clean Documentation**: READMEs now present only relevant document types, improving readability
2. **Project Clarity**: Users immediately understand what documentation exists without scrolling past empty sections
3. **Dynamic Adaptation**: Projects can evolve their documentation structure naturally without manual README maintenance
4. **Professional Presentation**: Generated READMEs appear polished and intentionally curated

### What becomes more difficult

1. **Section Predictability**: Developers can't assume all document type sections will always be present
2. **Template Consistency**: Different projects may have different README structures based on their document types

### Risks Mitigated

1. **Backward Compatibility**: Existing functionality preserved - sections with content continue working exactly as before
2. **Reversibility**: Adding documents immediately restores sections, so the change is fully reversible
3. **Robust Implementation**: The tagging system continues to work for section updates and additions

The change significantly improves the user experience of generated documentation while maintaining all existing functionality and automation benefits.
