# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Hooks::Form do
  describe CKEditor5::Rails::Hooks::Form::EditorInputBuilder do
    let(:post) { Post.new(content: 'Initial content') }
    let(:builder) { described_class.new(:post, post, template) }
    let(:template) do
      ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
    end

    before do
      template.ckeditor5_assets(version: '34.1.0')
    end

    describe '#build_editor' do
      subject(:rendered_editor) { builder.build_editor(:content) }

      it 'renders ckeditor element' do
        attrs = {
          name: 'post[content]',
          id: 'post_content',
          type: 'ClassicEditor',
          translations: '[{"import_name":"ckeditor5/translations/en.js"}]',
          watchdog: 'true'
        }

        expect(rendered_editor).to have_tag('ckeditor-component', with: attrs)
      end

      context 'with custom attributes' do
        subject(:rendered_editor) do
          builder.build_editor(:content, class: 'custom-class', id: 'custom-id', name: 'custom-name')
        end

        it 'respects custom HTML attributes' do
          expect(rendered_editor).to have_tag('ckeditor-component', with: {
                                                class: 'custom-class',
                                                id: 'custom-id',
                                                name: 'custom-name'
                                              })
        end
      end

      context 'with as parameter' do
        subject(:rendered_editor) do
          builder.build_editor(:content, as: 'custom_field')
        end

        it 'uses custom field name' do
          expect(rendered_editor).to have_tag('ckeditor-component', with: {
                                                name: 'post[custom_field]'
                                              })
        end
      end

      context 'without object_name' do
        let(:builder) { described_class.new('', post, template) }

        it 'uses method name as field name' do
          expect(rendered_editor).to have_tag('ckeditor-component', with: {
                                                name: 'content'
                                              })
        end

        context 'with as parameter' do
          subject(:rendered_editor) do
            builder.build_editor(:content, as: 'custom_field')
          end

          it 'uses as parameter as field name' do
            expect(rendered_editor).to have_tag('ckeditor-component', with: {
                                                  name: 'custom_field'
                                                })
          end
        end
      end

      context 'with initial data handling' do
        before do
          allow(template).to receive(:ckeditor5_editor)
        end

        context 'when object responds to the method' do
          it 'passes object method value as initial_data' do
            builder.build_editor(:content)

            expect(template).to have_received(:ckeditor5_editor)
              .with(hash_including(initial_data: 'Initial content'))
          end
        end

        context 'when object does not respond to the method' do
          let(:post) { double('Post') }

          it 'passes options initial_data value' do
            builder.build_editor(:content, initial_data: 'Provided content')

            expect(template).to have_received(:ckeditor5_editor)
              .with(hash_including(initial_data: 'Provided content'))
          end
        end
      end

      context 'with validation classes handling' do
        before do
          allow(template).to receive(:ckeditor5_editor)
        end

        context 'when object has errors on the field' do
          let(:post) do
            instance_double('Post', errors: { content: ['is invalid'] })
          end

          it 'adds is-invalid class' do
            builder.build_editor(:content, class: 'custom-class')

            expect(template).to have_received(:ckeditor5_editor)
              .with(hash_including(class: 'custom-class is-invalid'))
          end

          it 'adds is-invalid class when no initial class exists' do
            builder.build_editor(:content)

            expect(template).to have_received(:ckeditor5_editor)
              .with(hash_including(class: 'is-invalid'))
          end
        end

        context 'when object has no errors' do
          let(:post) do
            instance_double('Post', errors: {})
          end

          it 'keeps original class unchanged' do
            builder.build_editor(:content, class: 'custom-class')

            expect(template).to have_received(:ckeditor5_editor)
              .with(hash_including(class: 'custom-class'))
          end
        end

        context 'when object does not respond to errors' do
          let(:post) { double('Post') }

          it 'keeps original class unchanged' do
            builder.build_editor(:content, class: 'custom-class')

            expect(template).to have_received(:ckeditor5_editor)
              .with(hash_including(class: 'custom-class'))
          end
        end
      end
    end
  end

  describe CKEditor5::Rails::Hooks::Form::FormBuilderExtension do
    let(:template) { instance_double('ActionView::Base') }
    let(:object) { double('Post') }
    let(:builder) do
      Class.new do
        include CKEditor5::Rails::Hooks::Form::FormBuilderExtension
        attr_reader :object_name, :object, :template

        def initialize(object_name, object, template)
          @object_name = object_name
          @object = object
          @template = template
        end
      end.new('post', object, template)
    end

    describe '#ckeditor5' do
      let(:input_builder) { instance_double(CKEditor5::Rails::Hooks::Form::EditorInputBuilder) }

      before do
        allow(CKEditor5::Rails::Hooks::Form::EditorInputBuilder)
          .to receive(:new)
          .with('post', object, template)
          .and_return(input_builder)
        allow(input_builder).to receive(:build_editor)
      end

      it 'creates EditorInputBuilder with correct parameters' do
        builder.ckeditor5(:content, class: 'custom-class')

        expect(CKEditor5::Rails::Hooks::Form::EditorInputBuilder)
          .to have_received(:new)
          .with('post', object, template)
      end

      it 'calls build_editor with correct parameters' do
        options = { class: 'custom-class' }
        builder.ckeditor5(:content, options)

        expect(input_builder)
          .to have_received(:build_editor)
          .with(:content, options)
      end
    end
  end
end
