# frozen_string_literal: true

require_relative 'initializer_plugins'
require_relative 'initializer_builder'

module CKEditor5::Rails::Builder
  module Helpers
    def ckeditor5_editor(config:, type: :classic, id: nil, width: 'auto')
      initializer = InitializerBuilder.new(type, config, id: id)

      safe_join([
                  tag.div(style: "width: #{width};") do
                    tag.textarea(id: initializer.id)
                  end,
                  tag.script(initializer.to_js.html_safe, type: 'module')
                ])
    end

    def ckeditor5_window_plugin(name)
      CustomWindowPlugin.new(name)
    end

    def ckeditor5_esm_plugin(name, import_name)
      CustomEsmPlugin.new(name, import_name)
    end
  end
end
