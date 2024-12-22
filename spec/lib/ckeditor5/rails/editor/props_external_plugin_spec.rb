# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::PropsExternalPlugin do
  describe '#initialize' do
    it 'creates plugin with required parameters' do
      plugin = described_class.new('Test', script: 'https://example.org/plugin.js')

      expect(plugin.name).to eq('Test')
      expect(plugin.preload_assets_bundle.scripts.first.url).to eq('https://example.org/plugin.js')
    end

    it 'accepts optional parameters' do
      plugin = described_class.new(
        'Test',
        script: 'https://example.org/plugin.js',
        import_as: 'TestPlugin',
        window_name: 'TestWindow',
        stylesheets: ['https://example.org/style.css']
      )

      expect(plugin.preload_assets_bundle.stylesheets).to include('https://example.org/style.css')
    end
  end

  describe '#preload_assets_bundle' do
    it 'returns bundle with script and stylesheets' do
      plugin = described_class.new(
        'Test',
        script: 'https://example.org/plugin.js',
        stylesheets: ['https://example.org/style1.css', 'https://example.org/style2.css']
      )

      bundle = plugin.preload_assets_bundle
      expect(bundle.scripts.first.url).to eq('https://example.org/plugin.js')
      expect(bundle.stylesheets).to eq(['https://example.org/style1.css', 'https://example.org/style2.css'])
    end
  end

  describe '#to_h' do
    it 'returns hash with plugin configuration' do
      plugin = described_class.new(
        'Test',
        script: 'https://example.org/plugin.js',
        import_as: 'TestPlugin',
        window_name: 'TestWindow',
        stylesheets: ['https://example.org/style.css']
      )

      expect(plugin.to_h).to include(
        import_name: 'https://example.org/plugin.js',
        import_as: 'TestPlugin',
        window_name: 'TestWindow',
        stylesheets: ['https://example.org/style.css']
      )
    end
  end
end
