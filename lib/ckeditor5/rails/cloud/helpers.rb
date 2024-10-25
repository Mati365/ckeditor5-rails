# frozen_string_literal: true

require_relative 'ck_editor_base_bundle'

require_relative 'bundles/ck_editor'
require_relative 'bundles/ck_editor_premium_features'
require_relative 'bundles/ckbox'

module CKEditor5::Rails
  module Cloud::Helpers
    def ckeditor5_cloud_assets(version, premium: false, translations: [])
      semver = Semver.new(version)

      bundle = Cloud::CKEditor.new(semver, translations)
      bundle << Cloud::CKEditorPremiumFeatures.new(semver, translations) if premium

      AssetsBundleHtmlSerializer.new(bundle).to_html
    end
  end
end
