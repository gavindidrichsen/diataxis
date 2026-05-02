Feature: All Document Types
  As a documentation maintainer
  I want to create all 9 document types
  So that I can organize documentation using the Diataxis framework

  Background:
    Given a file named ".diataxis" with:
      """
      {
        "readme": "test_docs/README.md",
        "default": "test_docs",
        "howtos": "test_docs/how-to",
        "tutorials": "test_docs/tutorials",
        "explanations": "test_docs/explanations",
        "adr": "test_docs/adr",
        "notes": "test_docs/notes",
        "handovers": "test_docs/handovers",
        "5whys": "test_docs/5whys",
        "projects": "test_docs/projects"
      }
      """

  Scenario: Create a tutorial document
    When I run `bundle exec dia tutorial new "Getting Started"`
    Then the exit status should be 0
    And the file "test_docs/tutorials/tutorial_getting_started.md" should exist
    And the file "test_docs/README.md" should contain "### Tutorials"
    And the file "test_docs/README.md" should contain "Getting Started"

  Scenario: Create an explanation document
    When I run `bundle exec dia explanation new "System Architecture"`
    Then the exit status should be 0
    And the file "test_docs/explanations/explanation_system_architecture.md" should exist
    And the file "test_docs/README.md" should contain "### Explanations"
    And the file "test_docs/README.md" should contain "System Architecture"

  Scenario: Create an ADR with automatic numbering
    When I run `bundle exec dia adr new "Use PostgreSQL Database"`
    Then the exit status should be 0
    And the file "test_docs/adr/0001-use-postgresql-database.md" should exist
    And the file "test_docs/README.md" should contain "### Design Decisions"
    And the file "test_docs/README.md" should contain "ADR-0001"

  Scenario: Create multiple ADRs with sequential numbering
    When I run `bundle exec dia adr new "Use PostgreSQL Database"`
    And I run `bundle exec dia adr new "Use CLI Front End"`
    Then the exit status should be 0
    And the file "test_docs/adr/0001-use-postgresql-database.md" should exist
    And the file "test_docs/adr/0002-use-cli-front-end.md" should exist
    And the file "test_docs/README.md" should contain "ADR-0001"
    And the file "test_docs/README.md" should contain "ADR-0002"

  Scenario: Create a note document
    When I run `bundle exec dia note new "Meeting Notes Q4"`
    Then the exit status should be 0
    And the file "test_docs/notes/note_meeting_notes_q4.md" should exist
    And the file "test_docs/README.md" should contain "### Notes"
    And the file "test_docs/README.md" should contain "Meeting Notes Q4"

  Scenario: Create a handover document
    When I run `bundle exec dia handover new "Frontend Ownership"`
    Then the exit status should be 0
    And the file "test_docs/handovers/handover_frontend_ownership.md" should exist
    And the file "test_docs/README.md" should contain "### Handovers"
    And the file "test_docs/README.md" should contain "Frontend Ownership"

  Scenario: Create a 5why document
    When I run `bundle exec dia 5why new "Login Timeout Root Cause"`
    Then the exit status should be 0
    And the file "test_docs/5whys/5why_login_timeout_root_cause.md" should exist
    And the file "test_docs/README.md" should contain "### 5-Whys"
    And the file "test_docs/README.md" should contain "Login Timeout Root Cause"

  Scenario: Create a project document
    When I run `bundle exec dia project new "API Migration"`
    Then the exit status should be 0
    And the file "test_docs/README.md" should contain "### Projects"
    And the file "test_docs/README.md" should contain "API Migration"

  Scenario: Create a PR document
    When I run `bundle exec dia pr new "Refactor Auth Module"`
    Then the exit status should be 0
    And the file "test_docs/explanations/pr_refactor_auth_module.md" should exist
    And the file "test_docs/README.md" should contain "### Pull Requests"
    And the file "test_docs/README.md" should contain "Refactor Auth Module"

  Scenario: All 9 document types appear as separate README sections
    When I run `bundle exec dia howto new "Configure System"`
    And I run `bundle exec dia tutorial new "Getting Started"`
    And I run `bundle exec dia explanation new "System Architecture"`
    And I run `bundle exec dia adr new "Use PostgreSQL"`
    And I run `bundle exec dia note new "Meeting Notes"`
    And I run `bundle exec dia handover new "Frontend Ownership"`
    And I run `bundle exec dia 5why new "Login Timeout"`
    And I run `bundle exec dia project new "API Migration"`
    And I run `bundle exec dia pr new "Refactor Auth"`
    Then the file "test_docs/README.md" should contain "### How-To Guides"
    And the file "test_docs/README.md" should contain "### Tutorials"
    And the file "test_docs/README.md" should contain "### Explanations"
    And the file "test_docs/README.md" should contain "### Design Decisions"
    And the file "test_docs/README.md" should contain "### Notes"
    And the file "test_docs/README.md" should contain "### Handovers"
    And the file "test_docs/README.md" should contain "### 5-Whys"
    And the file "test_docs/README.md" should contain "### Projects"
    And the file "test_docs/README.md" should contain "### Pull Requests"
