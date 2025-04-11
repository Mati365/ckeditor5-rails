# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Presets::Manager do
  subject(:manager) { described_class.new }

  describe '#initialize' do
    it 'creates empty presets hash' do
      expect(manager.presets).to be_a(Hash)
    end

    it 'defines default preset' do
      expect(manager.default).to be_a(CKEditor5::Rails::Presets::PresetBuilder)
    end
  end

  describe '#define' do
    context 'with inheritance' do
      it 'creates new preset based on default' do
        manager.define(:custom) do
          automatic_upgrades enabled: false
          version '36.0.0', apply_patches: false
        end

        expect(manager[:custom].version).to eq('36.0.0')
        expect(manager[:custom].type).to eq(manager.default.type)
      end
    end

    context 'without inheritance' do
      it 'creates completely new preset' do
        manager.define(:custom, inherit: false) do
          automatic_upgrades enabled: false
          version '36.0.0', apply_patches: false
        end

        expect(manager[:custom].version).to eq('36.0.0')
        expect(manager[:custom].config).to eq({ plugins: [], toolbar: [] })
      end
    end

    context 'with compression settings' do
      it 'attempts compression when compression? returns true' do
        preset = manager.define(:with_compression, inherit: false) do
          version '36.0.0', apply_patches: true
          inline_plugin 'Test', <<~JAVASCRIPT
            const { Plugin } = await import( 'ckeditor5' );

            return class Abc extends Plugin {}
          JAVASCRIPT
        end

        expect(preset.config[:plugins].first.code).to include('const{Plugin:t,ColorPickerView:i,debounce:o}=')
      end

      it 'does not attempt compression when compression? returns false' do
        preset = manager.define(:without_compression, inherit: false) do
          compression enabled: false
          version '36.0.0', apply_patches: true
          inline_plugin 'Test', <<~JAVASCRIPT
            const { Plugin } = await import( 'ckeditor5' );

            return class Abc extends Plugin {}
          JAVASCRIPT
        end

        expect(preset.config[:plugins].first.code).to include('const { Plugin, ColorPickerView, debounce }')
      end
    end
  end

  describe '#override/#extend' do
    before do
      manager.define(:custom) do
        automatic_upgrades enabled: false
        version '35.0.0'
        toolbar :bold
      end
    end

    it 'modifies existing preset' do
      manager.override(:custom) do
        automatic_upgrades enabled: false
        version '36.0.0'
        toolbar :italic
      end

      expect(manager[:custom].version).to eq('36.0.0')
      expect(manager[:custom].config[:toolbar][:items]).to eq([:italic])
    end

    it 'allows using extend as alias for override' do
      manager.extend(:custom) do
        automatic_upgrades enabled: false
        version '36.0.0'
      end

      expect(manager[:custom].version).to eq('36.0.0')
    end

    context 'with compression settings' do
      let(:preset_builder) { instance_double(CKEditor5::Rails::Presets::PresetBuilder) }

      before do
        allow(preset_builder).to receive(:instance_eval)
        manager.instance_variable_set(:@presets, { custom: preset_builder })
      end

      it 'attempts compression when compression? returns true' do
        allow(preset_builder).to receive(:compression?).and_return(true)
        allow(preset_builder).to receive(:try_compress_inline_plugins!)

        manager.override(:custom) {}

        expect(preset_builder).to have_received(:try_compress_inline_plugins!).once
      end

      it 'does not attempt compression when compression? returns false' do
        allow(preset_builder).to receive(:compression?).and_return(false)
        allow(preset_builder).to receive(:try_compress_inline_plugins!)

        manager.override(:custom) {}

        expect(preset_builder).not_to have_received(:try_compress_inline_plugins!)
      end
    end
  end

  describe '#[]' do
    it 'returns preset by name' do
      manager.define(:custom) do
        automatic_upgrades enabled: false
        version '36.0.0'
      end

      expect(manager[:custom]).to be_a(CKEditor5::Rails::Presets::PresetBuilder)
      expect(manager[:custom].version).to eq('36.0.0')
    end

    it 'returns nil for non-existent preset' do
      expect(manager[:non_existent]).to be_nil
    end
  end

  describe '#default' do
    it 'has default configuration' do
      expect(manager.default.version).to eq(CKEditor5::Rails::DEFAULT_CKEDITOR_VERSION)
      expect(manager.default.type).to eq(:classic)
      expect(manager.default.automatic_upgrades?).to be true
      expect(manager.default.menubar?).to be true
      expect(manager.default.config[:plugins]).not_to be_empty
      expect(manager.default.config[:toolbar][:items]).not_to be_empty
    end
  end
end
