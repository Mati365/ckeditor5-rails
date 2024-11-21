# frozen_string_literal: true

require_relative '../../version_detector'
require_relative '../../presets/preset_builder'
require_relative 'config_helpers'

module CKEditor5::Rails
  module Editor::Helpers::Editor
    include Editor::Helpers::Config

    class EditorContextError < StandardError; end
    class PresetNotFoundError < ArgumentError; end

    # Creates a CKEditor 5 editor instance
    #
    # @param preset [Symbol] High-level configuration preset that defines base editor setup,
    #   including editor type, plugins, and default configuration
    # @param config [Hash] Editor-specific configuration that overrides preset defaults
    # @param extra_config [Hash] Additional configuration to be merged with the base config
    # @param type [Symbol] Editor type (:classic, :inline, :balloon, :decoupled, :multiroot),
    #   defaults to preset's type if not specified
    # @param initial_data [String] Initial content for the editor
    # @param watchdog [Boolean] Whether to enable the CKEditor watchdog feature
    # @param editable_height [String, Integer] Height of the editable area (Classic editor only)
    # @param html_attributes [Hash] Additional HTML attributes for the editor element
    def ckeditor5_editor( # rubocop:disable Metrics/ParameterLists
      preset: nil,
      config: nil, extra_config: {}, type: nil,
      initial_data: nil, watchdog: true,
      editable_height: nil,
      **html_attributes, &block
    )
      validate_editor_input!(initial_data, block)

      controller_context = validate_and_get_editor_context!

      preset = find_preset(preset || controller_context[:preset] || :default)
      config = build_editor_config(preset, config, extra_config, initial_data)
      type ||= preset.type

      editor_props = Editor::Props.new(
        controller_context, type, config,
        watchdog: watchdog,
        editable_height: editable_height
      )

      tag_attributes = html_attributes.merge(editor_props.to_attributes)

      tag.public_send(:'ckeditor-component', **tag_attributes, &block)
    end

    def ckeditor5_editable(name = nil, **kwargs, &block)
      tag.public_send(:'ckeditor-editable-component', name: name, **kwargs, &block)
    end

    def ckeditor5_ui_part(name, **kwargs, &block)
      tag.public_send(:'ckeditor-ui-part-component', name: name, **kwargs, &block)
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

    def build_editor_config(preset, config, extra_config, initial_data)
      editor_config = config || preset.config
      editor_config = editor_config.deep_merge(extra_config)
      editor_config[:initialData] = initial_data if initial_data

      if preset.automatic_upgrades? && editor_config[:version].present?
        detected_version = VersionDetector.latest_safe_version(editor_config[:version])
        editor_config[:version] = detected_version if detected_version
      end

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

    def find_preset(preset)
      Engine.find_preset(preset) or
        raise PresetNotFoundError, "Preset #{preset} is not defined."
    end
  end
end
