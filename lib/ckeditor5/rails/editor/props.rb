# frozen_string_literal: true

require_relative 'props_plugin'

module CKEditor5::Rails::Editor
  class Props
    EDITOR_TYPES = {
      classic: 'ClassicEditor',
      inline: 'InlineEditor',
      balloon: 'BalloonEditor',
      decoupled: 'DecoupledEditor',
      multiroot: 'MultiRootEditor'
    }.freeze

    def initialize(controller_context, type, config, watchdog: true)
      raise ArgumentError, "Invalid editor type: #{type}" unless Props.valid_editor_type?(type)

      @controller_context = controller_context
      @watchdog = watchdog
      @type = type
      @config = config
    end

    def to_attributes
      {
        type: EDITOR_TYPES[@type],
        **serialized_attributes
      }
    end

    def self.valid_editor_type?(type)
      EDITOR_TYPES.key?(type)
    end

    private

    attr_reader :controller_context, :watchdog, :type, :config

    def serialized_attributes
      {
        translations: serialize_translations,
        plugins: serialize_plugins,
        config: serialize_config,
        watchdog: watchdog
      }
    end

    def serialize_translations
      controller_context[:bundle].translations_scripts.map(&:to_h).to_json
    end

    def serialize_plugins
      (config[:plugins] || []).map { |plugin| PropsPlugin.normalize(plugin).to_h }.to_json
    end

    def serialize_config
      config
        .except(:plugins)
        .tap { |cfg| cfg[:licenseKey] = controller_context[:license_key] if controller_context[:license_key] }
        .to_json
    end
  end
end
