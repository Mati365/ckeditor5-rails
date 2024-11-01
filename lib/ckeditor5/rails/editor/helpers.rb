# frozen_string_literal: true

require_relative 'props_plugin'
require_relative 'props_inline_plugin'
require_relative 'props'

module CKEditor5::Rails
  module Editor::Helpers
    class EditorContextError < StandardError; end
    class PresetNotFoundError < ArgumentError; end

    def ckeditor5_editor(
      config: nil, extra_config: {},
      type: nil, preset: :default,
      **html_attributes, &block
    )
      context = validate_and_get_editor_context!
      preset = fetch_editor_preset(preset)

      config ||= preset.config
      type ||= preset.type

      editor_props = build_editor_props(
        config: config.deep_merge(extra_config),
        type: type,
        context: context
      )

      render_editor_component(editor_props, html_attributes,
                              &(%i[multiroot decoupled].include?(type) ? block : nil))
    end

    def ckeditor5_editable(name = nil, **kwargs, &block)
      tag.send(:'ckeditor-editable-component', name: name, **kwargs, &block)
    end

    def ckeditor5_ui_part(name, **kwargs, &block)
      tag.send(:'ckeditor-ui-part-component', name: name, **kwargs, &block)
    end

    def ckeditor5_toolbar(**kwargs)
      ckeditor5_ui_part('toolbar', **kwargs)
    end

    def ckeditor5_menubar(**kwargs)
      ckeditor5_ui_part('menuBarView', **kwargs)
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

    def render_editor_component(props, html_attributes, &block)
      tag.send(:'ckeditor-component', **props.to_attributes, **html_attributes, &block)
    end
  end
end
