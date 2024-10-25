# frozen_string_literal: true

require_relative 'ckeditor_bundle'
require_relative 'ckbox_bundle'

module CKEditor5::Rails
  module Cloud::Helpers
    def ckeditor5_cloud_assets(version, premium: false, translations: [], ckbox: nil)
      semver = Semver.new(version)

      bundle = ckeditor5_base_bundle(semver, translations)
      bundle << ckeditor5_premium_bundle(semver, translations) if premium
      bundle << Cloud::CKBoxBundle.new(ckbox[:version], ckbox[:theme] || 'lark') if ckbox

      Assets::AssetsBundleHtmlSerializer.new(bundle).to_html
    end

    def ckeditor5_base_bundle(version, translations)
      Cloud::CKEditorBundle.new(version, 'ckeditor5', translations: translations)
    end

    def ckeditor5_premium_bundle(version, translations)
      Cloud::CKEditorBundle.new(version, 'ckeditor5-premium-features', translations: translations)
    end
  end
end
