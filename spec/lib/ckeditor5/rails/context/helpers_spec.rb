# frozen_string_literal: true

require 'spec_helper'
require 'action_view'

RSpec.describe CKEditor5::Rails::Context::Helpers do
  let(:test_class) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include CKEditor5::Rails::Context::Helpers

      def content_security_policy_nonce
        'test-nonce'
      end
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

    it 'returns empty component when preset is nil' do
      result = helper.ckeditor5_context(nil)

      expect(result).to be_html_safe
      expect(result).to have_tag('ckeditor-context-component', count: 1)
      expect(result).not_to have_tag('script')
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

    it 'includes inline plugins script tags when preset has inline plugins' do
      preset = CKEditor5::Rails::Context::PresetBuilder.new do
        inline_plugin :CustomPlugin, <<~JS
          const { Plugin } = await import('ckeditor5');

          return class CustomPlugin extends Plugin {
            static get pluginName() { return 'CustomPlugin'; }
          }
        JS
      end

      result = helper.ckeditor5_context(preset)

      expect(result).to have_tag('script', with: { nonce: 'test-nonce' }) do
        with_text(/CustomPlugin/)
      end

      expect(result).to have_tag('ckeditor-context-component')
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
  end
end
