# frozen_string_literal: true

module CKEditor5::Rails
  module Cdn
    class CKEditorBundle < Assets::AssetsBundle
      include Cdn::UrlGenerator

      attr_reader :version, :translations, :import_name

      def initialize(version, import_name, cdn: Engine.default_preset.cdn, translations: [])
        raise ArgumentError, 'version must be semver' unless version.is_a?(Semver)
        raise ArgumentError, 'import_name must be a string' unless import_name.is_a?(String)
        raise ArgumentError, 'translations must be an array' unless translations.is_a?(Array)

        super()

        @cdn = cdn
        @version = version
        @import_name = import_name
        @translations = translations
      end

      def scripts
        @scripts ||= [
          js_url_imports,
          *translations_js_url_imports
        ]
      end

      def stylesheets
        @stylesheets ||= [
          create_cdn_url(import_name, version, "#{import_name}.css")
        ]
      end

      private

      def js_url_imports
        Assets::JSUrlImportMeta.new(
          create_cdn_url(import_name, version, "#{import_name}.js"),
          import_name: import_name
        )
      end

      def translations_js_url_imports
        translations.map do |lang|
          next if lang == :en

          url = create_cdn_url(import_name, version, "translations/#{lang}.js")

          Assets::JSUrlImportMeta.new(
            url,
            import_name: "#{import_name}/translations/#{lang}.js",
            translation: true
          )
        end.compact
      end
    end
  end
end
