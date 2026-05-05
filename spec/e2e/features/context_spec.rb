# frozen_string_literal: true

require 'e2e/spec_helper'

RSpec.describe 'CKEditor5 Context Integration', type: :feature, js: true do
  before { visit 'context' }

  it 'initializes context with multiple editors' do
    expect(page).to have_css('.ck-editor__editable', count: 2, wait: 10)
  end

  it 'initializes the magic context plugin' do
    eventually do
      plugin_exists = page.evaluate_script('window.__magicPluginInitialized !== undefined')
      expect(plugin_exists).to be true
    end
  end

  it 'allows editing content in context editors' do
    editors = all('.ck-editor__editable', count: 2, wait: 10)

    # Test first editor
    replace_editor_content(editors[0], 'Modified Context Item 1')

    # Test second editor
    replace_editor_content(editors[1], 'Modified Context Item 2')

    # Verify content
    expect(editors[0].text).to eq('Modified Context Item 1')
    expect(editors[1].text).to eq('Modified Context Item 2')
  end
end
