# frozen_string_literal: true

require 'active_support'

module CKEditor5::Rails::Cdn
  module UrlGenerator
    extend ActiveSupport::Concern

    CDN_THIRD_PARTY_GENERATORS = {
      jsdelivr: ->(bundle, version, path) {
        base_url = "https://cdn.jsdelivr.net/npm/#{bundle}@#{version}/dist"

        if path.start_with?('translations/')
          "#{base_url}/#{path}"
        else
          "#{base_url}/browser/#{path}"
        end
      }
    }.freeze

    CDN_COMMERCIAL_GENERATORS = {
      cloud: ->(bundle, version, path) { "https://cdn.ckeditor.com/#{bundle}/#{version}/#{path}" },
      ckbox: ->(bundle, version, path) { "https://cdn.ckbox.io/#{bundle}/#{version}/#{path}" },
    }.freeze

    included do
      attr_reader :cdn
    end

    def create_cdn_url(bundle, version, path)
      generator = CDN_THIRD_PARTY_GENERATORS[cdn] || CDN_COMMERCIAL_GENERATORS[cdn]

      raise ArgumentError, "Unknown provider: #{cdn}" unless generator

      generator.call(bundle, version, path)
    end
  end
end
