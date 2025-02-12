# Diataxis

Diataxis is a command-line tool for managing documentation following the [Diataxis framework](https://diataxis.fr/). It helps maintain How-To guides and tutorials, with automatic README.md updates.

## Features

- Create How-To guides with proper formatting and naming conventions
- Create tutorials with consistent structure
- Automatically update README.md with links to documentation
- Smart title formatting that converts statements to "How to" format
- Maintains alphabetical order in documentation lists

## Installation

Install the gem by executing:

```bash
gem install diataxis
```

## Usage

### Creating a New How-To Guide

```bash
# Create with a "How to" title
dia howto new "How to configure SSL certificates"

# Or use an imperative statement (automatically converted)
dia howto new "Configure SSL certificates"
# Creates: how_to_configure_ssl_certificates.md
# Title becomes: "How to configure SSL certificates"
```

### Creating a New Tutorial

```bash
dia tutorial new "Getting Started with Docker"
```

### Updating Documentation

The `update` command will:
1. Normalize filenames based on their titles
2. Update the README.md with links to all documentation

```bash
dia update .
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gavindidrichsen/diataxis. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gavindidrichsen/diataxis/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Diataxis project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gavindidrichsen/diataxis/blob/main/CODE_OF_CONDUCT.md).
