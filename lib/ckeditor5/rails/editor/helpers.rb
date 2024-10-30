# frozen_string_literal: true

require_relative 'props'

module CKEditor5::Rails::Editor
  module Helpers
    def ckeditor5_editor(config:, type: :classic, **html_attributes)
      unless defined?(@__ckeditor_context)
        raise 'CKEditor installation context is not defined. ' \
              'Ensure ckeditor5_assets (or any other assets initializer) is called in the head section.'
      end

      props = Props.new(@__ckeditor_context, type, config)

      tag.send('ckeditor-component', **props.to_attributes, **html_attributes)
    end
  end
end
