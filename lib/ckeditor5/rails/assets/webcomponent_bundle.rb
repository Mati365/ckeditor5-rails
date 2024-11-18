# frozen_string_literal: true

module CKEditor5::Rails::Assets
  module WebComponentBundle
    WEBCOMPONENTS_PATH = File.join(__dir__, 'webcomponents')
    WEBCOMPONENTS_MODULES = [
      'utils.mjs',
      'components/editable.mjs',
      'components/ui-part.mjs',
      'components/editor.mjs',
      'components/context.mjs'
    ].freeze

    module_function

    def source
      @source ||= WEBCOMPONENTS_MODULES.map do |file|
        File.read(File.join(WEBCOMPONENTS_PATH, file))
      end.join("\n").html_safe
    end
  end
end
