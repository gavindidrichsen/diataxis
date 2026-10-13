Feature: dia update targets an explicit directory or DIATAXIS_ROOT

  As a documentation maintainer
  I want dia update to act only where I tell it
  So that running it in the wrong place is an error instead of a silent no-op

  Background:
    Given a file named "proj/.diataxis" with:
      """
      { "default": "docs" }
      """
    And a file named "proj/docs/explanation_old_name.md" with:
      """
      # A Better Name
      """

  Scenario: An explicit directory is updated wherever dia is run from
    Given a directory named "elsewhere"
    When I cd to "elsewhere"
    And I run `bundle exec dia update ../proj`
    Then the exit status should be 0
    And the output should contain "Renamed 1 document(s) to match their titles."
    And the file "../proj/docs/explanation_a_better_name.md" should exist

  Scenario: Without a directory, DIATAXIS_ROOT is updated
    Given I set DIATAXIS_ROOT to the directory "proj"
    When I run `bundle exec dia update`
    Then the exit status should be 0
    And the file "proj/docs/explanation_a_better_name.md" should exist

  Scenario: Without a directory and without DIATAXIS_ROOT it is an error
    When I cd to "proj"
    And I run `bundle exec dia update`
    Then the exit status should be 1
    And the output should contain "DIATAXIS_ROOT is not set"
    And the file "docs/explanation_old_name.md" should exist

  Scenario: Running it from a subdirectory is an error that names the root
    When I cd to "proj/docs"
    And I run `bundle exec dia update .`
    Then the exit status should be 1
    And the output should contain "is not a .diataxis root"
    And the output should contain "run `dia update"
    And the file "explanation_old_name.md" should exist

  Scenario: A directory with no .diataxis is an error
    Given a directory named "bare"
    When I run `bundle exec dia update bare`
    Then the exit status should be 1
    And the output should contain "is not a .diataxis root"
