# frozen_string_literal: true

require 'active_support'
require 'terser'

module CKEditor5::Rails
  module Presets
    module Concerns
      module PluginMethods
        extend ActiveSupport::Concern

        class MissingInlinePluginError < StandardError; end
        class UnsupportedESModuleError < StandardError; end
        class InvalidPatchPluginError < ArgumentError; end
        class CompressionDisabledError < StandardError; end

        included do
          attr_reader :disallow_inline_plugin_compression
        end

        # Sets compression of inline plugin code. Make sure that it is called before setting the version
        # or adding plugins.
        # @example Disable compression
        #   compression(enabled: false)
        # @return [void]
        # @note This method is useful for debugging purposes, as it allows you to see the uncompressed code.
        def compression(enabled: false)
          @disallow_inline_plugin_compression = !enabled
        end

        # Check if compression is enabled
        # @return [Boolean] True if compression is enabled, false otherwise
        # @example Check if compression is enabled
        #  compression? # => true
        def compression?
          !@disallow_inline_plugin_compression
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
        # @param compress [Boolean] Whether to compress the code (default: true)
        # @example Define custom highlight plugin
        #   inline_plugin :MyCustomPlugin, <<~JS
        #     const { Plugin } = await import( 'ckeditor5' );
        #
        #     return class MyCustomPlugin extends Plugin {
        #       static get pluginName() {
        #         return 'MyCustomPlugin';
        #       }
        #
        #       init() {
        #         // Plugin initialization code
        #       }
        #     }
        #   JS
        def inline_plugin(name, code, compress: !@disallow_inline_plugin_compression)
          if code.match?(/export default/)
            raise UnsupportedESModuleError,
                  'Inline plugins must not use ES module syntax!' \
                  'Use async async imports instead!'
          end

          unless code.match?(/return class(\s+\w+)?\s+extends\s+Plugin/)
            raise MissingInlinePluginError,
                  'Plugin code must return a class that extends Plugin!'
          end

          plugin = Editor::PropsInlinePlugin.new(name, code, compress: compress)

          register_plugin(plugin)
        end

        # Registers a patch plugin that modifies CKEditor behavior for specific versions
        #
        # @param plugin [Editor::PropsPatchPlugin] Patch plugin instance to register
        # @raise [InvalidPatchPluginError] When provided plugin is not a PropsPatchPlugin
        # @return [Editor::PropsPatchPlugin, nil] Returns plugin if registered, nil if not applicable
        # @example Apply patch for specific CKEditor versions
        #   patch_plugin PropsPatchPlugin.new(:PatchName, code, min_version: '35.0.0', max_version: '36.0.0')
        def patch_plugin(plugin)
          unless plugin.is_a?(Editor::PropsPatchPlugin)
            raise InvalidPatchPluginError, 'Provided plugin must be a PropsPatchPlugin instance'
          end

          return unless !@version || plugin.applicable_for_version?(@version)

          register_plugin(plugin)
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

        # Compresses inline plugins to reduce bundle size
        #
        # @raise [CompressionDisabledError] If inline plugin compression is disabled
        # @example Compress inline plugins
        #   try_compress_inline_plugins!
        # @return [void]
        # @note This method is called automatically when defining a preset
        def try_compress_inline_plugins!
          raise CompressionDisabledError if @disallow_inline_plugin_compression

          config[:plugins].each do |plugin|
            next unless plugin.is_a?(Editor::PropsInlinePlugin)

            plugin.try_compress!
          end
        end

        private

        # Register a plugin in the editor configuration.
        #
        # @param plugin_obj [Editor::PropsBasePlugin] Plugin instance to register
        # @return [Editor::PropsBasePlugin] The registered plugin
        def register_plugin(plugin_obj)
          config[:plugins] ||= []
          config[:plugins] << plugin_obj
          plugin_obj
        end
      end
    end
  end
end
