# frozen_string_literal: true

module CKEditor5::Rails
  module Cdn::Concerns
    module BundleBuilder
      def create_preset_bundle(preset)
        cdn = preset.cdn
        version = preset.version
        translations = preset.translations
        ckbox = preset.ckbox
        premium = preset.premium

        bundle = build_base_cdn_bundle(cdn, version, translations)
        bundle << build_premium_cdn_bundle(cdn, version, translations) if premium
        bundle << build_ckbox_cdn_bundle(ckbox) if ckbox
        bundle << build_plugins_cdn_bundle(preset.plugins.items)
        bundle
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

      def build_plugins_cdn_bundle(plugins)
        plugins.each_with_object(Assets::AssetsBundle.new(scripts: [], stylesheets: [])) do |plugin, bundle|
          bundle << plugin.preload_assets_bundle if plugin.preload_assets_bundle.present?
        end
      end
    end
  end
end
