# frozen_string_literal: true

module CKEditor5::Rails::Editor
  class PropsPlugin
    delegate :to_h, to: :import_meta

    def initialize(name, premium: false, import_name: nil)
      @name = name
      @premium = premium
      @import_name = import_name
      @import_name ||= premium ? 'ckeditor5-premium-features' : 'ckeditor5'
    end

    def self.normalize(plugin)
      case plugin
      when String, Symbol then new(plugin)
      when PropsPlugin then plugin
      else raise ArgumentError, "Invalid plugin: #{plugin}"
      end
    end

    private

    attr_reader :name, :premium, :import_name

    def import_meta
      ::CKEditor5::Rails::Assets::JSImportMeta.new(
        import_as: name,
        import_name: import_name
      )
    end
  end
end
