# frozen_string_literal: true

require 'singleton'
require 'terser'

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
      @source ||= compress_source(raw_source)
    end

    def to_html
      @to_html ||= tag.script(source, type: 'module', nonce: true)
    end

    private

    def raw_source
      @raw_source ||= WEBCOMPONENTS_MODULES.map do |file|
        File.read(File.join(WEBCOMPONENTS_PATH, file))
      end.join("\n")
    end

    def compress_source(code)
      Terser.new(compress: true, mangle: true).compile(code).html_safe
    end
  end
end
