# frozen_string_literal: true

module CKEditor5::Rails
  module Context
    class Props
      def initialize(config)
        @config = config
      end

      def to_attributes
        {
          plugins: serialize_plugins,
          config: serialize_config
        }
      end

      private

      attr_reader :config

      def serialize_plugins
        (config[:plugins] || []).map { |plugin| Editor::PropsPlugin.normalize(plugin).to_h }.to_json
      end

      def serialize_config
        config.except(:plugins).to_json
      end
    end
  end
end
