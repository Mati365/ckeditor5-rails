# frozen_string_literal: true

module CKEditor5::Rails::Builder
  class InitializerPlugins
    attr_reader :plugins

    def initialize(plugins)
      @plugins = plugins || []
    end

    def js_config_plugins
      @js_config_plugins ||= generate_js_config_plugins
    end

    def js_imports
      @js_imports ||= generate_js_imports
    end

    private

    def generate_js_config_plugins
      plugins_list = [
        *internal_plugins,
        *window_plugins.map { |plugin| plugin[:name] },
        *esm_plugins.map { |plugin| plugin[:import_name] }
      ]

      "[ #{plugins_list.join(', ')} ]".delete('"')
    end

    def generate_js_imports
      [
        internal_plugins_import,
        esm_plugins_imports,
        window_plugins_imports
      ].join("\n")
    end

    def internal_plugins_import
      return '' if internal_plugins.empty?

      "import { #{internal_plugins.join(', ')} } from 'ckeditor5';"
    end

    def esm_plugins_imports
      esm_plugins.map { |plugin| "import { #{plugin[:import_name]} } from '#{plugin[:name]}';" }.join("\n")
    end

    def window_plugins_imports
      window_plugins.map { |plugin| "const #{plugin[:name]} = window['#{plugin[:name]}'];" }.join("\n")
    end

    def internal_plugins
      @internal_plugins ||= plugins.filter_map do |plugin|
        plugin.to_s if plugin.is_a?(String) || plugin.is_a?(Symbol)
      end
    end

    def window_plugins
      @window_plugins ||= plugins.filter_map do |plugin|
        if plugin.is_a?(CustomWindowPlugin)
          name = "__window_plugin_#{plugin.name.parameterize}"
          { code: "const #{name} = window['#{plugin.name}'];", name: name }
        end
      end
    end

    def esm_plugins
      @esm_plugins ||= plugins.filter_map do |plugin|
        { import_name: plugin.import_name, name: plugin.name } if plugin.is_a?(CustomEsmPlugin)
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
