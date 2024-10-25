# frozen_string_literal: true

require_relative 'initializer_builder'

module CKEditor5::Rails::Builder
  module Helpers
    def ckeditor5_editor(config:)
      initializer = InitializerBuilder.new(config)

      safe_join([
                  tag.div(id: initializer.id),
                  tag.script(initializer.to_js.html_safe, type: 'module')
                ])
    end
  end
end
