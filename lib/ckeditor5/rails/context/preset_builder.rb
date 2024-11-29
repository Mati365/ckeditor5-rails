# frozen_string_literal: true

require_relative '../presets/concerns/configuration_methods'
require_relative '../presets/concerns/plugin_methods'

module CKEditor5::Rails
  module Context
    # PresetBuilder provides functionality for building CKEditor 5 presets.
    #
    # This class includes configuration and plugin handling methods from concerns
    # and allows defining presets either through initialization blocks or method chaining.
    #
    # @example Basic preset definition
    #   preset = PresetBuilder.new do
    #     version '43.3.1'
    #     gpl
    #     type :classic
    #     toolbar :bold, :italic
    #   end
    #
    # @example Cloning and modifying a preset
    #   new_preset = preset.clone
    #   new_preset.toolbar do
    #     append :underline
    #   end
    #
    # @see Presets::Concerns::ConfigurationMethods
    # @see Presets::Concerns::PluginMethods
    class PresetBuilder
      include Presets::Concerns::ConfigurationMethods
      include Presets::Concerns::PluginMethods

      # Initializes a new preset builder with optional configuration block
      #
      # @param block [Proc] Optional configuration block
      # @example Initialize with block
      #   PresetBuilder.new do
      #     version '43.3.1'
      #     toolbar :bold, :italic
      #   end
      def initialize(&block)
        @config = {
          plugins: []
        }

        instance_eval(&block) if block_given?
      end

      # Creates a deep copy of the preset builder
      #
      # @param source [PresetBuilder] Source preset to copy from
      # @return [PresetBuilder] New preset instance with copied configuration
      def initialize_copy(source)
        super

        @config = {
          plugins: source.config[:plugins].map(&:dup)
        }.merge(
          source.config.except(:plugins).deep_dup
        )
      end
    end
  end
end
