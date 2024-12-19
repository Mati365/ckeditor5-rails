# frozen_string_literal: true

module CKEditor5::Rails::Editor::Helpers
  module Config
    # Creates a reference to a DOM element that will be used by CKEditor's features.
    # This is particularly useful for features that need to check element presence
    # or operate on specific DOM elements.
    #
    # @param selector [String] CSS selector for the target element
    # @return [Hash] A hash with the element reference in CKEditor's format
    #
    # @example Referencing an element in plugin configuration
    #   configure :yourPlugin, {
    #     element: ckeditor5_element_ref("body")
    #   }
    def ckeditor5_element_ref(selector)
      { '$element': selector }
    end

    # Creates or retrieves a preset configuration for CKEditor.
    # When called with a name, finds and returns an existing preset.
    # When called with a block, creates a new preset with the given configuration.
    #
    # @param name [Symbol, nil] The name of an existing preset to retrieve
    # @yield Block for configuring a new preset
    # @return [PresetBuilder] The preset configuration object
    #
    # @example Finding an existing preset
    #   @preset = ckeditor5_preset(:default)
    #
    # @example Creating a custom preset in controller
    #   @preset = ckeditor5_preset do
    #     version '43.3.1'
    #     toolbar :sourceEditing, :|, :bold, :italic
    #     plugins :Essentials, :Paragraph, :Bold, :Italic
    #   end
    #
    # @example Using preset in view
    #   <%= ckeditor5_assets preset: @preset %>
    #   <%= ckeditor5_editor %>
    #
    # @example Overriding existing preset
    #   @preset = ckeditor5_preset(:default).override do
    #     toolbar do
    #       remove :underline, :heading
    #     end
    #   end
    def ckeditor5_preset(name = nil, &block)
      return CKEditor5::Rails::Engine.find_preset(name) if name

      raise ArgumentError, 'Configuration block is required for preset definition' unless block_given?

      CKEditor5::Rails::Presets::PresetBuilder.new(
        disallow_inline_plugins: true,
        &block
      )
    end
  end
end
