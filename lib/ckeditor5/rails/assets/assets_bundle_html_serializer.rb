# frozen_string_literal: true

require 'action_view'

module CKEditor5::Rails::Assets
  class AssetsBundleHtmlSerializer
    include ActionView::Helpers::TagHelper

    attr_reader :bundle

    def initialize(bundle)
      raise TypeError, 'bundle must be an instance of AssetsBundle' unless bundle.is_a?(AssetsBundle)

      @bundle = bundle
    end

    def to_html
      safe_join([
                  preload_tags,
                  styles_tags,
                  window_scripts_tags,
                  scripts_import_map_tag
                ])
    end

    def self.url_resource_preload_type(url)
      case File.extname(url)
      when '.js' then 'script'
      when '.css' then 'style'
      else 'fetch'
      end
    end

    private

    def window_scripts_tags
      @window_scripts_tags ||= safe_join(bundle.scripts.select(&:window?).map do |script|
        tag.script(src: script.url, nonce: true, async: true)
      end)
    end

    def scripts_import_map_tag
      return @scripts_import_map_tag if defined?(@import_map_tag)

      import_map = bundle.scripts.each_with_object({}) do |script, memo|
        memo[script.import_name] = script.url if script.esm?
      end

      @import_map_tag = tag.script(
        { imports: import_map }.to_json.html_safe,
        type: 'importmap',
        nonce: true
      )
    end

    def styles_tags
      @styles_tags ||= safe_join(bundle.stylesheets.map do |url|
        tag.link(href: url, rel: 'stylesheet')
      end)
    end

    def preload_tags
      @preload_tags ||= safe_join(bundle.preloads.map do |url|
        tag.link(href: url, rel: 'preload', as: self.class.url_resource_preload_type(url))
      end)
    end
  end
end
