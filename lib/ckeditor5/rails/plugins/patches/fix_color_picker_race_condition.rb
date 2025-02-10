# frozen_string_literal: true

require_relative '../../editor/props_patch_plugin'

module CKEditor5::Rails::Plugins::Patches
  # Fixes focus management issues in the CKEditor5 color picker component
  # by ensuring proper focus handling when the color picker is opened.
  #
  # The patch modifies the ColorPickerView's focus behavior to properly
  # focus either the hex input field (when visible) or the first slider.
  #
  # @see https://github.com/ckeditor/ckeditor5/issues/17069
  class FixColorPickerRaceCondition < CKEditor5::Rails::Editor::PropsPatchPlugin
    PLUGIN_CODE = <<~JS
      const { Plugin, ColorPickerView, debounce } = await import( 'ckeditor5' );

      return class FixColorPickerRaceCondition extends Plugin {
        static get pluginName() {
          return 'FixColorPickerRaceCondition';
        }

        constructor(editor) {
          super(editor);
          this.editor = editor;
          this.#applyPatch();
        }

        #applyPatch() {
          const { focus } = ColorPickerView.prototype;

          ColorPickerView.prototype.focus = function() {
              try {
                if (!this._config.hideInput) {
                  this.hexInputRow.children.get( 1 ).focus();
                }

                this.slidersView.first.focus();
              } catch (error) {
                focus.apply(this, arguments);
              }
          }
        }
      }
    JS

    def initialize
      super(:FixColorPickerRaceCondition, PLUGIN_CODE)
      compress!
    end
  end
end
