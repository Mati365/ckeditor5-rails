# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Editor::Props do
  let(:bundle) { CKEditor5::Rails::Assets::AssetsBundle.new }
  let(:type) { :classic }
  let(:config) { { plugins: [], toolbar: { items: [] } } }

  describe '#initialize' do
    it 'accepts valid editor type' do
      expect { described_class.new(type, {}, bundle: bundle) }.not_to raise_error
    end

    it 'raises error for invalid editor type' do
      expect { described_class.new(:invalid, {}, bundle: bundle) }
        .to raise_error(ArgumentError, 'Invalid editor type: invalid')
    end
  end

  describe '#to_attributes' do
    subject(:props) { described_class.new(type, config, bundle: bundle) }

    it 'includes required attributes' do
      attributes = props.to_attributes
      expect(attributes).to include(
        type: 'ClassicEditor',
        bundle: String,
        plugins: String,
        config: String,
        watchdog: true
      )
    end

    context 'when bundle is nil' do
      let(:bundle) { nil }

      it 'includes bundle attribute with nil value' do
        attributes = props.to_attributes
        expect(attributes).to have_key(:bundle)
        expect(attributes[:bundle]).to be_nil
      end
    end

    context 'with editable height' do
      subject(:props) { described_class.new(type, config, bundle: bundle, editable_height: '500px') }

      it 'includes editable-height attribute' do
        expect(props.to_attributes[:'editable-height']).to eq('500px')
      end
    end

    context 'with watchdog disabled' do
      subject(:props) { described_class.new(type, config, bundle: bundle, watchdog: false) }

      it 'includes watchdog: false in attributes' do
        expect(props.to_attributes[:watchdog]).to be false
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
          described_class.new(type, config, bundle: bundle, editable_height: '500px')
        end.to raise_error(CKEditor5::Rails::Editor::InvalidEditableHeightError)
      end
    end

    context 'with classic editor' do
      let(:type) { :classic }

      it 'accepts integer values' do
        props = described_class.new(type, config, bundle: bundle, editable_height: 500)
        expect(props.to_attributes[:'editable-height']).to eq('500px')
      end

      it 'accepts pixel string values' do
        props = described_class.new(type, config, bundle: bundle, editable_height: '500px')
        expect(props.to_attributes[:'editable-height']).to eq('500px')
      end

      it 'raises error for invalid values' do
        expect do
          described_class.new(type, config, bundle: bundle, editable_height: '500em')
        end.to raise_error(CKEditor5::Rails::Editor::InvalidEditableHeightError)
      end
    end
  end
end
