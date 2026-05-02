Feature: DIATAXIS_ROOT Environment Variable
  As a documentation maintainer
  I want to use DIATAXIS_ROOT to target a different directory
  So that I can run dia from anywhere

  Scenario: Init creates config at DIATAXIS_ROOT
    Given a directory named "remote_root"
    And I set DIATAXIS_ROOT to the directory "remote_root"
    When I run `bundle exec dia init`
    Then the exit status should be 0
    And the file "remote_root/.diataxis" should exist

  Scenario: Create document at DIATAXIS_ROOT
    Given a directory named "remote_root"
    And I set DIATAXIS_ROOT to the directory "remote_root"
    When I run `bundle exec dia init`
    And I run `bundle exec dia explanation new "Remote Document"`
    Then the exit status should be 0
    And the file "remote_root/docs/explanation_remote_document.md" should exist

  Scenario: Update targets DIATAXIS_ROOT
    Given a directory named "remote_root"
    And I set DIATAXIS_ROOT to the directory "remote_root"
    When I run `bundle exec dia init`
    And I run `bundle exec dia explanation new "Remote Document"`
    And I run `bundle exec dia update`
    Then the exit status should be 0
    And the file "remote_root/README.md" should contain "Remote Document"

  Scenario: DIATAXIS_ROOT with custom config
    Given a directory named "remote_root"
    And I set DIATAXIS_ROOT to the directory "remote_root"
    And a file named "remote_root/.diataxis" with:
      """
      {
        "readme": "my_docs/README.md",
        "default": "my_docs",
        "adr": "my_docs/decisions"
      }
      """
    When I run `bundle exec dia adr new "Test Custom Config"`
    Then the exit status should be 0
    And the file "remote_root/my_docs/decisions/0001-test-custom-config.md" should exist
