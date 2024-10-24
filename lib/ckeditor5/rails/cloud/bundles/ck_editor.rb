# frozen_string_literal: true

module CKEditor5::Rails::Cloud
  class Bundles::CKEditor < CKEditorBaseBundle
    def initialize(version, translations: [])
      super(
        version: version,
        translations: translations,
        package: 'CKEditor5'
      )
    end

    def js_exports
      @js_exports ||= CKEditor5::AssetsBundle::JSExportsMeta.new(
        import_name: 'CKEditor5',
        window_name: 'CKEDITOR'
      )
    end
  end
end
