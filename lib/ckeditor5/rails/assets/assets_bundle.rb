# frozen_string_literal: true

require 'active_support/core_ext/module'
require 'uri'

module CKEditor5::Rails::Assets
  class AssetsBundle
    def initialize(scripts: nil, stylesheets: nil)
      @scripts = scripts
      @stylesheets = stylesheets
    end

    def scripts
      @scripts || []
    end

    def stylesheets
      @stylesheets || []
    end

    def empty?
      scripts.empty? && stylesheets.empty?
    end

    def translations_scripts
      scripts.select(&:translation?)
    end

    def preloads
      stylesheets + scripts.map(&:preloads)
    end

    def to_json(*_args)
      {
        scripts: unique_scripts(scripts).map(&:to_h),
        stylesheets: unique_stylesheets(stylesheets)
      }.to_json
    end

    def <<(other)
      raise TypeError, 'other must be an instance of AssetsBundle' unless other.is_a?(AssetsBundle)

      @scripts = unique_scripts(scripts + other.scripts)
      @stylesheets = unique_stylesheets(stylesheets + other.stylesheets)
    end

    private

    def unique_scripts(scripts_array)
      with_url, without_url = scripts_array.partition { |script| script.respond_to?(:url) && script.url }
      unique_with_url = with_url.uniq { |script| drop_version_from_url(script.url) }
      unique_with_url + without_url
    end

    def unique_stylesheets(stylesheets_array)
      stylesheets_array.uniq { |stylesheet| drop_version_from_url(stylesheet) }
    end

    def drop_version_from_url(url)
      url.to_s
         .gsub(%r{/v?\d+\.\d+\.\d+(-[a-z0-9.]+)?/}, '/')
         .gsub(%r{@\d+\.\d+\.\d+(-[a-z0-9.]+)?/?}, '')
    end
  end

  class JSUrlImportMeta
    attr_reader :url, :import_meta

    delegate :esm?, :window?, :import_name, :window_name, :import_as, to: :import_meta

    def initialize(url, translation: false, **import_options)
      @url = url
      @import_meta = JSImportMeta.new(**import_options)
      @translation = translation
    end

    def translation?
      @translation
    end

    def to_h
      import_meta.to_h.merge({
                               url: url,
                               translation: translation?
                             })
    end

    def preloads
      {
        as: 'script',
        rel: esm? ? 'modulepreload' : 'preload',
        href: url
      }
    end
  end

  class JSImportMeta
    attr_reader :import_as, :import_name, :window_name

    def initialize(import_as: nil, import_name: nil, window_name: nil)
      validate_arguments!(import_as, import_name, window_name)
      @import_as = import_as
      @import_name = import_name
      @window_name = window_name
    end

    def window?
      window_name.present?
    end

    def esm?
      import_name.present?
    end

    def to_h
      {
        import_as: import_as,
        import_name: import_name,
        window_name: window_name
      }.compact
    end

    private

    def validate_arguments!(import_as, import_name, window_name)
      if import_name.nil? && window_name.nil?
        raise ArgumentError,
              'import_name or window_name must be present'
      end

      raise ArgumentError, 'import_name required when import_as is present' if import_as && import_name.nil?
    end
  end
end
