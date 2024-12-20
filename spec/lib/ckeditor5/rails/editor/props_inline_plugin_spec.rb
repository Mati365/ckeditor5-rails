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
