# frozen_string_literal: true

class CKEditor5::CDN::CKEditorBundle < CKEditor5::AssetsBundle
  include CKEditor5::CDN::CKUrlBuilder

  attr_reader :version, :package

  def initialize(version:, package:, translations: [])
    raise ArgumentError, 'version must be semver' unless version.is_a?(CKEditor5::Semver)
    raise ArgumentError, 'package must be a string' unless package.is_a?(String)
    raise ArgumentError, 'translations must be an array' unless translations.is_a?(Array)

    super

    @version = version
    @package = package
  end

  def scripts
    @scripts ||= [
      self.class.create_ck_cdn_url(package, "#{package}.umd.js", version),
      *translations.map do |lang|
        self.class.create_ck_cdn_url(package, "translations/#{lang}.umd.js", version)
      end
    ]
  end

  def stylesheets
    @stylesheets ||= [
      self.class.create_ck_cdn_url(package, "#{package}.css", version)
    ]
  end
end
