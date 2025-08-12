# frozen_string_literal: true

require 'singleton'
require 'terser'

module CKEditor5::Rails::Assets
  class WebComponentBundle
    include ActionView::Helpers::TagHelper
    include Singleton

    NPM_PACKAGE_PATH = File.join(__dir__, '..', '..', '..', '..', 'npm_package').freeze

    def source
      @source ||= File.read(File.join(NPM_PACKAGE_PATH, 'dist/index.cjs')).html_safe
    end

    def to_html(nonce: nil)
      tag.script(source, type: 'module', nonce: nonce)
    end
  end
end
