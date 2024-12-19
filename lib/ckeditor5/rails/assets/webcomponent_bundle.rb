# frozen_string_literal: true

require 'singleton'
require 'terser'

require_relative '../editor/props_inline_plugin'

module CKEditor5::Rails
  module Assets
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
          content = File.read(File.join(WEBCOMPONENTS_PATH, file))

          if file == 'utils.mjs'
            inject_inline_code_signatures(content)
          else
            content
          end
        end.join("\n")
      end

      def inject_inline_code_signatures(content)
        json_signatures = Editor::InlinePluginsSignaturesRegistry.instance.to_a.to_json

        content.sub('__INLINE_CODE_SIGNATURES_PLACEHOLDER__', json_signatures)
      end

      def compress_source(code)
        Terser.new(compress: true, mangle: true).compile(code).html_safe
      end
    end
  end
end
