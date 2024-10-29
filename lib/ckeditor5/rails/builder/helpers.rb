# frozen_string_literal: true

require_relative 'js_builder'

require_relative 'initializer_translations'
require_relative 'initializer_plugins'
require_relative 'initializer_builder'

module CKEditor5::Rails::Builder
  module Helpers
    def ckeditor5_editor(config:, type: :classic, id: nil, width: 'auto')
      raise 'CKEditor installation info is not defined' unless defined?(@__ckeditor_installation_info)

      bundle = @__ckeditor_installation_info[:bundle]
      initializer = InitializerBuilder.new(bundle, type, config, id: id)

      safe_join([
                  tag.div(style: "width: #{width};") do
                    tag.textarea(id: initializer.id)
                  end,
                  tag.script(initializer.to_js.html_safe, type: 'module', async: true)
                ])
    end

    def ckeditor5_window_plugin(name)
      CustomWindowPlugin.new(name)
    end

    def ckeditor5_esm_plugin(name, import_name)
      EsmPlugin.new(name, import_name)
    end

    def ckeditor5_premium_plugin(name)
      "premium:#{name}"
    end
  end
end
