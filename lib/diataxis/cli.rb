# frozen_string_literal: true

require_relative 'version'
require_relative 'errors'

module Diataxis
  # Command handling
  class CLI
    def self.run(args)
      return usage if args.empty?

      command = args.shift
      handle_command(command, args)
    end

    def self.handle_command(command, args)
      case command
      when '--version', '-v'
        show_version
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
        unknown_command(command)
      end
    end

    def self.show_version
      puts "diataxis version #{VERSION}"
      exit 0
    end

    def self.unknown_command(command)
      raise UsageError.new("Unknown command: #{command}", 1)
    end

    def self.usage(exit_code = 1)
      usage_text = <<~USAGE
        Usage: diataxis <command> [arguments]
        Commands:
          --version, -v         - Show version number
          --help, -h            - Show this help message
          init                  - Initialize .diataxis config file
          howto new "Title"     - Create a new how-to guide
          tutorial new "Title"  - Create a new tutorial
          adr new "Title"      - Create a new architectural decision record
          explanation new "Title" - Create a new explanation document
          update <directory>    - Update document filenames and README.md
      USAGE

      raise UsageError.new(usage_text.strip, exit_code) unless exit_code.zero?

      puts usage_text
      exit 0
    end

    def self.handle_init(args)
      directory = args.empty? ? Dir.pwd : File.expand_path(args[0])
      unless Dir.exist?(directory)
        raise FileSystemError.new("'#{directory}' is not a valid directory.", path: directory,
                                                                              operation: 'directory_check')
      end

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
        raise UsageError.new('Usage: diataxis howto new "Title of the How-To Guide"', 1)
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
        raise UsageError.new('Usage: diataxis tutorial new "Title of the Tutorial"', 1)
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
      raise UsageError.new('Usage: diataxis adr new "Title of the ADR"', 1) if args.length < 2 || args[0] != 'new'

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
      raise UsageError.new('Usage: diataxis update <directory>', 1) if args.empty?

      directory = File.expand_path(args[0])
      unless Dir.exist?(directory)
        raise FileSystemError.new("'#{directory}' is not a valid directory.", path: directory,
                                                                              operation: 'directory_check')
      end

      Config.load(directory)
      document_types = [HowTo, Tutorial, Explanation, ADR]

      # First collect all files and update filenames
      readme_manager = ReadmeManager.new(directory, document_types)
      readme_manager.update
    end

    def self.handle_explanation(args)
      if args.length < 2 || args[0] != 'new'
        raise UsageError.new('Usage: diataxis explanation new "Title of the Explanation"', 1)
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
