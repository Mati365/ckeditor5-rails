# frozen_string_literal: true

class Ckeditor5::Cloud::CKEditorBaseBundle < Ckeditor5::AssetsBundle
  include Ckeditor5::CDN::CKUrlBuilder

  attr_reader :version, :package

  def initialize(version:, package:, translations: [])
    raise ArgumentError, 'version must be semver' unless version.is_a?(Ckeditor5::Semver)
    raise ArgumentError, 'package must be a string' unless package.is_a?(String)
    raise ArgumentError, 'translations must be an array' unless translations.is_a?(Array)

    super

    @version = version
    @package = package
  end

  def scripts
    @scripts ||= [
      self.class.create_ck_cloud_url(package, "#{package}.umd.js", version),
      *translations.map do |lang|
        self.class.create_ck_cloud_url(package, "translations/#{lang}.umd.js", version)
      end
    ]
  end

  def stylesheets
    @stylesheets ||= [
      self.class.create_ck_cloud_url(package, "#{package}.css", version)
    ]
  end
end
