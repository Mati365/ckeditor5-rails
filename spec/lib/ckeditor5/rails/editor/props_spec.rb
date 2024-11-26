# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::Props do
  let(:controller_context) do
    {
      bundle: double('Bundle', translations_scripts: [{ path: 'translations/en.js' }]),
      license_key: nil
    }
  end
  let(:type) { :classic }
  let(:config) { { plugins: [], toolbar: { items: [] } } }

  describe '#initialize' do
    it 'accepts valid editor type' do
      expect { described_class.new(controller_context, :classic, {}) }.not_to raise_error
    end

    it 'raises error for invalid editor type' do
      expect { described_class.new(controller_context, :invalid, {}) }
        .to raise_error(ArgumentError, 'Invalid editor type: invalid')
    end
  end

  describe '#to_attributes' do
    subject(:props) { described_class.new(controller_context, type, config) }

    it 'includes required attributes' do
      attributes = props.to_attributes
      expect(attributes).to include(
        type: 'ClassicEditor',
        translations: String,
        plugins: String,
        config: String,
        watchdog: true
      )
    end

    context 'with editable height' do
      subject(:props) { described_class.new(controller_context, type, config, editable_height: '500px') }

      it 'includes editable-height attribute' do
        expect(props.to_attributes['editable-height']).to eq('500px')
      end
    end

    context 'with language' do
      subject(:props) { described_class.new(controller_context, type, config, language: 'pl') }

      it 'includes language in config' do
        config_json = props.to_attributes[:config]

        expect(config_json).to include('language')
        expect(JSON.parse(config_json)['language']).to eq({ 'ui' => 'pl' })
      end
    end

    context 'with license key' do
      let(:controller_context) do
        { bundle: double('Bundle', translations_scripts: []), license_key: 'ABC123' }
      end

      it 'includes license key in config' do
        config_json = props.to_attributes[:config]
        expect(config_json).to include('licenseKey')
        expect(JSON.parse(config_json)['licenseKey']).to eq('ABC123')
      end
    end
  end

  describe '.valid_editor_type?' do
    it 'returns true for valid types' do
      %i[classic inline balloon decoupled multiroot].each do |type|
        expect(described_class.valid_editor_type?(type)).to be true
      end
    end

    it 'returns false for invalid types' do
      expect(described_class.valid_editor_type?(:invalid)).to be false
    end
  end

  describe 'editable height validation' do
    context 'with non-classic editor' do
      let(:type) { :inline }

      it 'raises error when editable height is set' do
        expect do
          described_class.new(controller_context, type, config, editable_height: '500px')
        end.to raise_error(CKEditor5::Rails::Editor::InvalidEditableHeightError)
      end
    end

    context 'with classic editor' do
      let(:type) { :classic }

      it 'accepts integer values' do
        props = described_class.new(controller_context, type, config, editable_height: 500)
        expect(props.to_attributes['editable-height']).to eq('500px')
      end

      it 'accepts pixel string values' do
        props = described_class.new(controller_context, type, config, editable_height: '500px')
        expect(props.to_attributes['editable-height']).to eq('500px')
      end

      it 'raises error for invalid values' do
        expect do
          described_class.new(controller_context, type, config, editable_height: '500em')
        end.to raise_error(CKEditor5::Rails::Editor::InvalidEditableHeightError)
      end
    end
  end
end
