# frozen_string_literal: true

class Ckeditor5::Cloud::Bundles::CKEditorPremiumFeatures < Ckeditor5::Cloud::CKEditorBaseBundle
  def initialize(version, translations: [])
    super(
      version: version,
      translations: translations,
      package: 'Ckeditor5-premium-features'
    )
  end

  def js_exports
    @js_exports ||= Ckeditor5::AssetsBundle::JSExportsMeta.new(
      import_name: 'Ckeditor5-premium-features',
      window_name: 'CKEDITOR_PREMIUM_FEATURES'
    )
  end
end
