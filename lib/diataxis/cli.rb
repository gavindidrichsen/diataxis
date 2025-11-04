# frozen_string_literal: true

require_relative 'version'

module Diataxis
  # Command handling
  class CLI
    def self.run(args)
      return usage if args.empty?

      command = args.shift
      case command
      when '--version', '-v'
        puts "diataxis version #{VERSION}"
        exit 0
      when '--help', '-h'
        usage(0)
      when 'init'
        handle_init(args)
      when 'howto'
        handle_howto(args)
      when 'tutorial'
        handle_tutorial(args)
      when 'adr'
        handle_adr(args)
      when 'explanation'
        handle_explanation(args)
      when 'update'
        handle_update(args)
      else
        puts "Unknown command: #{command}"
        exit 1
      end
    end

    def self.usage(exit_code = 1)
      puts 'Usage: diataxis <command> [arguments]'
      puts 'Commands:'
      puts '  --version, -v         - Show version number'
      puts '  --help, -h            - Show this help message'
      puts '  init                  - Initialize .diataxis config file'
      puts '  howto new "Title"     - Create a new how-to guide'
      puts '  tutorial new "Title"  - Create a new tutorial'
      puts '  adr new "Title"      - Create a new architectural decision record'
      puts '  explanation new "Title" - Create a new explanation document'
      puts '  update <directory>    - Update document filenames and README.md'
      exit exit_code
    end

    def self.handle_init(args)
      directory = args.empty? ? Dir.pwd : File.expand_path(args[0])
      abort("Error: '#{directory}' is not a valid directory.") unless Dir.exist?(directory)
      config = {
        'readme' => 'docs/README.md',
        'howtos' => 'docs/how-to',
        'tutorials' => 'docs/tutorials',
        'explanations' => 'docs/explanations',
        'adr' => 'docs/adr'
      }
      Config.create(directory, config)
    end

    def self.handle_howto(args)
      if args.length < 2 || args[0] != 'new'
        puts 'Usage: diataxis howto new "Title of the How-To Guide"'
        exit 1
      end
      directory = Dir.pwd
      title = args[1..].join(' ')
      config = Config.load(directory)

      howto_dir = File.join(directory, config['howtos'])
      FileUtils.mkdir_p(howto_dir)

      HowTo.new(title, howto_dir).create

      # Update the README.md after creating a new how-to
      document_types = [HowTo, Tutorial, Explanation]
      ReadmeManager.new(directory, document_types).update
    end

    def self.handle_tutorial(args)
      if args.length < 2 || args[0] != 'new'
        puts 'Usage: diataxis tutorial new "Title of the Tutorial"'
        exit 1
      end
      directory = Dir.pwd
      title = args[1..].join(' ')
      config = Config.load(directory)

      tutorial_dir = File.join(directory, config['tutorials'])
      FileUtils.mkdir_p(tutorial_dir)

      Tutorial.new(title, tutorial_dir).create

      # Update the README.md after creating a new tutorial
      document_types = [HowTo, Tutorial, Explanation]
      ReadmeManager.new(directory, document_types).update
    end

    def self.handle_adr(args)
      if args.length < 2 || args[0] != 'new'
        puts 'Usage: diataxis adr new "Title of the ADR"'
        exit 1
      end
      directory = Dir.pwd
      title = args[1..].join(' ')
      config = Config.load(directory)

      adr_dir = File.join(directory, config['adr'])
      FileUtils.mkdir_p(adr_dir)

      ADR.new(title, adr_dir).create

      # Update the README.md after creating a new ADR
      document_types = [HowTo, Tutorial, ADR]
      ReadmeManager.new(directory, document_types).update
    end

    def self.handle_update(args)
      if args.empty?
        puts 'Usage: diataxis update <directory>'
        exit 1
      end

      directory = File.expand_path(args[0])
      abort("Error: '#{directory}' is not a valid directory.") unless Dir.exist?(directory)

      Config.load(directory)
      document_types = [HowTo, Tutorial, Explanation, ADR]

      # First collect all files and update filenames
      readme_manager = ReadmeManager.new(directory, document_types)
      readme_manager.update
    end

    def self.handle_explanation(args)
      if args.length < 2 || args[0] != 'new'
        puts 'Usage: diataxis explanation new "Title of the Explanation"'
        exit 1
      end
      directory = Dir.pwd
      title = args[1..].join(' ')
      config = Config.load(directory)

      explanation_dir = File.join(directory, config['explanations'])
      FileUtils.mkdir_p(explanation_dir)

      Explanation.new(title, explanation_dir).create

      # Update the README.md after creating a new explanation
      document_types = [HowTo, Tutorial, Explanation]
      ReadmeManager.new(directory, document_types).update
    end
  end
end
