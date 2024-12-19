# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::Helpers::Config do
  let(:test_class) { Class.new { include CKEditor5::Rails::Editor::Helpers::Config } }
  let(:helper) { test_class.new }

  describe '#ckeditor5_element_ref' do
    it 'returns a hash with $element key' do
      expect(helper.ckeditor5_element_ref('#editor')).to eq({ '$element': '#editor' })
    end

    it 'accepts any selector string' do
      expect(helper.ckeditor5_element_ref('.custom-editor')).to eq({ '$element': '.custom-editor' })
    end
  end

  describe '#ckeditor5_preset' do
    let(:preset_builder) { instance_double(CKEditor5::Rails::Presets::PresetBuilder) }

    context 'when name is provided' do
      before do
        allow(CKEditor5::Rails::Engine).to receive(:find_preset).with(:default).and_return(preset_builder)
      end

      it 'returns preset from engine' do
        expect(helper.ckeditor5_preset(:default)).to eq(preset_builder)
      end
    end

    context 'when block is provided' do
      it 'returns new PresetBuilder instance' do
        expect(CKEditor5::Rails::Presets::PresetBuilder).to receive(:new)
        helper.ckeditor5_preset {}
      end

      it 'yields the block to PresetBuilder' do
        expect { |b| helper.ckeditor5_preset(&b) }.to yield_control
      end

      it 'does not allow inline plugins definition' do
        expect do
          helper.ckeditor5_preset do
            inline_plugin :CustomPlugin, <<~JS
              import Plugin from '@ckeditor/ckeditor5-core/src/plugin';
              export default class CustomPlugin extends Plugin {
                static get pluginName() { return 'CustomPlugin'; }
              }
            JS
          end
        end.to raise_error(
          CKEditor5::Rails::Presets::Concerns::PluginMethods::DisallowedInlinePlugin,
          'Inline plugins are not allowed here.'
        )
      end
    end

    context 'when neither name nor block is provided' do
      it 'raises ArgumentError' do
        expect { helper.ckeditor5_preset }.to raise_error(
          ArgumentError,
          'Configuration block is required for preset definition'
        )
      end
    end
  end
end
