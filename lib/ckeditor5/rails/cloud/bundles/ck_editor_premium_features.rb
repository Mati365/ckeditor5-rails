# frozen_string_literal: true

module CKEditor5::Rails
  module Cloud
    class CKEditorPremiumFeatures < CKEditorBaseBundle
      def initialize(version, translations = [])
        super(
          version: version,
          translations: translations,
          import_name: 'ckeditor5-premium-features',
          window_name: 'CKEDITOR_PREMIUM_FEATURES'
        )
      end
    end
  end
end
