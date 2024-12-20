# frozen_string_literal: true

require 'e2e/spec_helper'

RSpec.describe 'Lazy Assets', type: :feature do
  context 'without JavaScript', js: false do
    before do
      visit 'classic_lazy_assets?no_embed=true'
    end

    it 'does not load CKEditor assets' do
      expect(page).not_to have_css('link[href*="ckeditor5"]', visible: false)
      expect(page).not_to have_css('script[src*="ckeditor5"]', visible: false)

      scripts = page.all('script:not([type="importmap"]):not([type="module"])', visible: false)
      external_scripts = scripts.reject { |s| s[:src].nil? }
      expect(external_scripts).not_to include(match(/ckeditor5/))

      expect(page).to have_css('script[type="importmap"]', visible: false)
    end
  end

  context 'with JavaScript', js: true do
    before { visit 'classic_lazy_assets' }

    it 'loads editor when needed' do
      expect(page).to have_css('.ck-editor__editable', wait: 10)
      expect(page).to have_css('link[href*="ckeditor5"]', visible: false)
    end

    it 'initializes editor properly' do
      editor = find('.ck-editor__editable')
      expect(editor).to be_visible

      editor.click
      editor.send_keys('Test content')

      expect(editor).to have_text('Test content')
    end

    it 'initializes the inline plugin' do
      eventually do
        plugin_exists = page.evaluate_script('window.__customPlugin !== undefined')
        expect(plugin_exists).to be true
      end
    end

    it 'supports multiple editor instances' do
      visit 'classic_lazy_assets?multiple=true'

      editors = all('.ck-editor__editable', wait: 10)
      expect(editors.length).to eq(2)

      editors.each do |editor|
        editor.click
        editor.send_keys('Content for editor')
        expect(editor).to have_text('Content for editor')
      end
    end
  end
end
