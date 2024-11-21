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
    it 'creates context component with default attributes' do
      expect(helper.ckeditor5_context).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{}'
        }
      )
    end

    it 'creates context component with preset configuration' do
      expect(helper.ckeditor5_context(preset: :custom)).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{"preset":"custom"}'
        }
      )
    end

    it 'creates context component with cdn configuration' do
      expect(helper.ckeditor5_context(cdn: :jsdelivr)).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{"cdn":"jsdelivr"}'
        }
      )
    end

    it 'creates context component with multiple configurations' do
      result = helper.ckeditor5_context(preset: :custom, cdn: :jsdelivr)

      expect(result).to have_tag(
        'ckeditor-context-component',
        with: {
          plugins: '[]',
          config: '{"preset":"custom","cdn":"jsdelivr"}'
        }
      )
    end

    it 'accepts block content' do
      result = helper.ckeditor5_context { 'Content' }

      expect(result).to have_tag('ckeditor-context-component') do
        with_text 'Content'
      end
    end
  end
end
