# frozen_string_literal: true

require_relative '../editor/props_external_plugin'

module CKEditor5::Rails::Plugins
  class WProofreader < CKEditor5::Rails::Editor::PropsExternalPlugin
    DEFAULT_VERSION = '3.1.2'
    DEFAULT_CDN = 'https://cdn.jsdelivr.net/npm/@webspellchecker/wproofreader-ckeditor5'

    def initialize(version: nil, cdn: nil)
      cdn ||= DEFAULT_CDN
      version ||= DEFAULT_VERSION

      script_url = "#{cdn}@#{version}/dist/browser/index.js"
      style_url = "#{cdn}@#{version}/dist/browser/index.css"

      super(
        :WProofreader,
        script: script_url,
        import_as: 'WProofreader',
        stylesheets: [style_url],
      )
    end
  end

  # Sync I18n language from editor to WProofreader plugin
  class WProofreaderSync < CKEditor5::Rails::Editor::PropsInlinePlugin
    PLUGIN_CODE = <<~JS
      const { Plugin, FileRepository } = await import( 'ckeditor5' );
      const CORRECTION_LANGUAGES = [
        'en_US', 'en_GB', 'pt_BR', 'da_DK',
        'nl_NL', 'en_CA', 'fi_FI', 'fr_FR',
        'fr_CA', 'de_DE', 'el_GR', 'it_IT',
        'nb_NO', 'pt_PT', 'es_ES', 'sv_SE',
        'uk_UA', 'auto'
      ];

      return class WproofreaderSync extends Plugin {
        static get pluginName() {
          return 'WProofreaderSync';
        }

        async init() {
          const { editor } = this;

          const wproofreaderConfig = editor.config.get('wproofreader');
          const editorLangCode = (() => {
            const config = editor.config.get('language');

            return config.content || config.ui;
          })();

          if (!wproofreaderConfig || !editorLangCode) {
            return;
          }

          const lang = CORRECTION_LANGUAGES.find(
            lang => lang.startsWith(editorLangCode.toLowerCase())
          ) || 'auto';

          editor.config.set('wproofreader', {
            lang,
            localization: editorLangCode,
            ...wproofreaderConfig,
          });
        }
      }
    JS

    def initialize
      super(:WProofreaderSync, PLUGIN_CODE)
      compress!
    end
  end
end
