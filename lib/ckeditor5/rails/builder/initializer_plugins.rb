# frozen_string_literal: true

module CKEditor5::Rails::Builder
  class InitializerPlugins
    attr_reader :plugins

    def initialize(plugins)
      @plugins = plugins || []
      @internal_handler = InternalPluginsHandler.new(@plugins)
      @window_handler = WindowPluginsHandler.new(@plugins)
      @esm_handler = EsmPluginsHandler.new(@plugins)
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
        *@internal_handler.internal_plugins,
        *@window_handler.window_plugins.map { |plugin| plugin[:name] },
        *@esm_handler.esm_plugins.map { |plugin| plugin[:import_name] }
      ]

      "[ #{plugins_list.join(', ')} ]".delete('"')
    end

    def generate_js_imports
      [
        @internal_handler.js_imports,
        @esm_handler.js_imports,
        @window_handler.js_imports
      ].join("\n")
    end
  end

  class InternalPluginsHandler
    attr_reader :internal_plugins

    def initialize(plugins)
      @internal_plugins = plugins.filter_map do |plugin|
        plugin.to_s if plugin.is_a?(String) || plugin.is_a?(Symbol)
      end
    end

    def js_imports
      return '' if internal_plugins.empty?

      "import { #{internal_plugins.join(', ')} } from 'ckeditor5';"
    end
  end

  class WindowPluginsHandler
    attr_reader :window_plugins

    def initialize(plugins)
      @window_plugins = plugins.filter_map do |plugin|
        if plugin.is_a?(CustomWindowPlugin)
          name = "__window_plugin_#{plugin.name.parameterize}"
          { code: "const #{name} = window['#{plugin.name}'];", name: name }
        end
      end
    end

    def js_imports
      window_plugins.map { |plugin| "const #{plugin[:name]} = window['#{plugin[:name]}'];" }.join("\n")
    end
  end

  class EsmPluginsHandler
    attr_reader :esm_plugins

    def initialize(plugins)
      @esm_plugins = plugins.filter_map do |plugin|
        { import_name: plugin.import_name, name: plugin.name } if plugin.is_a?(CustomEsmPlugin)
      end
    end

    def js_imports
      esm_plugins.map { |plugin| "import { #{plugin[:import_name]} } from '#{plugin[:name]}';" }.join("\n")
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
