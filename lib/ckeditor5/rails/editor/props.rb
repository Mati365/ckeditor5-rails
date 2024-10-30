# frozen_string_literal: true

module CKEditor5::Rails::Editor
  class Props
    CKEDITOR_EDITOR_TYPES_IMPORTS = {
      classic: 'ClassicEditor',
      inline: 'InlineEditor',
      balloon: 'BalloonEditor',
      decoupled: 'DecoupledEditor',
      multiroot: 'MultiRootEditor'
    }.freeze

    attr_reader :type, :context, :config

    def initialize(context, type, config)
      raise ArgumentError, "Invalid editor type: #{type}" unless CKEDITOR_EDITOR_TYPES_IMPORTS.key?(type)

      @context = context
      @type = type
      @config = config
    end

    def to_attributes
      {
        type: editor_constructor,
        translations: build_translations_json,
        plugins: build_plugins_json,
        config: build_config_json
      }
    end

    private

    def build_plugins_json
      config[:plugins]
        .map { |plugin| PropsPlugin.normalize_plugin(plugin).to_h }
        .to_json
    end

    def build_translations_json
      bundle.translations_scripts.map { |script| script.import_meta.to_h }.to_json
    end

    def build_config_json
      config
        .except(:plugins)
        .merge(
          licenseKey: context[:license_key] || 'GPL'
        )
        .to_json
    end

    def bundle
      context[:bundle]
    end

    def editor_constructor
      CKEDITOR_EDITOR_TYPES_IMPORTS[type]
    end
  end

  class PropsPlugin
    attr_reader :name, :premium

    delegate :to_h, to: :import_meta

    def initialize(name, premium: false)
      @name = name
      @premium = premium
    end

    def self.normalize_plugin(plugin)
      if plugin.is_a?(String) || plugin.is_a?(Symbol)
        new(plugin)
      elsif plugin.is_a?(PropsPlugin)
        plugin
      else
        raise ArgumentError, "Invalid plugin: #{plugin}"
      end
    end

    def import_meta
      import_name = premium ? 'ckeditor5-premium-features' : 'ckeditor5'

      ::CKEditor5::Rails::Assets::JSImportMeta.new(
        import_as: name,
        import_name: import_name
      )
    end
  end
end
