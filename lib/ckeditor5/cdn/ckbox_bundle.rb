# frozen_string_literal: true

class CKEditor5::CDN::CKBoxBundle < CKEditor5::AssetsBundle
  attr_reader :version, :theme

  def initialize(version, theme: 'lark')
    raise ArgumentError, 'version must be semver' unless version.is_a?(CKEditor5::Semver)
    raise ArgumentError, 'theme must be a string' unless theme.is_a?(String)

    super

    @version = version
    @theme = theme
  end

  def scripts
    @scripts ||= [
      self.class.create_ckbox_cdn_url('ckbox', 'ckbox.js', version)
    ]
  end

  def stylesheets
    @stylesheets ||= [
      self.class.create_ckbox_cdn_url('ckbox', "styles/themes/#{theme}.css", version)
    ]
  end

  def self.create_ckbox_cdn_url(bundle, file, version)
    "https://cdn.ckbox.io/#{bundle}/#{version}/#{file}"
  end
end
