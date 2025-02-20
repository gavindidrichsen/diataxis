# frozen_string_literal: true

module Diataxis
  # Command handling
  class CLI
    def self.run(args)
      return usage if args.empty?

      command = args.shift
      case command
      when "init"
        handle_init(args)
      when "howto"
        handle_howto(args)
      when "tutorial"
        handle_tutorial(args)
      when "update"
        handle_update(args)
      else
        puts "Unknown command: #{command}"
        exit 1
      end
    end

    private

    def self.usage
      puts "Usage: diataxis <command> [arguments]"
      puts "Commands:"
      puts "  init                  - Initialize .diataxis config file"
      puts "  howto new \"Title\"     - Create a new how-to guide"
      puts "  tutorial new \"Title\"  - Create a new tutorial"
      puts "  update <directory>    - Update document filenames and README.md"
      exit 1
    end

    def self.handle_init(args)
      directory = args.empty? ? Dir.pwd : File.expand_path(args[0])
      abort("Error: '#{directory}' is not a valid directory.") unless Dir.exist?(directory)
      
      config = {
        'readme' => 'docs/README.md',
        'howtos' => 'docs/how-to',
        'tutorials' => 'docs/tutorials',
        'adr' => 'docs/exp/adr'
      }
      
      Config.create(directory, config)
    end

    def self.handle_howto(args)
      if args.length < 2 || args[0] != "new"
        puts "Usage: diataxis howto new \"Title of the How-To Guide\""
        exit 1
      end
      directory = Dir.pwd
      title = args[1..].join(" ")
      config = Config.load(directory)
      
      howto_dir = File.join(directory, config['howtos'])
      FileUtils.mkdir_p(howto_dir)
      
      HowTo.new(title, howto_dir).create
      
      # Update the README.md after creating a new how-to
      document_types = [HowTo, Tutorial]
      ReadmeManager.new(directory, document_types).update
    end

    def self.handle_tutorial(args)
      if args.length < 2 || args[0] != "new"
        puts "Usage: diataxis tutorial new \"Title of the Tutorial\""
        exit 1
      end
      directory = Dir.pwd
      title = args[1..].join(" ")
      config = Config.load(directory)
      
      tutorial_dir = File.join(directory, config['tutorials'])
      FileUtils.mkdir_p(tutorial_dir)
      
      Tutorial.new(title, tutorial_dir).create
      
      # Update the README.md after creating a new tutorial
      document_types = [HowTo, Tutorial]
      ReadmeManager.new(directory, document_types).update
    end

    def self.handle_update(args)
      if args.empty?
        puts "Usage: diataxis update <directory>"
        exit 1
      end

      directory = File.expand_path(args[0])
      abort("Error: '#{directory}' is not a valid directory.") unless Dir.exist?(directory)

      config = Config.load(directory)
      document_types = [HowTo, Tutorial]
      
      # Update filenames in configured directories
      FileManager.update_filenames(File.join(directory, config['howtos']), [HowTo])
      FileManager.update_filenames(File.join(directory, config['tutorials']), [Tutorial])
      
      ReadmeManager.new(directory, document_types).update
    end
  end
end
