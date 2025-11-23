# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe 'Diataxis::MarkdownUtils' do
  describe '.extract_title' do
    context 'when markdown file has no YAML front matter' do
      it 'extracts title from first heading' do
        with_temp_file("# Simple Title\n\nSome content") do |file|
          expect(described_class.extract_title(file.path)).to eq('Simple Title')
        end
      end

      it 'handles titles with special characters' do
        with_temp_file("# How to Install Ruby and Bundler on Windows Server\n\n## Description") do |file|
          expect(described_class.extract_title(file.path)).to eq('How to Install Ruby and Bundler on Windows Server')
        end
      end

      it 'skips empty lines before title' do
        with_temp_file("\n\n# Title After Blank Lines\n\nContent") do |file|
          expect(described_class.extract_title(file.path)).to eq('Title After Blank Lines')
        end
      end

      it 'returns nil when no heading is found' do
        with_temp_file('Just plain text without a heading') do |file|
          expect(described_class.extract_title(file.path)).to be_nil
        end
      end

      it 'returns nil for empty file' do
        with_temp_file('') do |file|
          expect(described_class.extract_title(file.path)).to be_nil
        end
      end
    end

    context 'when markdown file has YAML front matter' do
      it 'skips front matter and extracts title' do
        content = <<~MARKDOWN
          ---
          aliases:
            - "How to Install Ruby"
          tags:
            - ruby
          ---

          # How to Install Ruby and Bundler on Windows Server

          ## Description
        MARKDOWN

        with_temp_file(content) do |file|
          expect(described_class.extract_title(file.path)).to eq('How to Install Ruby and Bundler on Windows Server')
        end
      end

      it 'handles front matter with simple key-value pairs' do
        content = <<~MARKDOWN
          ---
          title: My Document
          date: 2025-11-19
          ---

          # Actual Title in Content

          Some content here
        MARKDOWN

        with_temp_file(content) do |file|
          expect(described_class.extract_title(file.path)).to eq('Actual Title in Content')
        end
      end

      it 'handles empty lines after front matter' do
        content = <<~MARKDOWN
          ---
          tags:
            - test
          ---


          # Title After Empty Lines

          Content
        MARKDOWN

        with_temp_file(content) do |file|
          expect(described_class.extract_title(file.path)).to eq('Title After Empty Lines')
        end
      end

      it 'handles front matter with complex nested structures' do
        content = <<~MARKDOWN
          ---
          metadata:
            author: John Doe
            version: 1.0
            tags:
              - important
              - documentation
          settings:
            enabled: true
          ---

          # Complex Document Title

          ## Section
        MARKDOWN

        with_temp_file(content) do |file|
          expect(described_class.extract_title(file.path)).to eq('Complex Document Title')
        end
      end

      it 'returns nil when front matter exists but no heading found' do
        content = <<~MARKDOWN
          ---
          title: Metadata Title
          ---

          Just plain text without a markdown heading
        MARKDOWN

        with_temp_file(content) do |file|
          expect(described_class.extract_title(file.path)).to be_nil
        end
      end

      it 'handles malformed front matter (only opening delimiter)' do
        content = <<~MARKDOWN
          ---
          incomplete front matter

          # Title Should Be Found

          Content
        MARKDOWN

        with_temp_file(content) do |file|
          # With only one delimiter, we wait indefinitely for the closing delimiter
          # and never reach the title, so we return nil (conservative behavior)
          expect(described_class.extract_title(file.path)).to be_nil
        end
      end
    end

    context 'with edge cases' do
      it 'handles file with only front matter' do
        content = <<~MARKDOWN
          ---
          key: value
          ---
        MARKDOWN

        with_temp_file(content) do |file|
          expect(described_class.extract_title(file.path)).to be_nil
        end
      end

      it 'handles multiple headings and returns the first' do
        content = <<~MARKDOWN
          # First Title

          ## Second Heading

          # Another Top Level
        MARKDOWN

        with_temp_file(content) do |file|
          expect(described_class.extract_title(file.path)).to eq('First Title')
        end
      end

      it 'stops at non-heading content after skipping empty lines' do
        content = <<~MARKDOWN
          ---
          tags: test
          ---

          Some text

          # This heading comes after text
        MARKDOWN

        with_temp_file(content) do |file|
          expect(described_class.extract_title(file.path)).to be_nil
        end
      end

      it 'handles heading with trailing whitespace' do
        with_temp_file("#    Title With Spaces    \n\nContent") do |file|
          expect(described_class.extract_title(file.path)).to eq('Title With Spaces')
        end
      end
    end
  end

  # Helper method to create temporary files for testing
  def with_temp_file(content)
    file = Tempfile.new(['test', '.md'])
    begin
      file.write(content)
      file.close
      yield file
    ensure
      file.unlink
    end
  end
end
