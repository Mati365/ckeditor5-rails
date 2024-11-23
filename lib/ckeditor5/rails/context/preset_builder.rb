# frozen_string_literal: true

require_relative '../presets/concerns/configuration_methods'
require_relative '../presets/concerns/plugin_methods'

module CKEditor5::Rails
  module Context
    class PresetBuilder
      include Presets::Concerns::ConfigurationMethods
      include Presets::Concerns::PluginMethods

      def initialize(&block)
        @config = {
          plugins: []
        }

        instance_eval(&block) if block_given?
      end

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
