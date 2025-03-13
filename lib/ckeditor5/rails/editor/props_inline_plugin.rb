# frozen_string_literal: true

require_relative 'props_base_plugin'

module CKEditor5::Rails::Editor
  class PropsInlinePlugin < PropsBasePlugin
    attr_reader :code

    def initialize(name, code)
      super(name)

      raise ArgumentError, 'Code must be a String' unless code.is_a?(String)

      @code = "(async () => { #{code} })()"
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
      code = <<~JS
        window.addEventListener('ckeditor:request-cjs-plugin:#{@plugin.name}', () => {
          try {
            window['#{@plugin.name}'] = #{@plugin.code};
          } catch(e) {
            console.error('Error initializing CKEditor plugin #{@plugin.name}:', e);
          }
        }, { once: true });
      JS

      tag.script(code.html_safe, nonce: nonce)
    end
  end
end
