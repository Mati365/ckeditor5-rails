# frozen_string_literal: true

module CKEditor5::Rails::Cloud
  class Bundles::CKEditorPremiumFeatures < CKEditorBaseBundle
    def initialize(version, translations: [])
      super(
        version: version,
        translations: translations,
        package: 'CKEditor5-premium-features'
      )
    end

    def js_exports
      @js_exports ||= CKEditor5::AssetsBundle::JSExportsMeta.new(
        import_name: 'CKEditor5-premium-features',
        window_name: 'CKEDITOR_PREMIUM_FEATURES'
      )
    end
  end
end
