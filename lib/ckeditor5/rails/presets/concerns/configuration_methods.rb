# frozen_string_literal: true

require 'active_support'

module CKEditor5::Rails
  module Presets
    module Concerns
      # ConfigurationMethods provides functionality for configuring CKEditor 5 presets and instances.
      #
      # This module is included in preset builders and allows setting various configuration options
      # for the editor.
      #
      # @example Basic configuration in preset
      #   presets.define :custom do
      #     configure :height, '400px'
      #     configure :width, '600px'
      #   end
      #
      # @example Complex configuration with nested options
      #   presets.define :custom do
      #     configure :image, {
      #       toolbar: ['imageTextAlternative', 'imageStyle:inline'],
      #       styles: ['alignLeft', 'alignCenter']
      #     }
      #   end
      #
      # @example Plugin-specific configuration
      #   presets.define :custom do
      #     configure :heading, {
      #       options: [
      #         { model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph' },
      #         { model: 'heading1', view: 'h1', title: 'Heading 1', class: 'ck-heading_heading1' }
      #       ]
      #     }
      #   end
      module ConfigurationMethods
        extend ActiveSupport::Concern

        included do
          attr_reader :config
        end

        # Sets a configuration value for a given key in the editor configuration.
        #
        # @param key [Symbol, String] The configuration key
        # @param value [Object] The configuration value
        #
        # @example Setting simple configuration
        #   configure :width, '500px'
        #
        # @example Setting plugin configuration
        #   configure :toolbar, ['bold', 'italic', '|', 'undo', 'redo']
        #
        # @example Setting nested configuration
        #   configure :image, {
        #     styles: {
        #       options: ['alignLeft', 'alignCenter']
        #     }
        #   }
        def configure(key, value)
          config[key] = value
        end
      end
    end
  end
end
