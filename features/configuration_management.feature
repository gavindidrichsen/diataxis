Feature: Configuration Management and Document Creation

  As a documentation maintainer
  I want to use custom configuration paths
  So that I can organize my documentation structure

  Background:
    Given a file named ".diataxis" with:
      """
      {
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
    And the file "test_docs/how-to/howto_how_to_configure_system.md" should exist

  Scenario: An empty .diataxis applies every default
    Given a file named "empty/.diataxis" with:
      """
      """
    When I cd to "empty"
    And I run `bundle exec dia howto new "Configure System"`
    Then the exit status should be 0
    And the file "docs/howto_how_to_configure_system.md" should exist

  Scenario: A commented .diataxis with an empty object applies every default
    Given a file named "commented/.diataxis" with:
      """
      // Sample override (all optional):
      //   { "howtos": "docs/guides" }
      {}
      """
    When I cd to "commented"
    And I run `bundle exec dia adr new "Use Postgres"`
    Then the exit status should be 0
    And the file "docs/adr/0001-use-postgres.md" should exist

  Scenario: A // comment inside the object does not stop an override applying
    Given a file named "override/.diataxis" with:
      """
      {
        // guides live here
        "howtos": "docs/guides"
      }
      """
    When I cd to "override"
    And I run `bundle exec dia howto new "Configure System"`
    Then the exit status should be 0
    And the file "docs/guides/howto_how_to_configure_system.md" should exist

  Scenario: dia init writes an empty object under a commented sample
    Given a directory named "fresh"
    When I cd to "fresh"
    And I run `bundle exec dia init`
    Then the exit status should be 0
    And the file ".diataxis" should contain "// dia reads this file as JSON"
    And the file ".diataxis" should contain "{}"
    And I run `bundle exec dia howto new "Configure System"`
    And the file "docs/howto_how_to_configure_system.md" should exist

  Scenario: Invalid JSON in .diataxis is a clear error, not a stack trace
    Given a file named "broken/.diataxis" with:
      """
      { not json
      """
    When I cd to "broken"
    And I run `bundle exec dia howto new "Configure System"`
    Then the exit status should be 1
    And the output should contain "is not valid JSON"
    And the output should not contain "from "
