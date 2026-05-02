Feature: Subdirectory Organization and Recursive Discovery
  As a documentation maintainer
  I want to organize documents in subdirectories
  So that I can structure large documentation sets

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "readme": "test_docs/README.md",
        "default": "test_docs",
        "howtos": "test_docs/how-to",
        "explanations": "test_docs/explanations"
      }
      """

  Scenario: Discover documents in subdirectories
    When I run `bundle exec dia explanation new "System Architecture"`
    And I run `mkdir -p test_docs/explanations/advanced`
    And I run `mv test_docs/explanations/explanation_system_architecture.md test_docs/explanations/advanced/explanation_system_architecture.md`
    And I run `bundle exec dia update .`
    Then the exit status should be 0
    And the file "test_docs/README.md" should contain "System Architecture"
    And the file "test_docs/README.md" should contain "advanced/explanation_system_architecture.md"

  Scenario: Rename documents in subdirectories
    When I run `bundle exec dia explanation new "System Architecture"`
    And I run `mkdir -p test_docs/explanations/advanced`
    And I run `mv test_docs/explanations/explanation_system_architecture.md test_docs/explanations/advanced/explanation_system_architecture.md`
    Given a file named "test_docs/explanations/advanced/explanation_system_architecture.md" with:
      """
      # Advanced Data Structures

      Content about data structures.
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0
    And the file "test_docs/explanations/advanced/explanation_advanced_data_structures.md" should exist
    And the file "test_docs/README.md" should contain "Advanced Data Structures"
    And the file "test_docs/README.md" should contain "advanced/explanation_advanced_data_structures.md"

  Scenario: Mixed top-level and subdirectory documents
    When I run `bundle exec dia explanation new "Overview"`
    And I run `bundle exec dia explanation new "Deep Dive"`
    And I run `mkdir -p test_docs/explanations/advanced`
    And I run `mv test_docs/explanations/explanation_deep_dive.md test_docs/explanations/advanced/explanation_deep_dive.md`
    And I run `bundle exec dia update .`
    Then the file "test_docs/README.md" should contain "Overview"
    And the file "test_docs/README.md" should contain "Deep Dive"
