# frozen_string_literal: true

require 'active_support'

module CKEditor5::Rails::Cdn
  module UrlGenerator
    extend ActiveSupport::Concern

    CDN_THIRD_PARTY_GENERATORS = {
      jsdelivr: lambda { |bundle, version, path|
        base_url = "https://cdn.jsdelivr.net/npm/#{bundle}@#{version}/dist"
        "#{base_url}/#{path.start_with?('translations/') ? '' : 'browser/'}#{path}"
      },

      unpkg: lambda { |bundle, version, path|
        base_url = "https://unpkg.com/#{bundle}@#{version}/dist"
        "#{base_url}/#{path.start_with?('translations/') ? '' : 'browser/'}#{path}"
      }
    }.freeze

    CDN_COMMERCIAL_GENERATORS = {
      cloud: lambda { |bundle, version, path|
        "https://cdn.ckeditor.com/#{bundle}/#{version}/#{path}"
      },

      ckbox: lambda { |bundle, version, path|
        "https://cdn.ckbox.io/#{bundle}/#{version}/#{path}"
      }
    }.freeze

    included do
      attr_reader :cdn
    end

    def create_cdn_url(bundle, version, path)
      executor = CDN_THIRD_PARTY_GENERATORS[cdn] || CDN_COMMERCIAL_GENERATORS[cdn] || cdn

      raise ArgumentError, "Unknown provider: #{cdn}" if executor.blank? || !executor.respond_to?(:call)

      executor.call(bundle, version, path)
    end
  end
end
