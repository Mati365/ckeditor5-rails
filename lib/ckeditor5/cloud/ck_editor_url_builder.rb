# frozen_string_literal: true

require 'active_support'
require 'active_support/concern'

module Ckeditor5::Cloud::CKEditorUrlBuilder
  extend ActiveSupport::Concern

  class_methods do
    def create_ck_cloud_url(bundle, file, version)
      "https://cdn.ckeditor.com/#{bundle}/#{version}/#{file}"
    end
  end
end
