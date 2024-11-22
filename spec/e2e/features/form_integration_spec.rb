# frozen_string_literal: true

require 'e2e/spec_helper'

RSpec.describe 'Form Integration', type: :feature, js: true do
  before do
    visit('form')
    setup_form_tracking(page)
  end

  shared_examples 'a form with CKEditor' do |form_testid, editor_testid, submit_testid| # rubocop:disable Metrics/BlockLength
    let(:form) { find("[data-testid='#{form_testid}']") }
    let(:editor) { find("[data-testid='#{editor_testid}']") }
    let(:editable) { editor.find('.ck-editor__editable') }
    let(:text_field) { editor.find('textarea', visible: :hidden) }
    let(:submit_button) { find("[data-testid='#{submit_testid}']") }

    it 'loads editor properly' do
      expect(page).to have_css("[data-testid='#{editor_testid}'] .ck-editor__editable")
      expect(editor).to have_invisible_textarea
    end

    it 'validates required fields' do
      editable.click
      editable.send_keys([[:control, 'a'], :backspace])

      text_field.set('')
      submit_button.click

      expect(form).not_to have_been_submitted
      expect(text_field).to be_invalid
    end

    it 'submits with valid data' do
      editable.click
      editable.send_keys('New content')
      text_field.set('Second field value')

      submit_button.click

      eventually do
        expect(form).to have_been_submitted
      end
    end
  end

  describe 'Rails form' do
    it_behaves_like 'a form with CKEditor',
                    'rails-form',
                    'rails-form-editor',
                    'rails-form-submit'
  end

  describe 'Simple form' do
    it_behaves_like 'a form with CKEditor',
                    'simple-form',
                    'simple-form-editor',
                    'simple-form-submit'
  end
end
