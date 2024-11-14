# frozen_string_literal: true

require_relative 'props'

module CKEditor5::Rails::Context
  module Helpers
    def ckeditor5_context(**config, &block)
      context_props = Props.new(config)

      tag.send(:'ckeditor-context-component', **context_props.to_attributes, &block)
    end
  end
end
