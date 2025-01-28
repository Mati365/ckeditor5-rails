# frozen_string_literal: true

require_relative 'props_base_plugin'

module CKEditor5::Rails::Editor
  class PropsPlugin < PropsBasePlugin
    def initialize(name, premium: false, **js_import_meta_attrs)
      super(name)

      if js_import_meta_attrs[:window_name]
        @js_import_meta = ::CKEditor5::Rails::Assets::JSImportMeta.new(**js_import_meta_attrs)
      else
        js_import_meta_attrs[:import_name] ||= if premium
                                                 'ckeditor5-premium-features'
                                               else
                                                 'ckeditor5'
                                               end

        @js_import_meta = ::CKEditor5::Rails::Assets::JSImportMeta.new(
          import_as: name,
          **js_import_meta_attrs
        )
      end
    end

    # Compress a little bit default plugins to make output smaller
    def to_h
      if @js_import_meta.import_name == 'ckeditor5'
        @js_import_meta.import_as.to_s
      else
        @js_import_meta.to_h
      end
    end
  end
end
