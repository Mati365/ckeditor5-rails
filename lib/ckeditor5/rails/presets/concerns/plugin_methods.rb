# frozen_string_literal: true

require 'active_support'

module CKEditor5::Rails
  module Presets
    module Concerns
      module PluginMethods
        extend ActiveSupport::Concern

        class DisallowedInlinePlugin < ArgumentError; end

        included do
          attr_reader :disallow_inline_plugins
        end

        # Registers an external plugin loaded from a URL
        #
        # @param name [Symbol] Plugin name
        # @param kwargs [Hash] Plugin options like :script, :import_as, :window_name, :stylesheets
        # @example Load plugin from URL
        #   external_plugin :MyPlugin, script: 'https://example.com/plugin.js'
        # @example Load with import alias
        #   external_plugin :MyPlugin,
        #     script: 'https://example.com/plugin.js',
        #     import_as: 'Plugin'
        def external_plugin(name, **kwargs)
          register_plugin(Editor::PropsExternalPlugin.new(name, **kwargs))
        end

        # Registers an inline plugin with raw JavaScript code
        #
        # @param name [Symbol] Plugin name
        # @param code [String] JavaScript code defining the plugin
        # @example Define custom highlight plugin
        #   inline_plugin :MyCustomPlugin, <<~JS
        #     import { Plugin } from 'ckeditor5';
        #
        #     export default class MyCustomPlugin extends Plugin {
        #       static get pluginName() {
        #         return 'MyCustomPlugin';
        #       }
        #
        #       init() {
        #         // Plugin initialization code
        #       }
        #     }
        #   JS
        def inline_plugin(name, code)
          register_plugin(Editor::PropsInlinePlugin.new(name, code))
        end

        # Register a single plugin by name
        #
        # @param name [Symbol, Editor::PropsBasePlugin] Plugin name or instance
        # @param kwargs [Hash] Plugin configuration options
        # @example Register standard plugin
        #   plugin :Bold
        # @example Register premium plugin
        #   plugin :RealTimeCollaboration, premium: true
        # @example Register custom plugin
        #   plugin :MyPlugin, import_name: 'my-custom-plugin'
        def plugin(name, **kwargs)
          premium(true) if kwargs[:premium] && respond_to?(:premium)
          register_plugin(PluginsBuilder.create_plugin(name, **kwargs))
        end

        # Register multiple plugins and configure plugin settings
        #
        # @param names [Array<Symbol>] Plugin names to register
        # @param kwargs [Hash] Shared plugin configuration
        # @example Register multiple plugins
        #   plugins :Bold, :Italic, :Underline
        # @example Configure plugins with block
        #   plugins do
        #     remove :Heading
        #     append :SelectAll, :RemoveFormat
        #     prepend :SourceEditing
        #   end
        def plugins(*names, **kwargs, &block)
          config[:plugins] ||= []

          names.each { |name| plugin(name, **kwargs) } unless names.empty?

          builder = PluginsBuilder.new(config[:plugins])
          builder.instance_eval(&block) if block_given?
          builder
        end

        private

        def looks_like_inline_plugin?(plugin)
          plugin.to_h[:type] == :inline
        end

        # Register a plugin in the editor configuration.
        #
        # It will raise an error if inline plugins are not allowed and the plugin is an inline plugin.
        # Most likely, this is being thrown when you use inline_plugin definition in a place where
        # it's not allowed (e.g. in a preset definition placed in controller).
        #
        # @param plugin_obj [Editor::PropsBasePlugin] Plugin instance to register
        # @return [Editor::PropsBasePlugin] The registered plugin
        def register_plugin(plugin_obj)
          if disallow_inline_plugins && looks_like_inline_plugin?(plugin_obj)
            raise DisallowedInlinePlugin, 'Inline plugins are not allowed here.'
          end

          config[:plugins] << plugin_obj
          plugin_obj
        end
      end
    end
  end
end
