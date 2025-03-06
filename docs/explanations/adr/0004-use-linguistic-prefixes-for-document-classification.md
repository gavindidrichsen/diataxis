# 4. Use Linguistic Prefixes for Document Classification

Date: 2025-03-06
Status: Accepted

## Context

The Diátaxis framework defines four distinct types of documentation: Tutorials, How-To Guides, Technical Reference, and Explanation. Each type serves a different purpose and follows different writing patterns. When creating and managing these documents, we need a reliable way to:

1. Clearly identify document types at a glance
2. Enforce consistent naming conventions
3. Help authors choose the right document type
4. Maintain alignment with Diátaxis principles

## Decision

We will use linguistic prefixes in both filenames and titles to signal document types:

1. How-To Guides:
   - Filename prefix: `how_to_`
   - Title prefix: "How to"
   - Example: `how_to_configure_system.md` -> "How to Configure System"

2. Tutorials:
   - Filename prefix: `tutorial_`
   - No enforced title prefix
   - Example: `tutorial_getting_started.md` -> "Getting Started with PDK"

3. Explanations:
   - Filename prefix: `understanding_`
   - Title prefix: "Understanding"
   - Example: `understanding_system_architecture.md` -> "Understanding System Architecture"

4. ADRs (Architecture Decision Records):
   - Filename prefix: Sequential number (e.g., `0001-`)
   - Title prefix: Sequential number
   - Example: `0001-use-linguistic-prefixes.md` -> "1. Use Linguistic Prefixes"

The system will:
- Automatically add prefixes if not present
- Prevent double-prefixing
- Update filenames when titles change
- Maintain prefix consistency in README links

## Consequences

### Positive

1. **Immediate Recognition**: Users can quickly identify document types by filename or title
2. **Consistent Structure**: Enforced prefixes maintain documentation organization
3. **Cognitive Aid**: Prefixes help authors frame content appropriately (e.g., "How to" suggests task-focused writing)
4. **Automated Management**: Clear patterns enable automated file management and link updates
5. **Diátaxis Alignment**: Prefixes reinforce the distinct purposes of each document type

### Negative

1. **Longer Filenames**: Prefixes increase filename length
2. **Migration Effort**: Existing documents need updating to follow conventions
3. **Flexibility Trade-off**: Strict naming rules might feel constraining for some authors

### Neutral

1. **SEO Impact**: Prefixes in titles might affect search engine optimization (requires monitoring)
2. **URL Structure**: Consistent prefixes create predictable but longer URLs

## Notes

- Regular expression patterns are used to detect and manage prefixes
- The system includes safeguards against double-prefixing
- Future document types can adopt similar linguistic patterns
What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?
