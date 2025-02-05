# frozen_string_literal: true

require_relative '../editor/props_inline_plugin'

module CKEditor5::Rails::Plugins
  class SpecialCharactersBootstrap < CKEditor5::Rails::Editor::PropsInlinePlugin
    PLUGIN_CODE = <<~JS
      const { Plugin } = await import( 'ckeditor5' );

      return class SpecialCharactersBootstrap extends Plugin {
        static get pluginName() {
          return 'SpecialCharactersBootstrap';
        }

        get bootstrapConfig() {
          return this.editor.config.get('specialCharactersBootstrap');
        }

        async init() {
          const { editor, bootstrapConfig } = this;
          const currentConfig = editor.config.get('specialCharacters');

          if (!bootstrapConfig) {
            return;
          }

          editor.config.define('specialCharacters', {
            ...currentConfig,
            order: bootstrapConfig.order || currentConfig.order,
          } );
        }

        async afterInit() {
          const { editor, bootstrapConfig } = this;
          const specialCharacters = editor.plugins.get('SpecialCharacters');

          if (!specialCharacters || !bootstrapConfig) {
            return;
          }

          const groups = bootstrapConfig.groups || [];

          for (const { name, items, options } of groups) {
            specialCharacters.addItems(name, items, {
              label: name,
              ...options
            });
          }
        }
      }
    JS

    def initialize
      super(:SpecialCharactersBootstrap, PLUGIN_CODE)
      compress!
    end
  end
end
