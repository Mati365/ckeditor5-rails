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

    def to_html(nonce: nil)
      tags = [
        WebComponentBundle.instance.to_html(nonce: nonce)
      ]

      unless lazy
        tags.prepend(
          preload_tags(nonce: nonce),
          styles_tags(nonce: nonce),
          window_scripts_tags(nonce: nonce)
        )
      end

      if importmap
        tags.prepend(
          AssetsImportMap.new(bundle).to_html(nonce: nonce)
        )
      end

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

    def window_scripts_tags(nonce: nil)
      scripts = bundle.scripts.map do |script|
        if script.window?
          tag.script(src: script.url, nonce: nonce, crossorigin: 'anonymous')
        end
      end.compact

      safe_join(scripts)
    end

    def styles_tags(nonce: nil)
      styles = bundle.stylesheets.map do |url|
        tag.link(href: url, nonce: nonce, rel: 'stylesheet', crossorigin: 'anonymous')
      end

      safe_join(styles)
    end

    def preload_tags(nonce: nil)
      preloads = bundle.preloads.map do |preload|
        if preload.is_a?(Hash) && preload[:as] && preload[:href]
          tag.link(
            **preload,
            nonce: nonce,
            crossorigin: 'anonymous'
          )
        else
          tag.link(
            href: preload,
            rel: 'preload',
            nonce: nonce,
            as: self.class.url_resource_preload_type(preload),
            crossorigin: 'anonymous'
          )
        end
      end

      safe_join(preloads)
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

    def to_html(nonce: nil)
      tag.script(
        to_json.html_safe,
        type: 'importmap',
        nonce: nonce
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
