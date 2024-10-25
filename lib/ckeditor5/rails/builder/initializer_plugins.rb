# frozen_string_literal: true

module CKEditor5::Rails::Builder
  class InitializerPlugins
    attr_reader :plugins

    def initialize(plugins)
      @plugins = plugins || []
    end

    def js_config_plugins
      return @js_config_plugins if defined?(@js_config_plugins)

      plugins = [
        *internal_plugins,
        *window_plugins.map { |plugin| plugin[:name] },
        *esm_plugins.map { |plugin| plugin[:import_name] }
      ]

      @js_config_plugins = "[ #{plugins.join(', ')} ]".delete('"')
    end

    def js_imports
      @js_imports ||= [
        internal_plugins.empty? ? '' : "import { #{internal_plugins.join(', ')} } from 'ckeditor5';",
        esm_plugins.map { |plugin| "import { #{plugin[:import_name]} } from '#{plugin[:name]}';" },
        window_plugins.map { |plugin| "const #{plugin[:name]} = window['#{plugin[:name]}'];" }
      ].join("\n")
    end

    private

    def internal_plugins
      @internal_plugins ||= plugins.filter_map do |plugin|
        next unless plugin.is_a?(String) || plugin.is_a?(Symbol)

        plugin.to_s
      end
    end

    def window_plugins
      @window_plugins ||= plugins.filter_map do |plugin|
        next unless plugin.is_a?(CustomWindowPlugin)

        name = "__window_plugin_#{plugin.name.parameterize}"

        {
          code: "const #{name} = window['#{plugin.name}'];",
          name: name
        }
      end
    end

    def esm_plugins
      @esm_plugins ||= plugins.filter_map do |plugin|
        next unless plugin.is_a?(CustomEsmPlugin)

        {
          import_name: plugin.import_name,
          name: plugin.name
        }
      end
    end
  end

  class CustomWindowPlugin
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class CustomEsmPlugin
    attr_reader :name, :import_name

    def initialize(name, import_name)
      @name = name
      @import_name = import_name
    end
  end
end
