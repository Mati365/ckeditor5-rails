# frozen_string_literal: true

module CKEditor5::Rails::Builder::JS
  class InitializerBuilder
    CKEDITOR_EDITOR_TYPES_IMPORTS = {
      classic: 'ClassicEditor',
      inline: 'InlineEditor',
      balloon: 'BalloonEditor',
      decoupled: 'DecoupledEditor',
      multiroot: 'MultiRootEditor'
    }.freeze

    attr_reader :id, :type, :context, :config

    def initialize(context, type, config, id: nil)
      raise ArgumentError, "Invalid editor type: #{type}" unless CKEDITOR_EDITOR_TYPES_IMPORTS.key?(type)

      @context = context
      @type = type
      @id = id || SecureRandom.uuid
      @config = config
    end

    def to_js
      <<-JS
        import { #{editor_constructor} } from 'ckeditor5';
        #{initializer_plugins.esm_imports}
        #{initializer_translations.esm_imports}

        (() => {
          const setupEditor = () => {
            #{initializer_plugins.window_imports}
            #{editor_constructor}.create(document.getElementById('#{id}'), #{js_config}).catch(error => {
              console.error(error);
            });
          };

          if (document.readyState === 'loaded')
            setupEditor();
          else
            window.addEventListener('load', setupEditor);
        })();
      JS
    end

    private

    def js_config
      @js_config ||= config
                     .except(:plugins)
                     .merge(
                       plugins: '__CKEDITOR_PLUGINS__',
                       translations: '__CKEDITOR_TRANSLATIONS__',
                       licenseKey: context[:license_key] || 'GPL'
                     )
                     .to_json
                     .gsub('"__CKEDITOR_PLUGINS__"', initializer_plugins.js_config_plugins)
                     .gsub('"__CKEDITOR_TRANSLATIONS__"', initializer_translations.js_config_translations)
    end

    def initializer_translations
      @initializer_translations ||= InitializerTranslations.new(context[:bundle])
    end

    def initializer_plugins
      @initializer_plugins ||= InitializerPlugins.new(config[:plugins])
    end

    def editor_constructor
      CKEDITOR_EDITOR_TYPES_IMPORTS[type]
    end
  end
end
