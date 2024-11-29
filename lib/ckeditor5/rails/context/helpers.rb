# frozen_string_literal: true

require_relative 'preset_builder'
require_relative 'preset_serializer'

module CKEditor5::Rails::Context
  module Helpers
    # Creates a CKEditor context component that can be shared between multiple editors.
    # This allows you to define common plugins that will be available to all editors
    # within the context.
    #
    # @param [PresetBuilder] preset The preset object containing shared plugins configuration
    # @yield The block where editor instances should be defined
    #
    # @example Basic usage with shared plugins
    #   <% preset = ckeditor5_context_preset do
    #     plugins :Mention, :Emoji  # These plugins will be shared across all editors
    #   end %>
    #
    #   <%= ckeditor5_context(preset) do %>
    #     <%= ckeditor5_editor preset: :content %>
    #     <%= ckeditor5_editor preset: :description %>
    #   <% end %>
    def ckeditor5_context(preset = nil, &block)
      preset ||= PresetBuilder.new
      context_props = PresetSerializer.new(preset)

      tag.public_send(:'ckeditor-context-component', **context_props.to_attributes, &block)
    end

    # Creates a new preset builder object for use with ckeditor5_context.
    # Used to define shared plugins that will be available to all editors within the context.
    # Note: Only plugins configuration is relevant for context, other settings like toolbar
    # should be configured at the editor level.
    #
    # @yield Block for configuring the shared plugins
    # @return [PresetBuilder] A new preset builder instance
    #
    # @example Creating a context with shared plugins
    #   <% preset = ckeditor5_context_preset do
    #     plugins :Comments, :TrackChanges, :Collaboration  # Shared functionality plugins
    #   end %>
    def ckeditor5_context_preset(&block)
      PresetBuilder.new(&block)
    end
  end
end
