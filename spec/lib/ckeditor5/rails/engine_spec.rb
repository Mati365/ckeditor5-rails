# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Engine do
  describe 'configuration' do
    let(:preset) { instance_double(CKEditor5::Rails::Presets::PresetBuilder) }
    let(:preset_manager) { instance_double(CKEditor5::Rails::Presets::Manager) }

    before do
      allow(described_class).to receive(:base).and_return(ActiveSupport::OrderedOptions.new)
      allow(described_class.base).to receive(:presets).and_return(preset_manager)
      allow(preset_manager).to receive(:default).and_return(preset)
    end

    it 'has default configuration' do
      expect(described_class.base).to be_a(ActiveSupport::OrderedOptions)

      default_preset = described_class.default_preset

      expect(default_preset.type).to eq(:classic)
      expect(default_preset.toolbar.items).to include(:undo, :redo, :'|', :heading)
      expect(default_preset.plugins.items.map(&:name)).to include(:Essentials, :Paragraph, :Heading)
    end

    describe '.configure' do
      it 'yields configuration proxy' do
        yielded_config = nil
        described_class.configure do |config|
          yielded_config = config
        end
        expect(yielded_config).to be_a(described_class::ConfigurationProxy)
      end

      it 'allows configuring default preset' do
        described_class.configure do
          automatic_upgrades enabled: false
          version '35.0.0'
          license_key '1234567'
        end

        expect(described_class.default_preset.version).to eq('35.0.0')
        expect(described_class.default_preset.license_key).to eq('1234567')
      end
    end

    describe '.find_preset' do
      before do
        allow(preset_manager).to receive(:[]).with(:custom).and_return(preset)
        allow(preset_manager).to receive(:[]).with(
          kind_of(CKEditor5::Rails::Presets::PresetBuilder)
        ).and_return(preset)
      end

      it 'returns preset instance if provided' do
        test_preset = CKEditor5::Rails::Presets::PresetBuilder.new
        expect(described_class.find_preset(test_preset)).to eq(test_preset)
      end

      it 'looks up preset by name' do
        expect(described_class.find_preset(:custom)).to eq(preset)
      end
    end
  end

  describe 'initializers' do
    describe 'helper initializer' do
      it 'includes helpers in ActionView and ActionController' do
        expect(ActionView::Base.included_modules).to include(CKEditor5::Rails::Helpers)
        expect(ActionController::Base.included_modules).to include(CKEditor5::Rails::Helpers)
      end
    end

    describe 'form_builder initializer' do
      it 'includes FormBuilderExtension in ActionView::Helpers::FormBuilder' do
        expect(ActionView::Helpers::FormBuilder.included_modules)
          .to include(CKEditor5::Rails::Hooks::Form::FormBuilderExtension)
      end
    end

    describe 'simple_form initializer' do
      context 'when SimpleForm is defined' do
        it 'registers ckeditor5 input type' do
          expect(SimpleForm::FormBuilder.mappings[:ckeditor5])
            .to eq(CKEditor5::Rails::Hooks::SimpleForm::CKEditor5Input)
        end
      end

      context 'when SimpleForm is not defined' do
        before do
          @simple_form = SimpleForm if defined?(SimpleForm)
          Object.send(:remove_const, :SimpleForm) if defined?(SimpleForm)
        end

        after do
          Object.const_set(:SimpleForm, @simple_form) if @simple_form
        end

        it 'does not raise error' do
          initializer = described_class.initializers.find { |i| i.name == 'ckeditor5.simple_form' }
          expect { initializer.run(Rails.application) }.not_to raise_error
        end
      end
    end

    describe 'importmap initializer' do
      context 'when Importmap is not defined' do
        before do
          @importmap = Importmap if defined?(Importmap)
          Object.send(:remove_const, :Importmap) if defined?(Importmap)
        end

        after do
          Object.const_set(:Importmap, @importmap) if @importmap
        end

        it 'does not raise error' do
          initializer = described_class.initializers.find { |i| i.name == 'ckeditor5.importmap' }
          expect { initializer.run(Rails.application) }.not_to raise_error
        end
      end
    end
  end
end
