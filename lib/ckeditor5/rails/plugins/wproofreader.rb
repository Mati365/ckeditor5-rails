# frozen_string_literal: true

require_relative '../editor/props_external_plugin'

module CKEditor5::Rails::Plugins
  class WProofreader < CKEditor5::Rails::Editor::PropsExternalPlugin
    DEFAULT_VERSION = '3.1.2'
    DEFAULT_CDN = 'https://cdn.jsdelivr.net/npm/@webspellchecker/wproofreader-ckeditor5'

    def initialize(version: nil, cdn: nil)
      cdn ||= DEFAULT_CDN
      version ||= DEFAULT_VERSION

      script_url = "#{cdn}@#{version}/dist/browser/index.js"
      style_url = "#{cdn}@#{version}/dist/browser/index.css"

      super(
        :WProofreader,
        script: script_url,
        import_as: 'WProofreader',
        stylesheets: [style_url],
      )
    end
  end
end
