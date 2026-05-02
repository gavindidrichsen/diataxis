Feature: Section Removal
  As a documentation maintainer
  I want README sections to disappear when their documents are deleted
  So that the README stays clean and accurate

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "readme": "test_docs/README.md",
        "default": "test_docs",
        "howtos": "test_docs/how-to",
        "tutorials": "test_docs/tutorials",
        "explanations": "test_docs/explanations"
      }
      """

  Scenario: Section removed when all documents of that type are deleted
    When I run `bundle exec dia howto new "Configure System"`
    And I run `bundle exec dia tutorial new "Getting Started"`
    Then the file "test_docs/README.md" should contain "### How-To Guides"
    And the file "test_docs/README.md" should contain "### Tutorials"
    When I run `rm test_docs/tutorials/tutorial_getting_started.md`
    And I run `bundle exec dia update .`
    Then the file "test_docs/README.md" should not contain "### Tutorials"
    And the file "test_docs/README.md" should contain "### How-To Guides"

  Scenario: Other sections remain intact after deletion
    When I run `bundle exec dia howto new "Configure System"`
    And I run `bundle exec dia explanation new "System Architecture"`
    And I run `bundle exec dia tutorial new "Getting Started"`
    Then the file "test_docs/README.md" should contain "### How-To Guides"
    And the file "test_docs/README.md" should contain "### Explanations"
    And the file "test_docs/README.md" should contain "### Tutorials"
    When I run `rm test_docs/tutorials/tutorial_getting_started.md`
    And I run `bundle exec dia update .`
    Then the file "test_docs/README.md" should contain "### How-To Guides"
    And the file "test_docs/README.md" should contain "### Explanations"
    And the file "test_docs/README.md" should contain "How to configure System"
    And the file "test_docs/README.md" should contain "System Architecture"
