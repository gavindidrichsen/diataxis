Feature: YAML Front Matter Support
  As a documentation maintainer
  I want to use YAML front matter in my markdown documents
  So that I can add metadata like aliases and tags

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "howtos": "docs/how-tos"
      }
      """

  Scenario: Extract title from document with YAML front matter
    Given a file named "docs/how-tos/howto_setup_server.md" with:
      """
      ---
      aliases:
        - "How to Setup Server"
      tags:
        - server
        - infrastructure
      ---

      # How to Setup Server on Linux

      ## Description

      This guide shows you how to setup a server.
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0

  Scenario: Extract title from document without YAML front matter
    Given a file named "docs/how-tos/howto_deploy_app.md" with:
      """
      # How to Deploy Application

      ## Description

      This guide shows you how to deploy an application.
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0

  Scenario: Handle multiple documents with mixed front matter
    Given a file named "docs/how-tos/howto_with_metadata.md" with:
      """
      ---
      tags:
        - test
      ---

      # How to Test with Metadata

      Content here.
      """
    And a file named "docs/how-tos/howto_without_metadata.md" with:
      """
      # How to Test without Metadata

      Content here.
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0

  Scenario: Update a document that gains YAML front matter
    When I run `bundle exec dia howto new "Configure Database"`
    Then the exit status should be 0
    And the file "docs/how-tos/howto_how_to_configure_database.md" should exist
    Given I append to "docs/how-tos/howto_how_to_configure_database.md" with:
      """
      ---
      aliases:
        - "Database Configuration"
      tags:
        - database
      ---
      """
    When I run `bundle exec dia update .`
    Then the exit status should be 0
    And the file "docs/how-tos/howto_how_to_configure_database.md" should exist
