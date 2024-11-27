# frozen_string_literal: true

module CKEditor5::Rails::Editor
  class PropsBasePlugin
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_h
      raise NotImplementedError, 'Method #to_h must be implemented in a subclass'
    end

    def self.normalize(plugin, **kwargs)
      case plugin
      when String, Symbol then PropsPlugin.new(plugin, **kwargs)
      when PropsBasePlugin then plugin
      else raise ArgumentError, "Invalid plugin: #{plugin}"
      end
    end
  end
end
