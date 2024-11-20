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

    def initialize(controller_context, type, config, watchdog: true, editable_height: nil)
      raise ArgumentError, "Invalid editor type: #{type}" unless Props.valid_editor_type?(type)

      @controller_context = controller_context
      @watchdog = watchdog
      @type = type
      @config = config
      @editable_height = normalize_editable_height(editable_height)
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

    attr_reader :controller_context, :watchdog, :type, :config, :editable_height

    def serialized_attributes
      {
        translations: serialize_translations,
        plugins: serialize_plugins,
        config: serialize_config,
        watchdog: watchdog
      }
        .merge(editable_height ? { 'editable-height' => editable_height } : {})
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

    def normalize_editable_height(editable_height)
      return nil if editable_height.nil?

      unless type == :classic
        raise InvalidEditableHeightError,
              'editable_height can be used only with ClassicEditor'
      end

      case editable_height
      when String, /^\d+px$/ then editable_height
      when Integer, /^\d+$/ then "#{editable_height}px"
      else
        raise InvalidEditableHeightError,
              "editable_height must be an integer representing pixels or string ending with 'px'\n" \
              "(e.g. 500 or '500px'). Got: #{editable_height.inspect}"
      end
    end
  end
end
