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
