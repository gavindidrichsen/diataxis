# frozen_string_literal: true

require 'shellwords'

module Diataxis
  # Keeps Obsidian-style wiki-links ([[note]]) pointing at the right document
  # when a file is renamed.
  #
  # Speed vs. precision: ripgrep does the broad, fast scan to find the *handful*
  # of files that even mention the old name inside a wiki-link; Ruby then does
  # the precise rewrite. The link grammar we honour is:
  #
  #   [[ (folder/)? NAME (.md)? (#heading | |alias)? ]]
  #
  # The rewrite only fires on an EXACT match of NAME, so renaming
  # `tutorial_intro` never disturbs an unrelated `[[tutorial_intro_advanced]]`.
  # Any folder prefix, ".md" extension, #heading or |alias is preserved.
  module WikiLinkUpdater
    module_function

    # @param root [String] directory tree whose markdown files may hold links
    # @param old_filepath [String] the path the renamed file used to have
    # @param new_filepath [String] the path the renamed file now has
    # @param document_type [Class, nil] the renamed file's document type. When
    #   given, a wiki-link alias that was the document's *old title* is retitled
    #   to the new title; a custom alias is always left alone. When nil, aliases
    #   are never touched (only the link target is repointed).
    def update_links(root, old_filepath, new_filepath, document_type: nil)
      old_name = File.basename(old_filepath, '.md')
      new_name = File.basename(new_filepath, '.md')
      return if old_name == new_name

      new_title = document_type ? MarkdownUtils.extract_title(new_filepath) : nil
      pattern = link_regexp(old_name)
      candidate_files(root, old_name).each do |file|
        rewrite_file(file, pattern, new_name, old_name, new_title, document_type)
      end
    end

    # A wiki-link whose target is EXACTLY old_name. The grammar is:
    #   [[ (folder/)? NAME (.md)? (#heading)? (|alias)? ]]
    # Heading and alias are captured separately so the alias can be retitled
    # while the target, extension and heading are carried through untouched.
    def link_regexp(old_name)
      esc = Regexp.escape(old_name)
      %r{\[\[(?<prefix>[^\[\]#|]*/)?#{esc}(?<ext>\.md)?(?<heading>\#[^\[\]|]*)?(?<aliaz>\|[^\[\]]*)?\]\]}
    end

    # The same grammar expressed as a string for ripgrep, so the candidate scan
    # and the Ruby rewrite agree on what an exact match is.
    def link_pattern_string(old_name)
      esc = Regexp.escape(old_name)
      "\\[\\[([^\\[\\]#|]*/)?#{esc}(\\.md)?(#[^\\[\\]|]*)?(\\|[^\\[\\]]*)?\\]\\]"
    end

    # Uses ripgrep (fast, exact, cross-platform) to list only the files that
    # actually contain a matching link. Falls back to a Dir.glob scan if rg is
    # not on PATH.
    def candidate_files(root, old_name)
      rg = ripgrep_path
      return glob_markdown(root) unless rg

      pattern = link_pattern_string(old_name)
      cmd = "#{Shellwords.escape(rg)} --files-with-matches --null --no-messages " \
            "-g '*.md' #{Shellwords.escape(pattern)} #{Shellwords.escape(root)}"
      out = `#{cmd}`
      out.split("\x00").reject(&:empty?)
    end

    def rewrite_file(file, pattern, new_name, old_name, new_title, document_type)
      content = File.read(file)
      updated = content.gsub(pattern) do
        m = Regexp.last_match
        aliaz = rewrite_alias(m[:aliaz], old_name, new_title, document_type)
        "[[#{m[:prefix]}#{new_name}#{m[:ext]}#{m[:heading]}#{aliaz}]]"
      end
      return if updated == content

      File.write(file, updated)
      Diataxis.logger.info "Updated wiki-links in #{file}"
    end

    # Retitles an alias that was the document's old title; preserves any other
    # alias (and the no-alias case). `alias_capture` includes the leading "|".
    def rewrite_alias(alias_capture, old_name, new_title, document_type)
      return nil if alias_capture.nil?

      text = alias_capture[1..]
      if new_title && document_type&.title_of_filename?(text, old_name)
        "|#{new_title}"
      else
        "|#{text}"
      end
    end

    def ripgrep_path
      path = `command -v rg 2>/dev/null`.strip
      path.empty? ? nil : path
    end

    def glob_markdown(root)
      Dir.glob(File.join(root, '**', '*.md'))
    end
  end
end
