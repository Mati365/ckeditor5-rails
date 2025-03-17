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

  describe '#try_compress!' do
    let(:plugin) { described_class.new(:CustomPlugin, valid_code) }
    let(:compiled_code) { '(async()=>{const compressed_code})()' }
    let(:terser_instance) { instance_double('Terser') }

    context 'when compression is enabled' do
      it 'compresses the code using Terser' do
        expect(Terser).to receive(:new).with(compress: false, mangle: true).and_return(terser_instance)
        expect(terser_instance).to receive(:compile).with(plugin.code).and_return(compiled_code)

        plugin.try_compress!
        expect(plugin.code).to eq(compiled_code)
      end
    end

    context 'when compression is disabled' do
      let(:plugin) { described_class.new(:CustomPlugin, valid_code, compress: false) }
      let(:original_code) { plugin.code.dup }

      it 'does not modify the code' do
        expect(Terser).not_to receive(:new)

        plugin.try_compress!
        expect(plugin.code).to eq(original_code)
      end
    end
  end

  describe '#to_h' do
    it 'returns correct hash representation' do
      plugin = described_class.new(:CustomPlugin, valid_code)
      expect(plugin.to_h).to eq({ window_name: :CustomPlugin })
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
