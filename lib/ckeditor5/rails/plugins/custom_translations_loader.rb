# frozen_string_literal: true

require_relative '../editor/props_inline_plugin'

module CKEditor5::Rails::Plugins
  class CustomTranslationsLoader < CKEditor5::Rails::Editor::PropsInlinePlugin
    def initialize(translations, **kwargs) # rubocop:disable Metrics/MethodLength
      code = <<~JS.freeze
        const { Plugin } = await import('ckeditor5');

        function resolveTranslationReferences(uiLanguage, config, visited = new WeakSet()) {
          if (!config || typeof config !== 'object') {
            return config;
          }

          if (visited.has(config)) {
            return config;
          }

          visited.add(config);

          if (Array.isArray(config)) {
            config.forEach((item, index) => {
              config[index] = resolveTranslationReferences(uiLanguage, item, visited);
            });

            return config;
          }

          for (const key of Object.getOwnPropertyNames(config)) {
            const value = config[key];

            if (value && typeof value === 'object') {
              if (value.$translation) {
                const translationKey = value.$translation;
                const translations = window.CKEDITOR_TRANSLATIONS?.[uiLanguage];

                if (!translations?.dictionary[translationKey]) {
                  console.warn(`Translation not found for key: ${translationKey}`);
                }

                config[key] = translations?.dictionary[translationKey] || translationKey;
              } else {
                resolveTranslationReferences(uiLanguage, value, visited);
              }
            }
          }

          return config;
        }

        return class CustomTranslationsLoader extends Plugin {
          static CUSTOM_TRANSLATIONS = Object.create( #{translations.to_json} );

          static get pluginName() {
            return 'CustomTranslationsLoader';
          }

          constructor( editor ) {
            super( editor );

            const { locale, config } = this.editor;

            this.#extendPack();
            resolveTranslationReferences(locale.uiLanguage, config._config)
          }

          #extendPack() {
            const { uiLanguage } = this.editor.locale;
            const translations = this.#translations;

            if (!window.CKEDITOR_TRANSLATIONS) {
              window.CKEDITOR_TRANSLATIONS = {};
            }

            if (!window.CKEDITOR_TRANSLATIONS[uiLanguage]) {
              window.CKEDITOR_TRANSLATIONS[uiLanguage] = { dictionary: {} };
            }

            Object.entries(translations).forEach(([key, value]) => {
              window.CKEDITOR_TRANSLATIONS[uiLanguage].dictionary[key] = value;
            });
          }

          get #translations() {
            const { uiLanguage } = this.editor.locale;

            return CustomTranslationsLoader.CUSTOM_TRANSLATIONS[uiLanguage];
          }
        }
      JS

      super(:CustomTranslationsLoader, code, **kwargs)
    end
  end
end
