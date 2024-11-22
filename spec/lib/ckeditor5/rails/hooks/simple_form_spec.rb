# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Hooks::SimpleForm::CKEditor5Input do
  let(:template) { instance_double('ActionView::Base') }
  let(:object) { double('Post', content: 'Initial content') }
  let(:object_name) { 'post' }
  let(:builder) do
    double('FormBuilder',
           object: object,
           object_name: object_name,
           template: template)
  end
  let(:attribute_name) { :content }
  let(:input_html_options) { {} }
  let(:input_options) { {} }

  subject(:input) do
    described_class.new(builder, attribute_name, nil, input_html_options, input_options)
  end

  before do
    allow(template).to receive(:ckeditor5_editor)
  end

  describe '#input' do
    it 'renders ckeditor with default options' do
      input.input

      expect(template).to have_received(:ckeditor5_editor).with(
        hash_including(
          preset: :default,
          type: :classic,
          config: nil,
          initial_data: 'Initial content',
          name: 'post[content]',
          class: [{}, :required] # Simple Form adds these classes by default
        )
      )
    end

    context 'with custom options' do
      let(:input_options) do
        {
          preset: :custom_preset,
          type: :inline,
          config: { toolbar: [:bold] }
        }
      end
      let(:input_html_options) do
        { class: 'custom-class', id: 'custom-id' }
      end

      it 'renders ckeditor with merged options' do
        input.input

        expect(template).to have_received(:ckeditor5_editor).with(
          hash_including(
            preset: :custom_preset,
            type: :inline,
            config: { toolbar: [:bold] },
            initial_data: 'Initial content',
            name: 'post[content]',
            class: [{ class: 'custom-class', id: 'custom-id' }, :required]
          )
        )
      end
    end

    context 'when object does not respond to attribute' do
      let(:object) { double('Post') }
      let(:input_options) { { initial_data: 'Provided content' } }

      it 'uses initial_data from options' do
        input.input

        expect(template).to have_received(:ckeditor5_editor).with(
          hash_including(initial_data: 'Provided content')
        )
      end
    end

    context 'with wrapper options' do
      let(:wrapper_options) { { wrapper_class: 'wrapper' } }
      let(:input_html_options) { { class: 'input' } }

      it 'merges wrapper options with input options' do
        input.input(wrapper_options)

        expect(template).to have_received(:ckeditor5_editor).with(
          hash_including(
            class: [{ class: 'input' }, :required],
            wrapper_class: 'wrapper'
          )
        )
      end
    end
  end
end
