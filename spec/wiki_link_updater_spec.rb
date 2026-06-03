# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe Diataxis::WikiLinkUpdater do
  let(:root) { Dir.mktmpdir('wiki-links') }

  after { FileUtils.remove_entry(root) }

  # Writes a markdown file under the temp root and returns its path.
  def write_note(name, body)
    path = File.join(root, name)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, body)
    path
  end

  # Renames old -> new (basenames) and runs the link updater over the tree.
  # Pass document_type to enable alias retitling.
  def rename(old_name, new_name, document_type: nil)
    described_class.update_links(
      root, File.join(root, old_name), File.join(root, new_name), document_type: document_type
    )
  end

  describe '.update_links' do
    it 'repoints a plain [[link]] to the new name' do
      note = write_note('index.md', 'See [[tutorial_intro]] for details.')
      rename('tutorial_intro.md', 'tutorial_getting_started.md')
      expect(File.read(note)).to eq('See [[tutorial_getting_started]] for details.')
    end

    it 'only replaces EXACT target matches, not prefix overlaps' do
      note = write_note('index.md', '[[tutorial_intro]] and [[tutorial_intro_advanced]]')
      rename('tutorial_intro.md', 'tutorial_basics.md')
      expect(File.read(note)).to eq('[[tutorial_basics]] and [[tutorial_intro_advanced]]')
    end

    it 'preserves an |alias' do
      note = write_note('index.md', 'Read [[tutorial_intro|the intro]] first.')
      rename('tutorial_intro.md', 'tutorial_basics.md')
      expect(File.read(note)).to eq('Read [[tutorial_basics|the intro]] first.')
    end

    it 'preserves a #heading reference' do
      note = write_note('index.md', 'Jump to [[tutorial_intro#Setup]].')
      rename('tutorial_intro.md', 'tutorial_basics.md')
      expect(File.read(note)).to eq('Jump to [[tutorial_basics#Setup]].')
    end

    it 'preserves a folder path and the .md extension' do
      note = write_note('index.md', 'See [[tutorials/tutorial_intro.md]].')
      rename('tutorial_intro.md', 'tutorial_basics.md')
      expect(File.read(note)).to eq('See [[tutorials/tutorial_basics.md]].')
    end

    it 'does not match a name embedded in a longer target' do
      note = write_note('index.md', '[[my_tutorial_intro]] stays put')
      rename('tutorial_intro.md', 'tutorial_basics.md')
      expect(File.read(note)).to eq('[[my_tutorial_intro]] stays put')
    end

    it 'updates every matching file across the tree' do
      a = write_note('a.md', '[[howto_setup]]')
      b = write_note('sub/b.md', 'again [[howto_setup]] here')
      rename('howto_setup.md', 'howto_install.md')
      expect(File.read(a)).to eq('[[howto_install]]')
      expect(File.read(b)).to eq('again [[howto_install]] here')
    end

    it 'does nothing when the name is unchanged' do
      note = write_note('index.md', '[[tutorial_intro]]')
      rename('tutorial_intro.md', 'tutorial_intro.md')
      expect(File.read(note)).to eq('[[tutorial_intro]]')
    end
  end

  describe 'alias retitling (with a document type)' do
    let(:explanation) { Diataxis::DocumentRegistry.lookup('explanation') }

    # The renamed file lives at its NEW path with its NEW title, since the
    # updater reads the new title from that file (as it does after a real mv).
    def rename_explanation(note_body)
      write_note('explanation_how_to_soar.md', "# How to soar\n\nbody")
      note = write_note('index.md', note_body)
      rename('explanation_how_to_fly.md', 'explanation_how_to_soar.md', document_type: explanation)
      File.read(note)
    end

    it 'retitles an alias that was the old title' do
      result = rename_explanation('See [[explanation_how_to_fly|How to fly]].')
      expect(result).to eq('See [[explanation_how_to_soar|How to soar]].')
    end

    it 'matches the old title regardless of its casing/punctuation' do
      result = rename_explanation('See [[explanation_how_to_fly|How To Fly!]].')
      expect(result).to eq('See [[explanation_how_to_soar|How to soar]].')
    end

    it 'keeps a custom alias that was never the title' do
      result = rename_explanation('See [[explanation_how_to_fly|the flying guide]].')
      expect(result).to eq('See [[explanation_how_to_soar|the flying guide]].')
    end

    it 'retitles the alias but preserves a #heading' do
      result = rename_explanation('Jump [[explanation_how_to_fly#Setup|How to fly]].')
      expect(result).to eq('Jump [[explanation_how_to_soar#Setup|How to soar]].')
    end

    it 'retargets a plain link with no alias' do
      result = rename_explanation('See [[explanation_how_to_fly]].')
      expect(result).to eq('See [[explanation_how_to_soar]].')
    end

    it 'leaves the alias alone when no document type is given' do
      write_note('explanation_how_to_soar.md', "# How to soar\n")
      note = write_note('index.md', 'See [[explanation_how_to_fly|How to fly]].')
      rename('explanation_how_to_fly.md', 'explanation_how_to_soar.md')
      expect(File.read(note)).to eq('See [[explanation_how_to_soar|How to fly]].')
    end
  end
end
