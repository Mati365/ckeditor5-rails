# frozen_string_literal: true

require_relative 'preset_builder'
require_relative 'preset_serializer'

module CKEditor5::Rails::Context
  module Helpers
    def ckeditor5_context(preset = nil, &block)
      preset ||= PresetBuilder.new
      context_props = PresetSerializer.new(preset)

      tag.public_send(:'ckeditor-context-component', **context_props.to_attributes, &block)
    end

    def ckeditor5_context_preset(&block)
      PresetBuilder.new(&block)
    end
  end
end
