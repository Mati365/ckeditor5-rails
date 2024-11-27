# frozen_string_literal: true

require_relative 'props_base_plugin'

module CKEditor5::Rails::Editor
  class PropsExternalPlugin < PropsBasePlugin
    attr_reader :stylesheets, :js_import_meta

    def initialize(name, script:, import_as: nil, window_name: nil, stylesheets: [])
      super(name)

      @stylesheets = stylesheets
      @js_import_meta = CKEditor5::Rails::Assets::JSUrlImportMeta.new(
        script,
        import_name: script,
        import_as: import_as,
        window_name: window_name
      )
    end

    def preload_assets_urls
      @stylesheets + [@js_import_meta.url]
    end

    def to_h
      @js_import_meta.to_h.merge(
        type: :external,
        stylesheets: @stylesheets
      )
    end
  end
end
