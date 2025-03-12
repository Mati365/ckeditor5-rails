# frozen_string_literal: true

require_relative 'props_base_plugin'

module CKEditor5::Rails::Editor
  class PropsInlinePlugin < PropsBasePlugin
    attr_reader :code

    def initialize(name, code)
      super(name)

      raise ArgumentError, 'Code must be a String' unless code.is_a?(String)

      @code = "(async () => { #{code.html_safe} })()"
    end

    def compress!
      @code = Terser.new(compress: false, mangle: true).compile(@code)
    end

    def to_h
      {
        window_name: name
      }
    end
  end

  class InlinePluginWindowInitializer
    include ActionView::Helpers::TagHelper

    def initialize(plugin)
      @plugin = plugin
    end

    def to_html(nonce: nil)
      code = wrap_with_handlers(@plugin.code)

      tag.script(code.html_safe, nonce: nonce)
    end

    private

    def wrap_with_handlers(code)
      <<~JS
        window.addEventListener('ckeditor:request-cjs-plugin:#{@plugin.name}', () => {
          window['#{@plugin.name}'] = #{code.html_safe};
        }, { once: true });
      JS
    end
  end
end
