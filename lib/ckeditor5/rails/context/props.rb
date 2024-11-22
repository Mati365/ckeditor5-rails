# frozen_string_literal: true

module CKEditor5::Rails
  module Context
    class Props
      include CKEditor5::Rails::Concerns::Checksum

      def initialize(config)
        @config = config
      end

      def to_attributes
        {
          **serialized_attributes,
          integrity: integrity_checksum
        }
      end

      private

      attr_reader :config

      def integrity_checksum
        unsafe_attributes = serialized_attributes.slice(:plugins)

        calculate_object_checksum(unsafe_attributes)
      end

      def serialized_attributes
        @serialized_attributes ||= {
          plugins: serialize_plugins,
          config: serialize_config
        }
      end

      def serialize_plugins
        (config[:plugins] || []).map { |plugin| Editor::PropsPlugin.normalize(plugin).to_h }.to_json
      end

      def serialize_config
        config.except(:plugins).to_json
      end
    end
  end
end
