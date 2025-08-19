# 5. Use Purpose-Driven Document Templates

Date: 2025-03-06
Status: Accepted

## Context

The Diátaxis framework emphasizes that different documentation types serve distinct purposes:
- Tutorials are learning-oriented
- How-To Guides are task-oriented
- Explanations are understanding-oriented
- Reference is information-oriented

When authors create new documents, they need guidance to:
1. Stay focused on the document's primary purpose
2. Include essential sections for that document type
3. Maintain consistency across the documentation
4. Follow Diátaxis principles effectively

## Decision

We will provide purpose-driven templates for each document type, with sections and prompts that reinforce their distinct roles:

1. How-To Guides Template:
```markdown
# How to [Task Name]

## Prerequisites
[What does the user need before starting?]

## Steps
1. First step...
2. Next step...

## Verification
[How can the user verify success?]

## Troubleshooting
[Common issues and solutions]
```

2. Explanation Template:
```markdown
# Understanding [Topic]

## Purpose
This document answers:
- Why do we do things this way?
- What are the core concepts?
- How do the pieces fit together?

## Background
[Context and fundamental concepts]

## Key Concepts
### Concept 1
[Explanation...]

## Related Topics
[Cross-references]
```

3. Tutorial Template:
```markdown
# [Learning Goal]

## Learning Objectives
- What you'll learn
- What you'll build

## Prerequisites
[Required knowledge/setup]

## Steps
1. First learning step...
   [Include explanations]

## Next Steps
[Further learning paths]
```

4. ADR Template:
```markdown
# [Number]. [Title]

Date: [YYYY-MM-DD]
Status: [Proposed/Accepted/Deprecated]

## Context
[Decision background]

## Decision
[Chosen approach]

## Consequences
[Outcomes and trade-offs]
```

## Consequences

### Positive

1. **Guided Writing**: Templates help authors focus on appropriate content
2. **Consistent Structure**: Users know where to find information
3. **Purpose Alignment**: Section prompts reinforce Diátaxis principles
4. **Reduced Cognitive Load**: Authors don't need to design document structure
5. **Quality Control**: Essential sections aren't forgotten

### Negative

1. **Initial Resistance**: Authors might feel constrained by templates
2. **Template Maintenance**: Need to evolve templates based on feedback
3. **Edge Cases**: Some documents might not fit templates perfectly

### Neutral

1. **Learning Curve**: New authors need to understand template purposes
2. **Template Variations**: Different teams might need customized templates

## Notes

- Templates are enforced through the document creation process
- Placeholders guide authors without being prescriptive
- Templates focus on structure, not content style
What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?
