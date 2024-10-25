# frozen_string_literal: true

require 'action_view'

module CKEditor5::Rails
  class AssetsBundleHtmlSerializer
    include ActionView::Helpers::TagHelper

    attr_reader :bundle

    def initialize(bundle)
      raise TypeError, 'bundle must be an instance of AssetsBundle' unless bundle.is_a?(AssetsBundle)

      @bundle = bundle
    end

    def to_html
      preload_tags + styles_tags + import_map_tag
    end

    def self.url_resource_preload_type(url)
      if url.end_with?('.js')
        'script'
      elsif url.end_with?('.css')
        'style'
      else
        'fetch'
      end
    end

    private

    # rubocop:disable Rails/OutputSafety

    def import_map_tag
      import_map = bundle.scripts.each_with_object({}) do |script, memo|
        memo[script.import_name] = script.url if script.esm?
      end

      tag.script import_map.to_json.html_safe, type: 'importmap', nonce: true
    end

    def styles_tags
      tags = bundle.stylesheets.map do |url|
        tag.link(href: url, rel: 'stylesheet')
      end

      safe_join(tags)
    end

    def preload_tags
      tags = bundle.preloads.map do |url|
        tag.link rel: 'preload', href: url, as: self.class.url_resource_preload_type(url)
      end

      safe_join(tags)
    end

    # rubocop:enable Rails/OutputSafety
  end
end
