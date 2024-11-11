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
      type: nil, preset: nil,
      initial_data: nil, watchdog: true,
      **html_attributes, &block
    )
      validate_editor_input!(initial_data, block)
      controller_context = validate_and_get_editor_context!

      preset = resolve_editor_preset(preset || controller_context[:preset])
      config = build_editor_config(preset, config, extra_config, initial_data)
      type ||= preset.type

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

    def validate_editor_input!(initial_data, block)
      return unless initial_data && block

      raise ArgumentError, 'Cannot pass initial data and block at the same time.'
    end

    def resolve_editor_preset(preset_name)
      fetch_editor_preset(preset_name || :default)
    end

    def build_editor_config(preset, config, extra_config, initial_data)
      editor_config = config || preset.config
      editor_config = editor_config.deep_merge(extra_config)
      editor_config[:initialData] = initial_data if initial_data
      editor_config
    end

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
