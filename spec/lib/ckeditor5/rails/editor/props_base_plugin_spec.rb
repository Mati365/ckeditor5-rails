# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::PropsBasePlugin do
  describe '.normalize' do
    it 'converts string to plugin instance' do
      plugin = described_class.normalize('Bold')
      expect(plugin).to be_a(described_class)
      expect(plugin.name).to eq('Bold')
    end

    it 'converts symbol to plugin instance' do
      plugin = described_class.normalize(:Bold)
      expect(plugin).to be_a(described_class)
      expect(plugin.name).to eq(:Bold)
    end

    it 'returns existing plugin instances unchanged' do
      original = described_class.new(:Bold)
      plugin = described_class.normalize(original)
      expect(plugin).to be(original)
    end

    it 'returns inline plugin instances unchanged' do
      inline = CKEditor5::Rails::Editor::PropsInlinePlugin.new(:Custom, 'export default class {}')
      plugin = described_class.normalize(inline)
      expect(plugin).to be(inline)
    end

    it 'raises error for invalid input' do
      expect { described_class.normalize({}) }.to raise_error(ArgumentError)
    end
  end

  describe '#preload_assets_bundle' do
    it 'returns nil by default' do
      plugin = described_class.new(:Bold)

      expect(plugin.preload_assets_bundle).to be_nil
    end
  end

  describe '#to_h' do
    it 'raises NotImplementedError' do
      plugin = described_class.new(:Bold)
      expect do
        plugin.to_h
      end.to raise_error(NotImplementedError, 'Method #to_h must be implemented in a subclass')
    end
  end

  describe '#name' do
    it 'returns the plugin name' do
      plugin = described_class.new(:Bold)
      expect(plugin.name).to eq(:Bold)
    end

    it 'preserves the type of name argument' do
      string_plugin = described_class.new('Bold')
      symbol_plugin = described_class.new(:Bold)

      expect(string_plugin.name).to eq('Bold')
      expect(symbol_plugin.name).to eq(:Bold)
    end
  end
end
