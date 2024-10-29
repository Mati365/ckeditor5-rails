# frozen_string_literal: true

require_relative 'js/import_creator'
require_relative 'js/initializer_translations'
require_relative 'js/initializer_plugins'
require_relative 'js/initializer_builder'

module CKEditor5::Rails::Builder
  module Helpers
    def ckeditor5_editor(config:, type: :classic, id: nil, width: 'auto')
      unless defined?(@__ckeditor_context)
        raise 'CKEditor installation context is not defined. ' \
              'Ensure ckeditor5_assets (or any other assets initializer) is called in the head section.'
      end

      initializer = JS::InitializerBuilder.new(@__ckeditor_context, type, config, id: id)

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
