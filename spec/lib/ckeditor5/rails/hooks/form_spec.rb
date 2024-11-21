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
    end
  end
end
