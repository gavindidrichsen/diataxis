# Diataxis

Diataxis is a command-line tool for managing documentation following the [Diataxis framework](https://diataxis.fr/). It helps maintain How-To guides, tutorials, and Architectural Decision Records (ADRs), with automatic README.md updates.

## Features

* Create How-To guides with proper formatting and naming conventions
* Create tutorials with consistent structure
* Create explanation documents following the Diataxis framework
* Create and manage ADRs following established community practices
* Automatically update README.md with links to documentation
* Smart title formatting that converts statements to "How to" format
* Maintains alphabetical order in documentation lists

## Installation

Install the gem by executing:

```bash
git clone https://github.com/gavindidrichsen/diataxis.git
cd diataxis
gem build diataxis.gemspec
gem install diataxis
```

Make sure that `dia` is available on your PATH.  

## Usage

```bash
# initialize a new diataxis project (creates .diataxis config)
dia init
cat .diataxis                                           # view and edit the default configuration

# Create a New How-To Guide
dia howto new "How to configure SSL certificates"       # create with a "How to" title
dia howto new "Configure SSL certificates"              # or use an imperative statement (automatically converted)

# Create a New Tutorial
dia tutorial new "Getting Started with Docker"

# Create a New Explanation
dia explanation new "Why We Use PostgreSQL"

# Create a new ADR
dia adr new "Do whiteboard wednesday talks"
```

If you change any document titles, then run the following to automatically rename the filenames and update the links:

```bash
dia update .
```

For more information including design decisions and how-to's see [docs/README.md](./docs/README.md).

## Testing

This project uses:

* **RSpec** for unit testing
* **Cucumber with Aruba** for BDD/CLI integration testing

For detailed information on using Cucumber with Aruba, see [Cucumber & Aruba Cheatsheet](../../../tools/@cheatsheets/cucumber.md).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Acknowledgments

The ADR functionality in this tool is inspired by and maintains compatibility with two excellent projects:

* [adr-tools](https://github.com/npryce/adr-tools) - The original ADR management tool that established many of the conventions we follow
* [adr-log](https://github.com/adr/adr-log) - A complementary tool for generating ADR logs

Like these tools, our ADR implementation:

* Uses the standard ADR format (Context, Decision, Consequences)
* Maintains a chronological sequence of decisions
* Supports superseding and amending previous decisions
* Generates consistent, numbered filenames
* Preserves markdown formatting

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gavindidrichsen/diataxis. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gavindidrichsen/diataxis/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Diataxis project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gavindidrichsen/diataxis/blob/main/CODE_OF_CONDUCT.md).

## Appendix

### How-To Guides

<!-- howtolog -->
* [How to add a new document template](docs/how_to_add_a_new_document_template.md)
* [How to add or amend log statements](docs/how_to_add_or_amend_log_statements.md)
* [How to manually test all diataxis features](docs/how_to_manually_test_all_diataxis_features.md)
<!-- howtologstop -->

### Explanations

<!-- explanationlog -->
* [Understanding the design of the logging system](docs/understanding_the_design_of_the_logging_system.md)
<!-- explanationlogstop -->

### Projects

<!-- projectlog -->
* [Project: Create common style guidelines for each template](docs/gtd/project_create_common_style_guidelines_for_each_template.md)
* [Project: Error handle new document failures](docs/gtd/project_error_handle_new_document_failures.md)
* [Project: Fix dia commands to work from within sub-directories](docs/gtd/project_fix_dia_commands_to_work_from_within_sub_directories.md)
<!-- projectlogstop -->

### Design Decisions

<!-- adrlog -->
* [ADR-0001](docs/adr/0001-adopt-diataxis-documentation-framework.md) - Adopt Diataxis Documentation Framework
* [ADR-0002](docs/adr/0002-use-configuration-file-for-document-paths.md) - Use Configuration File for Document Paths
* [ADR-0003](docs/adr/0003-auto-generate-readme-with-document-links.md) - Auto-Generate README with Document Links
* [ADR-0004](docs/adr/0004-use-linguistic-prefixes-for-document-classification.md) - Use Linguistic Prefixes for Document Classification
* [ADR-0005](docs/adr/0005-use-purpose-driven-document-templates.md) - Use Purpose-Driven Document Templates
* [ADR-0006](docs/adr/0006-implement-automated-readme-link-management.md) - Implement Automated README Link Management
* [ADR-0007](docs/adr/0007-enable-recursive-document-discovery.md) - Enable Recursive Document Discovery
* [ADR-0008](docs/adr/0008-refactor-document-templates-into-separate-class-files-for-improved-maintainability.md) - Refactor document templates into separate class files for improved maintainability
* [ADR-0009](docs/adr/0009-hide-readme-sections-when-no-matching-documents-exist.md) - Hide README sections when no matching documents exist
* [ADR-0010](docs/adr/0010-implement-custom-error-handling-system.md) - Implement Custom Error Handling System
* [ADR-0011](docs/adr/0011-implement-centralized-logging-system-with-ruby-logger.md) - Implement centralized logging system with Ruby Logger
* [ADR-0012](docs/adr/0012-move-to-external-template-system-with-direct-templateloader-usage.md) - Move to External Template System with Direct TemplateLoader Usage
* [ADR-0013](docs/adr/0013-set-default-directory-for-all-templates.md) - Set default directory for all templates
* [ADR-0014](docs/adr/0014-underscore-the-gtd-directory-for-project-files-so-they-always-live-at-the-top.md) - Underscore the gtd directory for project files so they always live at the top
<!-- adrlogstop -->
