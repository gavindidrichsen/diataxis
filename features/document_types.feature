Feature: All Document Types
  As a documentation maintainer
  I want to create each document type
  So that I can organize documentation using the Diataxis framework

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "default": "test_docs",
        "howtos": "test_docs/how-to",
        "tutorials": "test_docs/tutorials",
        "explanations": "test_docs/explanations",
        "adr": "test_docs/adr",
        "idr": "test_docs/idr",
        "wow": "test_docs/wow",
        "projects": "test_docs/projects"
      }
      """

  Scenario: Create a tutorial document
    When I run `bundle exec dia tutorial new "Getting Started"`
    Then the exit status should be 0
    And the file "test_docs/tutorials/tutorial_getting_started.md" should exist

  Scenario: Create an explanation document
    When I run `bundle exec dia explanation new "System Architecture"`
    Then the exit status should be 0
    And the file "test_docs/explanations/explanation_system_architecture.md" should exist

  Scenario: Create an ADR with automatic numbering
    When I run `bundle exec dia adr new "Use PostgreSQL Database"`
    Then the exit status should be 0
    And the file "test_docs/adr/0001-use-postgresql-database.md" should exist

  Scenario: Create multiple ADRs with sequential numbering
    When I run `bundle exec dia adr new "Use PostgreSQL Database"`
    And I run `bundle exec dia adr new "Use CLI Front End"`
    Then the exit status should be 0
    And the file "test_docs/adr/0001-use-postgresql-database.md" should exist
    And the file "test_docs/adr/0002-use-cli-front-end.md" should exist

  Scenario: Create a WoW record
    When I run `bundle exec dia wow new "Branch Discipline"`
    Then the exit status should be 0
    And the file "test_docs/wow/wow_branch_discipline.md" should exist

  Scenario: Create a project document
    When I run `bundle exec dia project new "API Migration"`
    Then the exit status should be 0

  Scenario: Create a PR document
    When I run `bundle exec dia pr new "Refactor Auth Module"`
    Then the exit status should be 0
    And the file "test_docs/explanations/pr_refactor_auth_module.md" should exist

  Scenario: Create a 5 Whys document
    When I run `bundle exec dia fivewhy new "Deploy Script Silently Failed"`
    Then the exit status should be 0
    And the file "test_docs/explanations/fivewhy_deploy_script_silently_failed.md" should exist
