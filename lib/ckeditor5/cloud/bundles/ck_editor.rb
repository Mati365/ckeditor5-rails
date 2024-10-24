# frozen_string_literal: true

class Ckeditor5::Cloud::Bundles::CKEditor < Ckeditor5::Cloud::CKEditorBaseBundle
  def initialize(version, translations: [])
    super(
      version: version,
      translations: translations,
      package: 'Ckeditor5'
    )
  end

  def js_exports
    @js_exports ||= Ckeditor5::AssetsBundle::JSExportsMeta.new(
      import_name: 'Ckeditor5',
      window_name: 'CKEDITOR'
    )
  end
end
