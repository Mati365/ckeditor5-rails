# frozen_string_literal: true

require_relative 'props_plugin'
require_relative 'props_inline_plugin'
require_relative 'props'

module CKEditor5::Rails
  module Editor::Helpers
    class EditorContextError < StandardError; end
    class PresetNotFoundError < ArgumentError; end

    def ckeditor5_editor( # rubocop:disable Metrics/ParameterLists
      config: nil, extra_config: {},
      type: nil, preset: :default,
      initial_data: nil, watchdog: true,
      **html_attributes, &block
    )
      controller_context = validate_and_get_editor_context!
      preset = fetch_editor_preset(preset)

      config ||= preset.config
      type ||= preset.type

      config = config.deep_merge(extra_config)
      config[:initialData] = initial_data if initial_data

      raise ArgumentError, 'Cannot pass initial data and block at the same time.' if initial_data && block

      editor_props = Editor::Props.new(
        controller_context, type, config,
        watchdog: watchdog
      )

      render_editor_component(editor_props, html_attributes, &block)
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

    def render_editor_component(props, html_attributes, &block)
      tag.send(:'ckeditor-component', **props.to_attributes, **html_attributes, &block)
    end
  end
end
