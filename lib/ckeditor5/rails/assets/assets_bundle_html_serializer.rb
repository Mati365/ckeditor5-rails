# frozen_string_literal: true

require 'uri'
require 'action_view'

require_relative 'webcomponent_bundle'

module CKEditor5::Rails::Assets
  class AssetsBundleHtmlSerializer
    include ActionView::Helpers::TagHelper

    attr_reader :bundle, :importmap, :lazy

    def initialize(bundle, importmap: true, lazy: false)
      raise TypeError, 'bundle must be an instance of AssetsBundle' unless bundle.is_a?(AssetsBundle)

      @importmap = importmap
      @bundle = bundle
      @lazy = lazy
    end

    def to_html
      tags = [
        WebComponentBundle.instance.to_html
      ]

      tags.prepend(preload_tags, styles_tags, window_scripts_tags) unless lazy
      tags.prepend(AssetsImportMap.new(bundle).to_html) if importmap

      safe_join(tags)
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
      @window_scripts_tags ||= safe_join(bundle.scripts.filter_map do |script|
        tag.script(src: script.url, nonce: true, crossorigin: 'anonymous') if script.window?
      end)
    end

    def styles_tags
      @styles_tags ||= safe_join(bundle.stylesheets.map do |url|
        tag.link(href: url, rel: 'stylesheet', crossorigin: 'anonymous')
      end)
    end

    def preload_tags
      @preload_tags ||= safe_join(bundle.preloads.map do |preload|
        if preload.is_a?(Hash) && preload[:as] && preload[:href]
          tag.link(
            **preload,
            crossorigin: 'anonymous'
          )
        else
          tag.link(
            href: preload,
            rel: 'preload',
            as: self.class.url_resource_preload_type(preload),
            crossorigin: 'anonymous'
          )
        end
      end)
    end
  end

  class AssetsImportMap
    include ActionView::Helpers::TagHelper

    attr_reader :bundle

    def initialize(bundle)
      @bundle = bundle
    end

    def to_json(*_args)
      import_map = bundle.scripts.each_with_object({}) do |script, map|
        next if !script.esm? || looks_like_url?(script.import_name)

        map[script.import_name] = script.url
      end

      { imports: import_map }.to_json
    end

    def to_html
      tag.script(
        to_json.html_safe,
        type: 'importmap',
        nonce: true
      )
    end

    private

    def looks_like_url?(str)
      uri = URI.parse(str)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end
  end
end
