# frozen_string_literal: true

module Diataxis
  # Command handling
  class CLI
    def self.run(args)
      return usage if args.empty?

      command = args.shift
      case command
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
      puts "  howto new \"Title\"     - Create a new how-to guide"
      puts "  tutorial new \"Title\"  - Create a new tutorial"
      puts "  update <directory>    - Update document filenames and README.md"
      exit 1
    end

    def self.handle_howto(args)
      if args.length < 2 || args[0] != "new"
        puts "Usage: diataxis howto new \"Title of the How-To Guide\""
        exit 1
      end
      directory = Dir.pwd
      title = args[1..].join(" ")
      HowTo.new(title, directory).create
      
      # Update the README.md after creating a new how-to
      document_types = [HowTo, Tutorial]
      ReadmeManager.new(directory, document_types).update
    end

    def self.handle_tutorial(args)
      if args.length < 2 || args[0] != "new"
        puts "Usage: diataxis tutorial new \"Title of the Tutorial\""
        exit 1
      end
      title = args[1..].join(" ")
      Tutorial.new(title, Dir.pwd).create
    end

    def self.handle_update(args)
      if args.empty?
        puts "Usage: diataxis update <directory>"
        exit 1
      end

      directory = File.expand_path(args[0])
      abort("Error: '#{directory}' is not a valid directory.") unless Dir.exist?(directory)

      document_types = [HowTo, Tutorial]
      FileManager.update_filenames(directory, document_types)
      ReadmeManager.new(directory, document_types).update
    end
  end
end
