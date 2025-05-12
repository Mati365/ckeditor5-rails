# frozen_string_literal: true

require_relative 'props_plugin'
require_relative 'editable_height_normalizer'

module CKEditor5::Rails::Editor
  class Props
    EDITOR_TYPES = {
      classic: 'ClassicEditor',
      inline: 'InlineEditor',
      balloon: 'BalloonEditor',
      decoupled: 'DecoupledEditor',
      multiroot: 'MultiRootEditor'
    }.freeze

    def initialize(
      type, config,
      bundle: nil,
      watchdog: true,
      editable_height: nil
    )
      raise ArgumentError, "Invalid editor type: #{type}" unless Props.valid_editor_type?(type)

      @bundle = bundle
      @watchdog = watchdog
      @type = type
      @config = config
      @editable_height = EditableHeightNormalizer.new(type).normalize(editable_height)
    end

    def to_attributes
      {
        type: EDITOR_TYPES[@type]
      }
        .merge(serialized_attributes)
    end

    def self.valid_editor_type?(type)
      EDITOR_TYPES.key?(type)
    end

    private

    attr_reader :bundle, :watchdog, :type, :config, :editable_height

    def serialized_attributes
      {
        bundle: bundle.to_json,
        plugins: serialize_plugins,
        config: serialize_config,
        watchdog: watchdog
      }
        .merge(editable_height ? { 'editable-height' => editable_height } : {})
    end

    def serialize_plugins
      (config[:plugins] || []).map { |plugin| PropsBasePlugin.normalize(plugin).to_h }.to_json
    end

    def serialize_config
      config
        .except(:plugins)
        .to_json
    end
  end
end
