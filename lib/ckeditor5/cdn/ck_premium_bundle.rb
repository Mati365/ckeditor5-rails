# frozen_string_literal: true

class CKEditor5::CDN::CKPremiumBundle < CKEditor5::CDN::CKEditorBundle
  def initialize(version, translations: [])
    super(
      version: version,
      translations: translations,
      package: 'ckeditor5-premium-features'
    )
  end

  def js_exports
    @js_exports ||= CKEditor5::AssetsBundle::JSExportsMeta.new(
      import_name: 'ckeditor5-premium-features',
      window_name: 'CKEDITOR_PREMIUM_FEATURES'
    )
  end
end
