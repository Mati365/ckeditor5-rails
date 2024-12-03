# frozen_string_literal: true

require_relative '../../version_detector'
require_relative '../../presets/preset_builder'
require_relative 'config_helpers'

module CKEditor5::Rails
  module Editor::Helpers::Editor
    include Editor::Helpers::Config
    include Cdn::Concerns::BundleBuilder

    # Creates a CKEditor 5 editor instance in the view.
    #
    # @param preset [Symbol, PresetBuilder] The name of the preset or a PresetBuilder object
    # @param config [Hash] Custom editor configuration that overrides preset configuration
    # @param extra_config [Hash] Additional configuration to merge with preset/custom config
    # @param type [Symbol] Editor type (:classic, :inline, :balloon, :decoupled, :multiroot)
    # @param initial_data [String] Initial HTML content for the editor
    # @param watchdog [Boolean] Enable/disable the editor crash recovery (default: true)
    # @param editable_height [Integer] Set fixed height for editor in pixels
    # @param language [Symbol] Set editor UI language (e.g. :pl, :es)
    # @param html_attributes [Hash] Additional HTML attributes for editor element
    #
    # @example Basic usage with default preset
    #   <%= ckeditor5_editor %>
    #
    # @example Custom preset with specific height and initial content
    #   <%= ckeditor5_editor preset: :custom, editable_height: 300, initial_data: "<p>Hello</p>" %>
    #
    # @example Inline editor with custom styling
    #   <%= ckeditor5_editor type: :inline, style: 'width: 600px' %>
    #
    # @example Multiroot editor with multiple editable areas
    #   <%= ckeditor5_editor type: :multiroot do %>
    #     <%= ckeditor5_toolbar %>
    #     <%= ckeditor5_editable 'title', style: 'border: 1px solid gray' %>
    #     <%= ckeditor5_editable 'content' %>
    #   <% end %>
    #
    # @example Decoupled editor with custom UI layout
    #   <%= ckeditor5_editor type: :decoupled do %>
    #     <div class="toolbar-container">
    #       <%= ckeditor5_toolbar %>
    #     </div>
    #     <div class="editor-container">
    #       <%= ckeditor5_editable %>
    #     </div>
    #   <% end %>
    #
    # @example Editor with event handlers
    #   <%= ckeditor5_editor oneditorchange: 'handleChange',
    #                        oneditorready: 'handleReady',
    #                        oneditorerror: 'handleError' %>
    #
    # @example Form integration
    #   <%= form_for @post do |f| %>
    #     <%= f.ckeditor5 :content, required: true %>
    #   <% end %>
    def ckeditor5_editor( # rubocop:disable Metrics/ParameterLists
      preset: nil,
      config: nil, extra_config: {}, type: nil,
      initial_data: nil, watchdog: true,
      editable_height: nil, language: nil,
      **html_attributes, &block
    )
      validate_editor_input!(initial_data, block)

      context = ckeditor5_context_or_fallback(preset)

      preset = Engine.find_preset!(preset || context[:preset] || :default)
      config = build_editor_config(preset, config, extra_config, initial_data)

      type ||= preset.type

      # Add some fallbacks
      config[:licenseKey] ||= context[:license_key]
      config[:language] = { ui: language } if language

      editor_props = Editor::Props.new(
        type, config,
        bundle: context[:bundle],
        watchdog: watchdog,
        editable_height: editable_height || preset.editable_height
      )

      tag_attributes = html_attributes.merge(editor_props.to_attributes)

      tag.public_send(:'ckeditor-component', **tag_attributes, &block)
    end

    # Creates an editable area for multiroot or decoupled editors.
    #
    # @param name [String] Identifier for the editable area
    # @param kwargs [Hash] HTML attributes for the editable element
    #
    # @example Creating a named editable area in multiroot editor
    #   <%= ckeditor5_editable 'content', style: 'border: 1px solid gray' %>
    def ckeditor5_editable(name = nil, **kwargs, &block)
      tag.public_send(:'ckeditor-editable-component', name: name, **kwargs, &block)
    end

    # Creates a UI part component for the editor (toolbar, menubar).
    #
    # @param name [String] Name of the UI component ('toolbar', 'menuBarView')
    # @param kwargs [Hash] HTML attributes for the UI component
    #
    # @example Creating a toolbar component
    #   <%= ckeditor5_ui_part 'toolbar' %>
    def ckeditor5_ui_part(name, **kwargs, &block)
      tag.public_send(:'ckeditor-ui-part-component', name: name, **kwargs, &block)
    end

    # Creates a toolbar component for decoupled editor.
    #
    # @param kwargs [Hash] HTML attributes for the toolbar element
    #
    # @example Creating a toolbar with custom class
    #   <%= ckeditor5_toolbar class: 'custom-toolbar' %>
    def ckeditor5_toolbar(**kwargs)
      ckeditor5_ui_part('toolbar', **kwargs)
    end

    # Creates a menubar component for decoupled editor.
    #
    # @param kwargs [Hash] HTML attributes for the menubar element
    #
    # @example Creating a menubar with custom styling
    #   <%= ckeditor5_menubar style: 'margin-bottom: 10px' %>
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

    def ckeditor5_context_or_fallback(preset)
      return @__ckeditor_context if @__ckeditor_context.present?

      if preset.present?
        found_preset = Engine.find_preset(preset)

        return {
          bundle: create_preset_bundle(found_preset),
          preset: found_preset
        }
      end

      {
        bundle: nil,
        preset: Engine.default_preset
      }
    end
  end
end
