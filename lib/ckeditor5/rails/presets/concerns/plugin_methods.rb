# frozen_string_literal: true

module CKEditor5::Rails
  module Presets
    module Concerns
      module PluginMethods
        private

        def register_plugin(plugin_obj)
          config[:plugins] << plugin_obj
          plugin_obj
        end

        public

        def external_plugin(name, **kwargs)
          register_plugin(Editor::PropsExternalPlugin.new(name, **kwargs))
        end

        def inline_plugin(name, code)
          register_plugin(Editor::PropsInlinePlugin.new(name, code))
        end

        def plugin(name, **kwargs)
          premium(true) if kwargs[:premium] && respond_to?(:premium)
          register_plugin(PluginsBuilder.create_plugin(name, **kwargs))
        end

        def plugins(*names, **kwargs, &block)
          config[:plugins] ||= []

          names.each { |name| plugin(name, **kwargs) } unless names.empty?

          builder = PluginsBuilder.new(config[:plugins])
          builder.instance_eval(&block) if block_given?
          builder
        end
      end
    end
  end
end
