require 'fileutils'

module Diataxis
  # Base document class following Template Method pattern
  class Document
    attr_reader :title, :filename

    def initialize(title, directory = '.')
      @title = title
      @directory = directory
      @filename = File.join(@directory, generate_filename)
    end

    def create
      File.write(@filename, content)
      puts "Created new #{type}: #{@filename}"
    end

    def self.pattern
      raise NotImplementedError, "#{self.name} must implement pattern"
    end

    protected

    def type
      self.class.name.split('::').last.downcase
    end

    def generate_filename
      sanitize_filename(title)
    end

    def content
      raise NotImplementedError, "#{self.class.name} must implement content"
    end

    private

    def sanitize_filename(title)
      # Remove any existing 'How to' prefix for the filename
      title_without_prefix = title.sub(/^How to\s+/i, '')
      prefix = self.class == HowTo ? "how_to" : type
      "#{prefix}_#{title_without_prefix.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')}.md"
    end
  end

  # Concrete document types
  class HowTo < Document
    def self.pattern
      "how_to_*.md"
    end

    def initialize(title, directory = '.')
      normalized_title = normalize_title(title)
      super(normalized_title, directory)
    end

    protected

    def normalize_title(title)
      return title if title.downcase.start_with?('how to')
      
      # Convert imperative statements to 'How to' format
      # Strip any trailing punctuation and normalize whitespace
      action = title.strip.sub(/[.!?]\s*$/, '')
      "How to #{action[0].downcase}#{action[1..]}"
    end

    def content
      <<~CONTENT
        # #{title}

        ## Description

        A brief overview of what this guide helps the reader achieve.

        ## Prerequisites

        List any setup steps, dependencies, or prior knowledge needed before following this guide.

        ## Steps

        **Step 1: [Action]**  
        Explanation of the step with commands or code snippets if applicable.  

        ```bash
        # step 1
        some-command --option value

        # step 2

        # step 3
        ```

        ## Verification

        How to confirm that the how-to was successful. Example output or tests.

        ## Troubleshooting

        Common issues and resolutions.

        ## Appendix

        Additional references, sample outputs, or related links.
      CONTENT
    end
  end

  class Tutorial < Document
    def self.pattern
      "tutorial_*.md"
    end

    protected

    def content
      <<~CONTENT
        # #{title}

        ## Learning Objectives

        What the reader will learn from this tutorial.

        ## Prerequisites

        What the reader needs to know or have installed before starting.

        ## Tutorial

        Step-by-step instructions...
      CONTENT
    end
  end

  # File management
  class FileManager
    def self.update_filenames(directory, document_types)
      document_types.each do |doc_type|
        Dir.glob(File.join(directory, doc_type.pattern)).each do |filepath|
          update_filename(filepath, directory)
        end
      end
    end

    private

    def self.update_filename(filepath, directory)
      first_line = File.open(filepath, &:readline).strip
      if first_line.start_with?('# ')
        title = first_line[2..] # Remove the "# " prefix
        # Extract title part after how_to_ prefix
        current_name = File.basename(filepath)
        if current_name.start_with?('how_to_')
          # Remove how_to_ prefix from title if it exists
          title = title.sub(/^how to /i, '')
          title_part = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
          new_filename = "how_to_#{title_part}.md"
        else
          type = current_name.split('_').first
          title_part = title.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
          new_filename = "#{type}_#{title_part}.md"
        end
        new_filepath = File.join(directory, new_filename)
        
        if File.basename(filepath) != new_filename
          FileUtils.mv(filepath, new_filepath)
          puts "Renamed: #{filepath} -> #{new_filepath}"
        end
      end
    end
  end

  # README management
  class ReadmeManager
    def initialize(directory, document_types)
      @directory = directory
      @document_types = document_types
    end

    def update
      if File.exist?(readme_path)
        update_existing_readme
      else
        create_new_readme
      end
    end

    private

    def readme_path
      File.join(@directory, "README.md")
    end

    def document_entries
      entries = {}
      @document_types.each do |doc_type|
        entries[doc_type] = collect_entries(doc_type)
      end
      entries
    end

    def collect_entries(doc_type)
      pattern = File.join(@directory, doc_type.pattern)
      files = Dir.glob(pattern)
      puts "Found #{files.length} files matching #{pattern}"
      files.map do |file|
        title = File.open(file, &:readline).strip[2..] # Extract title from first line
        "* [#{title}](#{File.basename(file)})"
      end
    end

    def update_existing_readme
      content = File.read(readme_path)
      @document_types.each do |doc_type|
        section_name = doc_type.name.split('::').last
        if content.include?("<!-- #{section_name.downcase}log -->")
          content = update_section(content, section_name, document_entries[doc_type])
        else
          content = add_section(content, section_name, document_entries[doc_type])
        end
      end
      File.write(readme_path, content)
    end

    def update_section(content, section_name, entries)
      section_type = section_name.downcase.gsub(/s$/, '') # Remove trailing 's'
      tag_start = "<!-- #{section_type}log -->"
      tag_end = "<!-- #{section_type}logstop -->"
      # Update all occurrences of the section
      content.gsub(/#{tag_start}.*?#{tag_end}/m, "#{tag_start}\n#{entries.join("\n")}\n#{tag_end}")
    end

    def add_section(content, section_name, entries)
      section_type = section_name.downcase.gsub(/s$/, '') # Remove trailing 's'
      new_section = <<~SECTION
        \n### #{section_name}s

        <!-- #{section_type}log -->
        #{entries.join("\n")}
        <!-- #{section_type}logstop -->
      SECTION
      content + new_section
    end

    def create_new_readme
      current_directory_name = File.basename(@directory)
      sections = @document_types.map do |doc_type|
        section_name = doc_type.name.split('::').last
        entries = document_entries[doc_type]
        if entries.empty?
          <<~SECTION
            ### #{section_name}s
    
            <!-- #{section_name.downcase}log -->
            <!-- #{section_name.downcase}logstop -->
          SECTION
        else
          <<~SECTION
            ### #{section_name}s
    
            <!-- #{section_name.downcase}log -->
            #{entries.join("\n")}
            <!-- #{section_name.downcase}logstop -->
          SECTION
        end
      end.join("\n")
    
      content = <<~HEREDOC
        # #{current_directory_name}
    
        ## Description
    
        ## Usage
    
        ## Appendix
    
        ### Design Decisions
    
        <!-- adrlog -->
        <!-- adrlogstop -->
    
        #{sections}
      HEREDOC

      # Ensure content only has a single newline at the end
      content = content.rstrip + "\n"
    
      File.write(readme_path, content)
      puts "Created new README.md in #{@directory}"
    end
  end


end
