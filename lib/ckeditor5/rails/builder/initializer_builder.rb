# frozen_string_literal: true

module CKEditor5::Rails::Builder
  class InitializerBuilder
    CKEDITOR_EDITOR_TYPES_IMPORTS = {
      classic: 'ClassicEditor',
      inline: 'InlineEditor',
      balloon: 'BalloonEditor',
      decoupled: 'DecoupledEditor',
      multiroot: 'MultiRootEditor'
    }.freeze

    attr_reader :id, :type, :config

    def initialize(type, config, id: nil)
      raise ArgumentError, "Invalid editor type: #{type}" unless CKEDITOR_EDITOR_TYPES_IMPORTS.key?(type)

      @type = type
      @id = id || SecureRandom.uuid
      @config = config
    end

    def to_js
      <<-JS
        import { #{editor_constructor} } from 'ckeditor5';
        #{initializer_plugins.js_imports}

        (() => {
          const setupEditor = () => {
            #{editor_constructor}
              .create(document.getElementById('#{id}'), #{js_config})
              .catch(error => {
                console.error(error);
              });
          };

          if (['complete', 'loaded'].includes(document.readyState))
            setupEditor();
          else
            document.addEventListener('DOMContentLoaded', setupEditor);
        })();
      JS
    end

    private

    def js_config
      @js_config ||= config
                     .except(:plugins)
                     .merge(plugins: '__CKEDITOR_PLUGINS__')
                     .to_json
                     .gsub('"__CKEDITOR_PLUGINS__"', initializer_plugins.js_config_plugins)
    end

    def initializer_plugins
      @initializer_plugins ||= InitializerPlugins.new(config[:plugins])
    end

    def editor_constructor
      CKEDITOR_EDITOR_TYPES_IMPORTS[type]
    end
  end
end
