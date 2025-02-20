# frozen_string_literal: true

require_relative 'lib/diataxis/version'

Gem::Specification.new do |spec|
  spec.name = 'diataxis'
  spec.version = Diataxis::VERSION
  spec.authors = ['Gavin Didrichsen']
  spec.email = ['gavin.didrichsen@gmail.com']

  spec.summary = 'A command-line tool for managing documentation following the Diataxis framework'
  spec.description = 'Create docs according to the Diataxis framework.'
  spec.homepage = 'https://github.com/gavindidrichsen/diataxis'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/gavindidrichsen/diataxis'
  spec.metadata['changelog_uri'] = 'https://github.com/gavindidrichsen/diataxis/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.25'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
