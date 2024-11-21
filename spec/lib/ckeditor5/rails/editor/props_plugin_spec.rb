# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::PropsPlugin do
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

  describe '#to_h' do
    it 'generates hash for standard plugin' do
      plugin = described_class.new(:Bold)
      expect(plugin.to_h).to include(
        type: :external,
        import_name: 'ckeditor5',
        import_as: :Bold
      )
    end

    it 'generates hash for premium plugin' do
      plugin = described_class.new(:Bold, premium: true)
      expect(plugin.to_h).to include(
        type: :external,
        import_name: 'ckeditor5-premium-features',
        import_as: :Bold
      )
    end

    it 'handles custom import metadata' do
      plugin = described_class.new(:Custom,
                                   import_name: 'custom-module',
                                   window_name: 'CustomPlugin')
      expect(plugin.to_h).to include(
        type: :external,
        import_name: 'custom-module',
        window_name: 'CustomPlugin'
      )
    end
  end
end
