# frozen_string_literal: true

module CKEditor5::Rails
  module Cdn
    class CKBoxBundle < Assets::AssetsBundle
      include Cdn::UrlGenerator

      attr_reader :cdn, :version, :theme, :translations

      def initialize(version, theme: :lark, cdn: Engine.default_preset.cdn, translations: [])
        super()

        @cdn = cdn
        @version = version
        @theme = theme
        @translations = translations

        validate!
      end

      def scripts
        @scripts ||= [
          Assets::JSExportsMeta.new(
            create_cdn_url('ckbox', version, 'ckbox.js'),
            *translations_js_exports_meta,
            window_name: 'CKBox'
          )
        ]
      end

      def stylesheets
        @stylesheets ||= [
          create_cdn_url('ckbox', version, "styles/themes/#{theme}.css")
        ]
      end

      private

      def validate!
        raise ArgumentError, 'version must be semver' unless version.is_a?(Semver)
        raise ArgumentError, 'translations must be an array' unless translations.is_a?(Array)

        return if theme.is_a?(String) || theme.is_a?(Symbol)

        raise ArgumentError,
              'theme must be a string or symbol'
      end

      def translations_js_exports_meta
        translations.map do |lang|
          url = create_cdn_url('ckbox', version, "translations/#{lang}.js")

          Assets::JSExportsMeta.new(url, window_name: 'CKBOX_TRANSLATIONS', translation: true)
        end
      end
    end
  end
end
