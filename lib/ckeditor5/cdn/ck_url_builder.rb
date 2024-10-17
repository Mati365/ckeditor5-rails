# frozen_string_literal: true

require 'active_support/concern'

module CKEditor5::CDN::CKUrlBuilder
  extend ActiveSupport::Concern

  class_methods do
    def create_ck_cdn_url(bundle, file, version)
      "https://cdn.ckeditor.com/#{bundle}/#{version}/#{file}"
    end
  end
end
