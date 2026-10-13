# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'
require 'tmpdir'

RSpec.describe Diataxis::DocumentRenamer do
  # Outside the gem checkout so Config.find_config cannot pick up its .diataxis.
  let(:root) { File.join(Dir.tmpdir, 'diataxis-renamer-spec') }
  let(:docs) { File.join(root, 'docs') }

  before do
    Diataxis::Log.reset!
    FileUtils.rm_rf(root)
    FileUtils.mkdir_p(docs)
    File.write(File.join(root, '.diataxis'), JSON.generate(Diataxis::Config::DEFAULT_CONFIG))
  end

  after { FileUtils.rm_rf(root) }

  def write_doc(name, title, dir: docs)
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, name), "# #{title}\n\nBody.\n")
  end

  def rename_all
    described_class.new(root, Diataxis::DocumentRegistry.all).rename_all
  end

  it 'renames a document whose filename no longer matches its title and returns the count' do
    write_doc('explanation_old_name.md', 'A Better Name')

    expect(rename_all).to eq(1)
    expect(File).to exist(File.join(docs, 'explanation_a_better_name.md'))
    expect(File).not_to exist(File.join(docs, 'explanation_old_name.md'))
  end

  it 'returns 0 and changes nothing when every filename already matches its title' do
    write_doc('explanation_a_better_name.md', 'A Better Name')

    expect(rename_all).to eq(0)
    expect(File).to exist(File.join(docs, 'explanation_a_better_name.md'))
  end

  it 'repoints wiki-links in other documents to the renamed file' do
    write_doc('explanation_old_name.md', 'A Better Name')
    File.write(File.join(docs, 'notes.md'), "See [[explanation_old_name]].\n")

    rename_all

    expect(File.read(File.join(docs, 'notes.md'))).to include('[[explanation_a_better_name]]')
  end

  it 'renames documents of every type, including those in subdirectories' do
    write_doc('howto_how_to_old.md', 'How to New')
    write_doc('tutorial_old.md', 'New Tutorial', dir: File.join(docs, 'sub'))

    expect(rename_all).to eq(2)
    expect(File).to exist(File.join(docs, 'howto_how_to_new.md'))
    expect(File).to exist(File.join(docs, 'sub', 'tutorial_new_tutorial.md'))
  end

  it 'never creates a README' do
    write_doc('explanation_old_name.md', 'A Better Name')

    rename_all

    expect(Dir.glob(File.join(root, '**', 'README.md'))).to be_empty
  end
end
