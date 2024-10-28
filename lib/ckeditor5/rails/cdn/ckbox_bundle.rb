# frozen_string_literal: true

module CKEditor5::Rails
  module Cdn
    class CKBoxBundle < Assets::AssetsBundle
      include Cdn::UrlGenerator

      attr_reader :cdn, :version, :theme

      def initialize(version, theme: :lark, cdn: :jsdelivr)
        raise ArgumentError, 'version must be semver' unless version.is_a?(Semver)
        raise ArgumentError, 'theme must be a string' unless theme.is_a?(String)

        super()

        @cdn = cdn
        @version = version
        @theme = theme
      end

      def scripts
        @scripts ||= [
          Assets::JSExportsMeta.new(
            create_cdn_url('ckbox', 'ckbox.js', version)
          )
        ]
      end

      def stylesheets
        @stylesheets ||= [
          create_cdn_url('ckbox', "styles/themes/#{theme}.css", version)
        ]
      end
    end
  end
end
