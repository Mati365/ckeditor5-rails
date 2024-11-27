# frozen_string_literal: true

require_relative 'props_base_plugin'

module CKEditor5::Rails::Editor
  class PropsPlugin < PropsBasePlugin
    def initialize(name, premium: false, **js_import_meta_attrs)
      super(name)

      js_import_meta_attrs[:import_name] ||= if premium
                                               'ckeditor5-premium-features'
                                             else
                                               'ckeditor5'
                                             end

      @js_import_meta = ::CKEditor5::Rails::Assets::JSImportMeta.new(
        import_as: js_import_meta_attrs[:window_name] ? nil : name,
        **js_import_meta_attrs
      )
    end

    def to_h
      @js_import_meta.to_h.merge(type: :external)
    end
  end
end
