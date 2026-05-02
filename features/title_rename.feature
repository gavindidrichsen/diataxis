Feature: Title Change and Filename Rename
  As a documentation maintainer
  I want document filenames to update when I change the title
  So that filenames always reflect the document content

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "readme": "test_docs/README.md",
        "default": "test_docs",
        "howtos": "test_docs/how-to",
        "tutorials": "test_docs/tutorials",
        "explanations": "test_docs/explanations",
        "adr": "test_docs/adr"
      }
      """

  Scenario: Rename explanation when title changes
    When I run `bundle exec dia explanation new "System Architecture"`
    Then the file "test_docs/explanations/explanation_system_architecture.md" should exist
    Given a file named "test_docs/explanations/explanation_system_architecture.md" with:
      """
      # Advanced System Design

      Updated content about advanced system design.
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0
    And the file "test_docs/explanations/explanation_advanced_system_design.md" should exist
    And the file "test_docs/README.md" should contain "Advanced System Design"
    And the file "test_docs/README.md" should contain "explanation_advanced_system_design.md"

  Scenario: Rename how-to when title changes
    When I run `bundle exec dia howto new "Configure System"`
    Then the file "test_docs/how-to/howto_how_to_configure_system.md" should exist
    Given a file named "test_docs/how-to/howto_how_to_configure_system.md" with:
      """
      # How to Configure Advanced Networking

      Updated guide for networking configuration.
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0
    And the file "test_docs/how-to/howto_how_to_configure_advanced_networking.md" should exist
    And the file "test_docs/README.md" should contain "How to Configure Advanced Networking"

  Scenario: README links update after rename
    When I run `bundle exec dia tutorial new "Getting Started"`
    Given a file named "test_docs/tutorials/tutorial_getting_started.md" with:
      """
      # Quick Start Guide

      A faster way to get started.
      """
    When I run `bundle exec dia update .`
    Then the file "test_docs/README.md" should not contain "tutorial_getting_started.md"
    And the file "test_docs/README.md" should contain "tutorial_quick_start_guide.md"
    And the file "test_docs/README.md" should contain "Quick Start Guide"
