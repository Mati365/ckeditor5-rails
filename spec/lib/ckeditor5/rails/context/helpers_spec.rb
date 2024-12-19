# frozen_string_literal: true

require 'spec_helper'
require 'action_view'

RSpec.describe CKEditor5::Rails::Context::Helpers do
  let(:test_class) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include CKEditor5::Rails::Context::Helpers
    end
  end

  let(:helper) { test_class.new }

  describe '#ckeditor5_context' do
    let(:empty_preset) { CKEditor5::Rails::Context::PresetBuilder.new }

    let(:custom_preset) do
      CKEditor5::Rails::Context::PresetBuilder.new do
        configure :preset, :custom
      end
    end

    let(:cdn_preset) do
      CKEditor5::Rails::Context::PresetBuilder.new do
        configure :cdn, :jsdelivr
      end
    end

    let(:complex_preset) do
      CKEditor5::Rails::Context::PresetBuilder.new do
        configure :preset, :custom
        configure :cdn, :jsdelivr
      end
    end

    it 'is optional to pass a preset' do
      expect(helper.ckeditor5_context).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{}'
        }
      )
    end

    it 'creates context component with default attributes' do
      expect(helper.ckeditor5_context(empty_preset)).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{}'
        }
      )
    end

    it 'creates context component with preset configuration' do
      expect(helper.ckeditor5_context(custom_preset)).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{"preset":"custom"}'
        }
      )
    end

    it 'creates context component with cdn configuration' do
      expect(helper.ckeditor5_context(cdn_preset)).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{"cdn":"jsdelivr"}'
        }
      )
    end

    it 'creates context component with multiple configurations' do
      result = helper.ckeditor5_context(complex_preset)

      expect(result).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{"preset":"custom","cdn":"jsdelivr"}'
        }
      )
    end

    it 'accepts block content' do
      result = helper.ckeditor5_context(empty_preset) { 'Content' }

      expect(result).to have_tag('ckeditor-context-component') do
        with_text 'Content'
      end
    end
  end

  describe '#ckeditor5_context_preset' do
    it 'creates a new preset builder' do
      preset = helper.ckeditor5_context_preset do
        configure :preset, :custom
      end

      expect(preset.config).to eq(
        plugins: [],
        preset: :custom
      )
    end

    it 'raises error when trying to define inline plugin' do
      expect do
        helper.ckeditor5_context_preset do
          inline_plugin :TestPlugin, <<~JS
            export default class TestPlugin { }
          JS
        end
      end.to raise_error(
        CKEditor5::Rails::Presets::Concerns::PluginMethods::DisallowedInlinePlugin,
        'Inline plugins are not allowed here.'
      )
    end
  end
end
