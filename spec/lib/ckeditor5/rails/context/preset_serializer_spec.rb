# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Context::PresetSerializer do
  let(:preset) do
    CKEditor5::Rails::Context::PresetBuilder.new do
      plugin 'Plugin1', import_name: '@ckeditor/plugin1'
      inline_plugin 'plugin2', <<~JAVASCRIPT
        const { Plugin } = await import( 'ckeditor5' );

        return class Abc extends Plugin {}
      JAVASCRIPT

      configure :toolbar, { items: %w[bold italic] }
      configure :language, 'en'
    end
  end

  subject(:serializer) { described_class.new(preset) }

  describe '#initialize' do
    it 'accepts a preset instance' do
      expect { described_class.new(preset) }.not_to raise_error
    end
  end

  describe '#to_attributes' do
    subject(:attributes) { serializer.to_attributes }

    it 'returns a hash with plugins and config keys' do
      expect(attributes).to be_a(Hash)
      expect(attributes.keys).to match_array(%i[plugins config])
    end

    describe ':plugins key' do
      subject(:plugins_json) { attributes[:plugins] }

      it 'serializes plugins array to JSON' do
        expect(plugins_json).to be_a(String)
        expect(JSON.parse(plugins_json)).to be_an(Array)
      end

      it 'normalizes and includes all plugins' do
        plugins = JSON.parse(plugins_json)

        expect(plugins.size).to eq(2)

        expect(plugins.first).to include(
          'import_name' => '@ckeditor/plugin1'
        )

        expect(plugins.last).to include(
          'window_name' => 'plugin2'
        )
      end
    end

    describe ':config key' do
      subject(:config_json) { attributes[:config] }

      it 'serializes config to JSON excluding plugins' do
        expect(config_json).to be_a(String)
        parsed = JSON.parse(config_json)
        expect(parsed).to include(
          'toolbar' => { 'items' => %w[bold italic] },
          'language' => 'en'
        )
        expect(parsed).not_to include('plugins')
      end
    end
  end
end
