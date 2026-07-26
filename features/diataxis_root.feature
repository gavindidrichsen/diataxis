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

  # These scenarios' working directory is itself governed by this gem's own
  # root .diataxis (it self-hosts its docs), so pointing DIATAXIS_ROOT at a
  # distinct "remote_root" is a genuine local-vs-root conflict (see
  # docs/adr/0018-prompt-on-diataxis-root-and-local-diataxis-conflict.md). The
  # `--root` flag resolves that conflict non-interactively in favour of
  # DIATAXIS_ROOT, without blocking on a prompt.
  Scenario: Create document at DIATAXIS_ROOT
    Given a directory named "remote_root"
    And I set DIATAXIS_ROOT to the directory "remote_root"
    When I run `bundle exec dia init`
    And I run `bundle exec dia explanation new "Remote Document" --root`
    Then the exit status should be 0
    And the file "remote_root/docs/explanation_remote_document.md" should exist

  Scenario: Update targets DIATAXIS_ROOT
    Given a directory named "remote_root"
    And I set DIATAXIS_ROOT to the directory "remote_root"
    When I run `bundle exec dia init`
    And I run `bundle exec dia explanation new "Remote Document" --root`
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
    When I run `bundle exec dia adr new "Test Custom Config" --root`
    Then the exit status should be 0
    And the file "remote_root/my_docs/decisions/0001-test-custom-config.md" should exist

  Scenario: --here forces the document into the current directory despite DIATAXIS_ROOT being set
    Given a directory named "remote_root"
    And I set DIATAXIS_ROOT to the directory "remote_root"
    And a file named ".diataxis" with:
      """
      {
        "default": "docs",
        "readme": "README.md",
        "adr": "docs/adr",
        "projects": "docs/_gtd"
      }
      """
    When I run `bundle exec dia explanation new "Local Override" --here`
    Then the exit status should be 0
    And the file "docs/explanation_local_override.md" should exist
    And the file "remote_root/docs/explanation_local_override.md" should not exist

  Scenario: A non-interactive conflict between DIATAXIS_ROOT and a local .diataxis fails with a clear message
    Given a directory named "remote_root"
    And I set DIATAXIS_ROOT to the directory "remote_root"
    And a file named ".diataxis" with:
      """
      {
        "default": "docs",
        "readme": "README.md",
        "adr": "docs/adr",
        "projects": "docs/_gtd"
      }
      """
    When I run `bundle exec dia explanation new "Ambiguous Document"`
    Then the exit status should not be 0
    And the output should contain "--here or --root"
