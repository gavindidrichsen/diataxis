Feature: Document Tagging
  As a documentation maintainer
  I want to tag documents with metadata
  So that I can categorize and filter documentation

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "readme": "test_docs/README.md",
        "default": "test_docs",
        "explanations": "test_docs/explanations",
        "notes": "test_docs/notes"
      }
      """

  Scenario: Create document with --tag flag
    When I run `bundle exec dia explanation new "Tagged Document" --tag backend`
    Then the exit status should be 0
    And the file "test_docs/explanations/explanation_tagged_document.md" should contain "tags:"
    And the file "test_docs/explanations/explanation_tagged_document.md" should contain "- backend"

  Scenario: Create document with multiple tags using -t shorthand
    When I run `bundle exec dia explanation new "Multi Tagged" --tag backend -t api`
    Then the exit status should be 0
    And the file "test_docs/explanations/explanation_multi_tagged.md" should contain "- backend"
    And the file "test_docs/explanations/explanation_multi_tagged.md" should contain "- api"

  Scenario: Document without tags has no YAML front matter tags
    When I run `bundle exec dia explanation new "Untagged Document"`
    Then the exit status should be 0
    And the file "test_docs/explanations/explanation_untagged_document.md" should not contain "tags:"

  Scenario: Tags from DIATAXIS_TAG environment variable
    Given I set the environment variable "DIATAXIS_TAG" to "sprint-42, infrastructure"
    When I run `bundle exec dia note new "Env Tagged Note"`
    Then the exit status should be 0
    And the file "test_docs/notes/note_env_tagged_note.md" should contain "- sprint-42"
    And the file "test_docs/notes/note_env_tagged_note.md" should contain "- infrastructure"

  Scenario: Merge CLI and env tags with deduplication
    Given I set the environment variable "DIATAXIS_TAG" to "sprint-42, infrastructure"
    When I run `bundle exec dia note new "Merged Tags Note" --tag infrastructure -t monitoring`
    Then the exit status should be 0
    And the file "test_docs/notes/note_merged_tags_note.md" should contain "- sprint-42"
    And the file "test_docs/notes/note_merged_tags_note.md" should contain "- infrastructure"
    And the file "test_docs/notes/note_merged_tags_note.md" should contain "- monitoring"
