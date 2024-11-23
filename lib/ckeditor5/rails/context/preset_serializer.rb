# frozen_string_literal: true

module CKEditor5::Rails
  module Context
    class PresetSerializer
      def initialize(preset)
        @preset = preset
      end

      def to_attributes
        {
          plugins: serialize_plugins,
          config: serialize_config
        }
      end

      private

      delegate :config, to: :@preset

      def serialize_plugins
        (config[:plugins] || []).map { |plugin| Editor::PropsPlugin.normalize(plugin).to_h }.to_json
      end

      def serialize_config
        config.except(:plugins).to_json
      end
    end
  end
end
