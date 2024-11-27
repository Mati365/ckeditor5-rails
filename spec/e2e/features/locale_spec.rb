# frozen_string_literal: true

require 'e2e/spec_helper'

TRANSLATIONS = {
  'en' => { 'Edit' => 'Edit', 'Insert' => 'Insert', 'Format' => 'Format' },
  'pl' => { 'Edit' => 'Zmiana', 'Insert' => 'Wstaw', 'Format' => 'Format' },
  'es' => { 'Edit' => 'Editar', 'Insert' => 'Insertar', 'Format' => 'Formato' },
  'ru' => { 'Edit' => 'Редактировать', 'Insert' => 'Вставить', 'Format' => 'Формат' },
  'de' => { 'Edit' => 'Bearbeiten', 'Insert' => 'Einfügen', 'Format' => 'Format' }
}.freeze

RSpec.describe 'Editor localization', type: :system do
  shared_examples 'localized editor' do |locale|
    it "displays menubar in #{locale}" do
      visit path

      expect(page).to have_css('.ck-editor__main')

      within('.ck-menu-bar') do
        TRANSLATIONS[locale].each_value do |translation|
          expect(page).to have_content(translation)
        end
      end
    end
  end

  describe 'setting locale via assets' do
    let(:path) { '/locale_via_assets' }
    it_behaves_like 'localized editor', 'pl'
  end

  describe 'setting locale via editor prop' do
    let(:path) { '/locale_via_editor' }
    it_behaves_like 'localized editor', 'es'
  end

  describe 'setting locale via preset' do
    let(:path) { '/locale_via_preset' }
    it_behaves_like 'localized editor', 'ru'
  end

  describe 'setting locale via Rails I18n' do
    context 'using default I18n.locale' do
      let(:path) { '/locale_via_rails_i18n' }
      it_behaves_like 'localized editor', 'en'
    end

    context 'using custom I18n.locale' do
      let(:path) { '/locale_via_rails_i18n?locale=de' }
      it_behaves_like 'localized editor', 'de'
    end
  end
end
