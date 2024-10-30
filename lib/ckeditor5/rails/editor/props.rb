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

    def initialize(context, type, config)
      raise ArgumentError, "Invalid editor type: #{type}" unless EDITOR_TYPES.key?(type)

      @context = context
      @type = type
      @config = config
    end

    def to_attributes
      {
        type: EDITOR_TYPES[@type],
        **serialized_attributes
      }
    end

    private

    attr_reader :context, :type, :config

    def serialized_attributes
      {
        translations: serialize_translations,
        plugins: serialize_plugins,
        config: serialize_config
      }
    end

    def serialize_translations
      context[:bundle].translations_scripts.map { |script| script.import_meta.to_h }.to_json
    end

    def serialize_plugins
      config[:plugins].map { |plugin| PropsPlugin.normalize(plugin).to_h }.to_json
    end

    def serialize_config
      config
        .except(:plugins)
        .merge(licenseKey: context[:license_key] || 'GPL')
        .to_json
    end
  end
end
