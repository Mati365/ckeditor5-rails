# frozen_string_literal: true

module CKEditor5::Rails
  class Presets::PluginsBuilder
    attr_reader :items

    def initialize(plugins)
      @items = plugins
    end

    def self.create_plugin(name, **kwargs)
      if name.is_a?(Editor::PropsBasePlugin)
        name
      else
        Editor::PropsPlugin.new(name, **kwargs)
      end
    end

    def remove(*names)
      names.each { |name| items.delete_if { |plugin| plugin.name == name } }
    end

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
