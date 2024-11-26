# frozen_string_literal: true

require 'e2e/spec_helper'

RSpec.describe 'Editor localization', type: :system do
  describe 'setting locale via assets' do
    it 'displays menubar in Polish' do
      visit '/locale_via_assets'

      expect(page).to have_css('.ck-editor__main')

      within('.ck-menu-bar') do
        expect(page).to have_content('Zmiana')
        expect(page).to have_content('Wstaw')
        expect(page).to have_content('Format')
      end
    end
  end

  describe 'setting locale via editor prop' do
    it 'displays menubar in Spanish' do
      visit '/locale_via_editor'

      expect(page).to have_css('.ck-editor__main')

      within('.ck-menu-bar') do
        expect(page).to have_content('Editar')
        expect(page).to have_content('Insertar')
        expect(page).to have_content('Formato')
      end
    end
  end

  describe 'setting locale via preset' do
    it 'displays menubar in Russian' do
      visit '/locale_via_preset'

      expect(page).to have_css('.ck-editor__main')

      within('.ck-menu-bar') do
        expect(page).to have_content('Редактировать')
        expect(page).to have_content('Вставить')
        expect(page).to have_content('Формат')
      end
    end
  end
end
