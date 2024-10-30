# frozen_string_literal: true

require_relative 'url_generator'
require_relative 'ckeditor_bundle'
require_relative 'ckbox_bundle'

module CKEditor5::Rails
  module Cdn::Helpers
    def ckeditor5_cdn_assets(version:, cdn:, license_key: 'GPL', premium: false, translations: [], ckbox: nil)
      bundle = build_base_cdn_bundle(cdn, version, translations)
      bundle << build_premium_cdn_bundle(cdn, version, translations) if premium
      bundle << build_ckbox_cdn_bundle(ckbox) if ckbox

      @__ckeditor_context = {
        license_key: license_key,
        bundle: bundle
      }

      Assets::AssetsBundleHtmlSerializer.new(bundle).to_html
    end

    Cdn::UrlGenerator::CDN_THIRD_PARTY_GENERATORS.each_key do |key|
      define_method(:"ckeditor5_#{key.to_s.parameterize}_assets") do |**kwargs|
        ckeditor5_cdn_assets(**kwargs.merge(cdn: key))
      end
    end

    def ckeditor5_assets(**kwargs)
      if kwargs[:license_key] && kwargs[:license_key] != 'GPL'
        ckeditor5_cloud_assets(**kwargs)
      else
        ckeditor5_cdn_assets(**kwargs.merge(cdn: Engine.base.default_cdn))
      end
    end

    private

    def build_base_cdn_bundle(cdn, version, translations)
      Cdn::CKEditorBundle.new(
        Semver.new(version),
        'ckeditor5',
        translations: translations,
        cdn: cdn
      )
    end

    def build_premium_cdn_bundle(cdn, version, translations)
      Cdn::CKEditorBundle.new(
        Semver.new(version),
        'ckeditor5-premium-features',
        translations: translations,
        cdn: cdn
      )
    end

    def build_ckbox_cdn_bundle(ckbox)
      Cdn::CKBoxBundle.new(
        Semver.new(ckbox[:version]),
        theme: ckbox[:theme] || :lark,
        cdn: ckbox[:cdn] || :ckbox
      )
    end
  end
end
