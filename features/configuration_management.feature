Feature: Configuration Management and Document Creation

  As a documentation maintainer
  I want to use custom configuration paths
  So that I can organize my documentation structure

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "readme": "test_docs/README.md",
        "howtos": "test_docs/how-to",
        "tutorials": "test_docs/tutorials",
        "explanations": "test_docs/explanations",
        "adr": "test_docs/adr"
      }
      """

  Scenario: Create a how-to document with custom configuration
    When I run `bundle exec dia howto new "Configure System"`
    Then the exit status should be 0
    And the output should contain "Created new howto:"
    And the file "test_docs/how-to/how_to_configure_system.md" should exist
    And the file "test_docs/README.md" should exist

  Scenario: README contains correct how-to link
    When I run `bundle exec dia howto new "Configure System"`
    Then the file "test_docs/README.md" should contain "### How-To Guides"
    And the file "test_docs/README.md" should contain "How to configure System"
    And the file "test_docs/README.md" should contain "how-to/how_to_configure_system.md"
