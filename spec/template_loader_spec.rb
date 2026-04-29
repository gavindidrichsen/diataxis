# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'

RSpec.describe Diataxis::TemplateLoader do
  let(:test_dir) { File.join(File.expand_path('..', File.dirname(__FILE__)), 'tmp', 'test') }
  let(:config_path) { File.join(test_dir, '.diataxis') }

  before do
    Diataxis::Log.reset!
    FileUtils.rm_rf(test_dir)
    FileUtils.mkdir_p(test_dir)
    FileUtils.mkdir_p(File.dirname(config_path))
    File.write(config_path, JSON.generate(Diataxis::Config::DEFAULT_CONFIG))
  end

  after do
    FileUtils.rm_rf(test_dir)
  end

  describe '.load_template' do
    let(:gem_root) { File.expand_path('..', File.dirname(__FILE__)) }
    let(:common_path) { File.join(gem_root, 'templates', 'common.metadata') }

    context 'with {{common.metadata}} placeholder' do
      it 'resolves the placeholder with common.metadata content' do
        content = described_class.load_template(Diataxis::DocumentRegistry.lookup('explanation'), 'Test Topic')

        expect(content).to include('**Style Guidelines (Strict):**')
        expect(content).to include('Treat this document as a template to be filled, not redesigned.')
        expect(content).not_to include('{{common.metadata}}')
      end

      it 'resolves placeholder before title/date substitutions' do
        original_content = File.read(common_path)

        begin
          File.write(common_path, original_content + "\n{{title}} should remain literal")
          content = described_class.load_template(Diataxis::DocumentRegistry.lookup('explanation'), 'My Title')

          expect(content).to include('My Title should remain literal')
          expect(content).not_to include('{{title}} should remain literal')
        ensure
          File.write(common_path, original_content)
        end
      end
    end

    context 'with templates that lack the placeholder' do
      it 'returns content without error' do
        Dir.chdir(test_dir) do
          content = described_class.load_template(Diataxis::ADR, 'Test Decision', adr_number: '0001', status: 'Proposed')

          expect(content).to include('Test Decision')
          expect(content).not_to include('{{common.metadata}}')
          expect(content).not_to include('Style Guidelines')
        end
      end
    end

    context 'when common.metadata file is missing' do
      it 'raises TemplateError with descriptive message' do
        backup_path = "#{common_path}.bak"

        begin
          FileUtils.mv(common_path, backup_path)

          expect { described_class.load_template(Diataxis::DocumentRegistry.lookup('explanation'), 'Test') }
            .to raise_error(Diataxis::TemplateError, /common\.metadata/)
        ensure
          FileUtils.mv(backup_path, common_path)
        end
      end
    end
  end

  describe 'behavioral equivalence' do
    it 'produces explanation with common guidelines and type-specific metadata' do
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['explanation', 'new', 'Test Topic'])
      end

      doc_path = File.join(test_dir, 'docs', 'understanding_test_topic.md')
      content = File.read(doc_path)

      aggregate_failures do
        expect(content).to include('Style Guidelines (Strict)')
        expect(content).to include('Treat this document as a template to be filled')
        expect(content).to include('Purpose Section Requirement')
        expect(content).to include('Code Evidence Requirement')
        expect(content).to include('# Understanding Test Topic')
        expect(content).to include('## Purpose')
        expect(content).to include('## Background')
        expect(content).to include('## Key Concepts')
      end
    end

    it 'produces handover with common guidelines and type-specific metadata' do
      Dir.chdir(test_dir) do
        Diataxis::CLI.run(['handover', 'new', 'Server Migration'])
      end

      doc_path = File.join(test_dir, 'docs', 'handover_server_migration.md')
      content = File.read(doc_path)

      aggregate_failures do
        expect(content).to include('Style Guidelines (Strict)')
        expect(content).to include('Treat this document as a template to be filled')
        expect(content).to include('Linking Rules')
        expect(content).to include('# Server Migration')
        expect(content).to include('## Problem Summary')
        expect(content).to include('## What Do We Know')
        expect(content).to include('## What We Think')
      end
    end
  end
end
