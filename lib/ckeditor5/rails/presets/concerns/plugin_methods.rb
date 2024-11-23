# frozen_string_literal: true

module CKEditor5::Rails
  module Presets
    module Concerns
      module PluginMethods
        def inline_plugin(name, code)
          config[:plugins] << Editor::PropsInlinePlugin.new(name, code)
        end

        def plugin(name, **kwargs)
          plugin_obj = PluginsBuilder.create_plugin(name, **kwargs)
          config[:plugins] << plugin_obj
          plugin_obj
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
