# frozen_string_literal: true

module CKEditor5::Rails
  module Cloud
    class CKEditorBaseBundle < AssetsBundle
      attr_reader :version, :translations, :import_name, :window_name

      def initialize(version:, import_name:, window_name:, translations: [])
        raise ArgumentError, 'version must be semver' unless version.is_a?(Semver)
        raise ArgumentError, 'import_name must be a string' unless import_name.is_a?(String)
        raise ArgumentError, 'window_name must be a string' unless window_name.is_a?(String)
        raise ArgumentError, 'translations must be an array' unless translations.is_a?(Array)

        super()

        @version = version
        @import_name = import_name
        @window_name = window_name
        @translations = translations
      end

      def scripts
        @scripts ||= [
          js_exports_meta,
          *translations_js_exports_meta
        ]
      end

      def stylesheets
        @stylesheets ||= [
          create_ck_cloud_url("#{import_name}.css")
        ]
      end

      private

      def js_exports_meta
        JSExportsMeta.new(
          create_ck_cloud_url("#{import_name}.umd.js"),
          import_name: import_name,
          window_name: window_name
        )
      end

      def translations_js_exports_meta
        translations.map do |lang|
          url = create_ck_cloud_url("translations/#{lang}.umd.js")

          JSExportsMeta.new(url, import_name: "#{import_name}/translations/#{lang}")
        end
      end

      def create_ck_cloud_url(file)
        "https://cdn.ckeditor.com/#{import_name}/#{version}/#{file}"
      end
    end
  end
end
