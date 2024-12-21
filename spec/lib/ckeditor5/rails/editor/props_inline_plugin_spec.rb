# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::PropsInlinePlugin do
  let(:valid_code) do
    <<~JAVASCRIPT
      const { Plugin } = await import( 'ckeditor5' );

      return class CustomPlugin extends Plugin {
        init() {
          console.log('Custom plugin initialized');
        }
      }
    JAVASCRIPT
  end

  describe '#initialize' do
    it 'accepts valid plugin code' do
      expect { described_class.new(:CustomPlugin, valid_code) }.not_to raise_error
    end

    it 'raises error when code is not a string' do
      expect { described_class.new(:CustomPlugin, nil) }
        .to raise_error(ArgumentError, 'Code must be a String')
    end
  end

  describe '#to_h' do
    it 'returns correct hash representation' do
      plugin = described_class.new(:CustomPlugin, valid_code)
      expect(plugin.to_h).to eq({
                                  type: :external,
                                  window_name: :CustomPlugin
                                })
    end
  end
end

RSpec.describe CKEditor5::Rails::Editor::InlinePluginWindowInitializer do
  let(:plugin) do
    CKEditor5::Rails::Editor::PropsInlinePlugin.new(:CustomPlugin, 'const plugin = {}')
  end

  subject(:initializer) { described_class.new(plugin) }

  describe '#to_html' do
    it 'generates script tag with event listener' do
      result = initializer.to_html

      expect(result).to be_html_safe
      expect(result).to include('script')
      expect(result).to include("window.addEventListener('ckeditor:request-cjs-plugin:CustomPlugin'")
      expect(result).to include("window['CustomPlugin']")
    end

    it 'adds nonce attribute when provided' do
      result = initializer.to_html(nonce: 'test-nonce')

      expect(result).to include('nonce="test-nonce"')
    end

    it 'wraps plugin code in event handler' do
      result = initializer.to_html

      expect(result).to include('const plugin = {}')
      expect(result).to include('{ once: true }')
    end
  end
end
