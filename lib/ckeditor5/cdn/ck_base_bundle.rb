# frozen_string_literal: true

class CKEditor5::CDN::CKBaseBundle < CKEditor5::CDN::CKEditorBundle
  def initialize(version, translations: [])
    super(
      version: version,
      translations: translations,
      package: 'ckeditor5'
    )
  end

  def js_exports
    @js_exports ||= CKEditor5::AssetsBundle::JSExportsMeta.new(
      import_name: 'ckeditor5',
      window_name: 'CKEDITOR'
    )
  end
end
