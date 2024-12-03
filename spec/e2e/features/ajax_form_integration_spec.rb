# frozen_string_literal: true

require 'e2e/spec_helper'

RSpec.describe 'AJAX Form Integration', type: :feature, js: true do
  before do
    visit('form_ajax')
    setup_form_tracking(page)
  end

  shared_examples 'an ajax form with CKEditor' do |form_testid, editor_testid, submit_testid, response_id| # rubocop:disable Metrics/BlockLength
    let(:form) { find("[data-testid='#{form_testid}']") }
    let(:editor) { find("[data-testid='#{editor_testid}']") }
    let(:editable) { editor.find('.ck-editor__editable') }
    let(:text_field) { editor.find('textarea', visible: :hidden) }
    let(:submit_button) { find("[data-testid='#{submit_testid}']") }
    let(:response_container) { find("##{response_id}") }

    before do
      expect(page).to have_css('.ck-editor__editable', wait: 10)
    end

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

    it 'submits form and shows response' do
      test_content = "Test content #{Time.now.to_i}"

      editable.click
      editable.send_keys([[:control, 'a'], :backspace])
      editable.send_keys(test_content)

      sleep 1

      submit_button.click

      eventually(timeout: 13) do
        expect(response_container).to be_visible
        expect(response_container).to have_text('Success!')
        expect(response_container).to have_text(test_content)

        # Verify that CKEditor initializes in the response
        response_editor = response_container.find('.ck-editor__editable', wait: 10)

        expect(response_editor).to be_visible
        expect(response_editor).to have_text(test_content)
      end
    end
  end

  describe 'Regular AJAX form' do
    it_behaves_like 'an ajax form with CKEditor',
                    'rails-form',
                    'rails-form-editor',
                    'rails-form-submit',
                    'response'
  end

  describe 'Turbo Stream form' do
    it_behaves_like 'an ajax form with CKEditor',
                    'rails-form-stream',
                    'rails-form-editor-stream',
                    'rails-form-submit-stream',
                    'response-stream'
  end
end
