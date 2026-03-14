# frozen_string_literal: true

require 'e2e/spec_helper'

RSpec.describe 'CKEditor5 Types Integration', type: :feature, js: true do
  shared_examples 'an editor' do |path|
    before { visit path }

    it 'loads and initializes the editor' do
      expect(page).to have_css('.ck-editor__editable', wait: 10)
    end
  end

  shared_examples 'an editor that fires change event with main payload' do |path|
    before { visit path }

    it 'sends properly change events with proper payload' do
      editor = first('.ck-editor__editable')

      # Set up detailed change event listener
      page.execute_script(<<~JS)
        window._editorEvents = [];
        document.querySelector('ckeditor-component').addEventListener('editor-change', (e) => {
          window._editorEvents.push({
            data: e.detail.data,
            hasEditor: !!e.detail.editor
          });
        });
      JS

      # Clear editor and type text
      editor.click
      editor.send_keys([[:control, 'a'], :backspace])
      editor.send_keys('Hello from keyboard!')

      # Wait for change events and verify the last one
      eventually do
        events = page.evaluate_script('window._editorEvents')
        last_event = events.last

        expect(last_event['data']).to eq('main' => '<p>Hello from keyboard!</p>')
        expect(last_event['hasEditor']).to be true
      end
    end
  end

  shared_examples 'a multiroot editor that fires change events' do |path, editables|
    before { visit path }

    it 'sends properly change events with proper payload for editables' do
      editors = editables.map do |name|
        find("[data-testid='#{name}-editable']")
      end

      # Set up detailed change event listener
      page.execute_script(<<~JS)
        window._editorEvents = [];
        document.querySelector('ckeditor-component').addEventListener('editor-change', (e) => {
          window._editorEvents.push({
            data: e.detail.data,
            hasEditor: !!e.detail.editor
          });
        });
      JS

      expect(page).to have_css('.ck-editor__editable', minimum: editables.size, wait: 10)

      # Test each editable
      expected_data = {}
      editors.each_with_index do |editor, index|
        editor.click
        editor.send_keys([[:control, 'a'], :backspace])

        content = "Content for #{editables[index]}"

        editor.send_keys(content)
        expected_data[editables[index]] = "<p>#{content}</p>"
      end

      # Wait for change events and verify the last one
      eventually do
        events = page.evaluate_script('window._editorEvents')
        last_event = events.last

        expect(last_event['data']).to eq(expected_data)
        expect(last_event['hasEditor']).to be true
      end
    end
  end

  describe 'Classic Editor' do
    it_behaves_like 'an editor', 'classic'
    it_behaves_like 'an editor that fires change event with main payload', 'classic'

    it 'initializes the inline plugin' do
      visit 'classic'

      eventually do
        plugin_exists = page.evaluate_script('window.__customPlugin !== undefined')
        expect(plugin_exists).to be true
      end
    end

    it 'initializes the window plugin' do
      visit 'classic'

      eventually do
        plugin_exists = page.evaluate_script('window.__customWindowPlugin !== undefined')
        expect(plugin_exists).to be true
      end
    end
  end

  describe 'Decoupled Editor' do
    before { visit 'decoupled' }

    it_behaves_like 'an editor', 'decoupled'
    it_behaves_like 'an editor that fires change event with main payload', 'decoupled'

    it 'has separate toolbar' do
      expect(page).to have_css('.toolbar-container .ck-toolbar')
    end
  end

  describe 'Balloon Editor' do
    before { visit 'balloon' }

    it_behaves_like 'an editor', 'balloon'
    it_behaves_like 'an editor that fires change event with main payload', 'balloon'

    it 'shows balloon toolbar on selection' do
      editor = first('.ck-editor__editable')
      editor.click

      expect(page).to have_css('.ck-balloon-panel', wait: 5)
    end
  end

  describe 'Inline Editor' do
    it_behaves_like 'an editor', 'inline'
    it_behaves_like 'an editor that fires change event with main payload', 'inline'
  end

  describe 'Multiroot Editor' do
    before { visit 'multiroot' }

    it_behaves_like 'an editor', 'multiroot'
    it_behaves_like 'a multiroot editor that fires change events', 'multiroot', %w[toolbar content]

    it 'supports multiple editable areas' do
      expect(page).to have_css('.ck-editor__editable', minimum: 2)
    end

    it 'shares toolbar between editables' do
      expect(page).to have_css('.ck-toolbar', count: 1)
    end

    it 'handles dynamically added editables' do
      page.execute_script(<<~JS)
        window._newEditableEvents = [];
        document.querySelector('ckeditor-component').addEventListener('editor-change', (e) => {
          window._newEditableEvents.push({
            data: e.detail.data,
            hasEditor: !!e.detail.editor
          });
        });
      JS

      page.execute_script(<<~JS)
        const container = document.querySelector('[data-testid="multiroot-editor"]');
        const newEditable = document.createElement('ckeditor-editable-component');
        newEditable.setAttribute('name', 'new-root');
        container.appendChild(newEditable);
      JS

      # Wait for the new editable to be fully initialized by CKEditor,
      # not just present in the DOM — minimum: 3 because multiroot already has 2
      expect(page).to have_css('.ck-editor__editable', minimum: 3, wait: 10)

      new_editable = find("[name='new-root']")
      new_editable.click
      new_editable.send_keys([[:control, 'a'], :backspace])
      new_editable.send_keys('Content for new root')

      eventually do
        events = page.evaluate_script('window._newEditableEvents')
        last_event = events.last

        expect(last_event['data']).to include(
          'content' => '',
          'new-root' => '<p>Content for new root</p>',
          'toolbar' => '<p>This is a toolbar editable</p>'
        )

        expect(last_event['hasEditor']).to be true
      end
    end
  end
end
