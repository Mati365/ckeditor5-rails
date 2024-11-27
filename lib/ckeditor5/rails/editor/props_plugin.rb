# frozen_string_literal: true

require_relative 'props_base_plugin'

module CKEditor5::Rails::Editor
  class PropsPlugin < PropsBasePlugin
    attr_reader :js_import_meta

    delegate :to_h, to: :import_meta

    def initialize(name, premium: false, **js_import_meta)
      super(name)

      @js_import_meta = if js_import_meta.empty?
                          { import_name: premium ? 'ckeditor5-premium-features' : 'ckeditor5' }
                        else
                          js_import_meta
                        end
    end

    def to_h
      meta = ::CKEditor5::Rails::Assets::JSImportMeta.new(
        import_as: js_import_meta[:window_name] ? nil : name,
        **js_import_meta
      ).to_h

      meta.merge!({ type: :external })
      meta
    end
  end
end
