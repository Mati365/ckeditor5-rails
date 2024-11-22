# frozen_string_literal: true

module CKEditor5
  module Rails
    require_relative 'rails/version'
    require_relative 'rails/version_detector'
    require_relative 'rails/semver'
    require_relative 'rails/assets/assets_bundle'
    require_relative 'rails/assets/assets_bundle_html_serializer'
    require_relative 'rails/helpers'
    require_relative 'rails/engine'
  end
end
