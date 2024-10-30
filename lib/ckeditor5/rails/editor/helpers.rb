# frozen_string_literal: true

require_relative 'props_plugin'
require_relative 'props'

module CKEditor5::Rails
  module Editor::Helpers
    class EditorContextError < StandardError; end
    class PresetNotFoundError < ArgumentError; end

    def ckeditor5_editor(config: nil, type: nil, preset: :default, **html_attributes)
      context = validate_and_get_editor_context!

      preset_config = fetch_editor_preset(preset)

      editor_props = build_editor_props(
        config: config || preset_config.config,
        type: type || preset_config.type,
        context: context
      )

      render_editor_component(editor_props, html_attributes)
    end

    private

    def validate_and_get_editor_context!
      unless defined?(@__ckeditor_context)
        raise EditorContextError,
              'CKEditor installation context is not defined. ' \
              'Ensure ckeditor5_assets is called in the head section.'
      end

      @__ckeditor_context
    end

    def fetch_editor_preset(preset)
      Engine.base.presets[preset] or
        raise PresetNotFoundError, "Preset #{preset} is not defined."
    end

    def build_editor_props(config:, type:, context:)
      Editor::Props.new(context, type, config)
    end

    def render_editor_component(props, html_attributes)
      tag.send(:'ckeditor-component', **props.to_attributes, **html_attributes)
    end
  end
end
