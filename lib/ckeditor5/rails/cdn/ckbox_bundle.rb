# frozen_string_literal: true

module CKEditor5::Rails
  module Cdn
    class CKBoxBundle < Assets::AssetsBundle
      include Cdn::UrlGenerator

      attr_reader :cdn, :version, :theme, :translations

      def initialize(version, theme: :lark, cdn: Engine.default_preset.cdn, translations: [])
        raise ArgumentError, 'version must be semver' unless version.is_a?(Semver)
        raise ArgumentError, 'theme must be a string' unless theme.is_a?(String)
        raise ArgumentError, 'translations must be an array' unless translations.is_a?(Array)

        super()

        @cdn = cdn
        @version = version
        @theme = theme
        @translations = translations
      end

      def scripts
        @scripts ||= [
          Assets::JSExportsMeta.new(
            create_cdn_url('ckbox', 'ckbox.js', version),
            *translations_js_exports_meta
          )
        ]
      end

      def stylesheets
        @stylesheets ||= [
          create_cdn_url('ckbox', "styles/themes/#{theme}.css", version)
        ]
      end

      private

      def translations_js_exports_meta
        translations.map do |lang|
          url = create_cdn_url('ckbox', "translations/#{lang}.js", version)

          Assets::JSExportsMeta.new(url, window_name: 'CKBOX_TRANSLATIONS', translation: true)
        end
      end
    end
  end
end
