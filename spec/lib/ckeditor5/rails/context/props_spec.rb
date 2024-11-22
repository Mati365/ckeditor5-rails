# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Context::Props do
  let(:config) do
    {
      plugins: [
        CKEditor5::Rails::Editor::PropsPlugin.new('Plugin1', import_name: '@ckeditor/plugin1'),
        CKEditor5::Rails::Editor::PropsInlinePlugin.new('plugin2', 'export default class Plugin2 {}')
      ],
      toolbar: { items: %w[bold italic] },
      language: 'en'
    }
  end

  subject(:props) { described_class.new(config) }

  describe '#initialize' do
    it 'accepts a config hash' do
      expect { described_class.new({}) }.not_to raise_error
    end
  end

  describe '#to_attributes' do
    subject(:attributes) { props.to_attributes }

    it 'returns integrity property' do
      expect(attributes[:integrity]).to eq(
        '24e46c3ee19f6764930b38ecdf62c0ac824a0acbe6616b46199d892afb211acb'
      )
    end

    it 'returns a hash with plugins and config keys' do
      expect(attributes).to be_a(Hash)
      expect(attributes.keys).to match_array(%i[plugins integrity config])
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
          'type' => 'external',
          'import_name' => '@ckeditor/plugin1'
        )
        expect(plugins.last).to include(
          'type' => 'inline',
          'name' => 'plugin2',
          'code' => 'export default class Plugin2 {}'
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
