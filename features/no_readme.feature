Feature: dia does not manage a README

  As a documentation maintainer
  I want dia to only create and rename documents
  So that no generated README gets in the way of the documents themselves

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "default": "docs",
        "adr": "docs/adr"
      }
      """

  Scenario: Creating a document does not create a README
    When I run `bundle exec dia howto new "Configure System"`
    Then the exit status should be 0
    And the file "docs/howto_how_to_configure_system.md" should exist
    And the file "README.md" should not exist
    And the file "docs/README.md" should not exist

  Scenario: Updating renames documents but writes no README
    Given a file named "docs/explanation_old_name.md" with:
      """
      # A Better Name

      Some text.
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0
    And the output should contain "Renamed 1 document(s) to match their titles."
    And the file "docs/explanation_a_better_name.md" should exist
    And the file "docs/explanation_old_name.md" should not exist
    And the file "README.md" should not exist
    And the file "docs/README.md" should not exist

  Scenario: Updating an up-to-date tree says so and changes nothing
    Given a file named "docs/explanation_a_better_name.md" with:
      """
      # A Better Name

      Some text.
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0
    And the output should contain "All document filenames already match their titles."
    And the file "docs/explanation_a_better_name.md" should exist

  Scenario: An existing README is left untouched
    Given a file named "README.md" with:
      """
      # My project
      """
    When I run `bundle exec dia howto new "Configure System"`
    And I run `bundle exec dia update .`
    Then the exit status should be 0
    And the file "README.md" should contain "# My project"
    And the file "README.md" should not contain "howto"

  Scenario: A legacy "readme" key in .diataxis is ignored
    Given a file named ".diataxis" with:
      """
      {
        "default": "docs",
        "readme": "custom/README.md"
      }
      """
    When I run `bundle exec dia howto new "Configure System"`
    Then the exit status should be 0
    And the file "docs/howto_how_to_configure_system.md" should exist
    And the file "custom/README.md" should not exist
