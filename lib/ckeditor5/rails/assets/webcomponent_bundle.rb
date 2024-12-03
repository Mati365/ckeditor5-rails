# frozen_string_literal: true

require 'singleton'

module CKEditor5::Rails::Assets
  class WebComponentBundle
    include ActionView::Helpers::TagHelper
    include Singleton

    WEBCOMPONENTS_PATH = File.join(__dir__, 'webcomponents')
    WEBCOMPONENTS_MODULES = [
      'utils.mjs',
      'components/editable.mjs',
      'components/ui-part.mjs',
      'components/editor.mjs',
      'components/context.mjs'
    ].freeze

    def source
      @source ||= WEBCOMPONENTS_MODULES.map do |file|
        File.read(File.join(WEBCOMPONENTS_PATH, file))
      end.join("\n").html_safe
    end

    def to_html
      @to_html ||= tag.script(source, type: 'module', nonce: true)
    end
  end
end
