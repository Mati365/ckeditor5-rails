# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::PropsInlinePlugin do
  let(:valid_code) do
    <<~JAVASCRIPT
      import Plugin from '@ckeditor/ckeditor5-core/src/plugin';
      export default class CustomPlugin extends Plugin {
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

    it 'raises error when code lacks export default' do
      expect { described_class.new(:CustomPlugin, 'class CustomPlugin {}') }
        .to raise_error(ArgumentError, /must include `export default`/)
    end
  end

  describe '#to_h' do
    it 'returns correct hash representation' do
      plugin = described_class.new(:CustomPlugin, valid_code)
      expect(plugin.to_h).to eq({
                                  type: :inline,
                                  name: :CustomPlugin,
                                  code: valid_code
                                })
    end
  end
end
