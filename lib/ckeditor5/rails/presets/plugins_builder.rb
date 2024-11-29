# frozen_string_literal: true

module CKEditor5::Rails
  class Presets::PluginsBuilder
    attr_reader :items

    def initialize(plugins)
      @items = plugins
    end

    # Creates a plugin instance from a name or returns the plugin if it's already a PropsBasePlugin
    #
    # @param name [Symbol, Editor::PropsBasePlugin] Plugin name or instance
    # @param kwargs [Hash] Additional plugin configuration
    # @return [Editor::PropsBasePlugin] Plugin instance
    def self.create_plugin(name, **kwargs)
      if name.is_a?(Editor::PropsBasePlugin)
        name
      else
        Editor::PropsPlugin.new(name, **kwargs)
      end
    end

    # Removes specified plugins from the editor configuration
    #
    # @param names [Array<Symbol>] Names of plugins to remove
    # @example Remove plugins from configuration
    #   plugins do
    #     remove :Heading, :Link
    #   end
    def remove(*names)
      names.each { |name| items.delete_if { |plugin| plugin.name == name } }
    end

    # Prepends plugins to the beginning of the plugins list or before a specific plugin
    #
    # @param names [Array<Symbol>] Names of plugins to prepend
    # @param before [Symbol, nil] Optional plugin name before which to insert new plugins
    # @param kwargs [Hash] Additional plugin configuration
    # @raise [ArgumentError] When the specified 'before' plugin is not found
    # @example Prepend plugins to configuration
    #   plugins do
    #     prepend :Bold, :Italic, before: :Link
    #   end
    def prepend(*names, before: nil, **kwargs)
      new_plugins = names.map { |name| self.class.create_plugin(name, **kwargs) }

      if before
        index = items.index { |p| p.name == before }
        raise ArgumentError, "Plugin '#{before}' not found" unless index

        items.insert(index, *new_plugins)
      else
        items.insert(0, *new_plugins)
      end
    end

    # Appends plugins to the end of the plugins list or after a specific plugin
    #
    # @param names [Array<Symbol>] Names of plugins to append
    # @param after [Symbol, nil] Optional plugin name after which to insert new plugins
    # @param kwargs [Hash] Additional plugin configuration
    # @raise [ArgumentError] When the specified 'after' plugin is not found
    # @example Append plugins to configuration
    #   plugins do
    #     append :Bold, :Italic, after: :Link
    #   end
    def append(*names, after: nil, **kwargs)
      new_plugins = names.map { |name| self.class.create_plugin(name, **kwargs) }

      if after
        index = items.index { |p| p.name == after }
        raise ArgumentError, "Plugin '#{after}' not found" unless index

        items.insert(index + 1, *new_plugins)
      else
        items.push(*new_plugins)
      end
    end
  end
end
