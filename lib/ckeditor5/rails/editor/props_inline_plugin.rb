# frozen_string_literal: true

module CKEditor5::Rails::Editor
  class PropsInlinePlugin
    def initialize(name, code)
      @name = name
      @code = code
      validate_code!
    end

    def to_h
      {
        type: :inline,
        name: name,
        code: code
      }
    end

    private

    attr_reader :name, :code

    def validate_code!
      raise ArgumentError, 'Code must be a String' unless code.is_a?(String)

      return if code.include?('export default')

      raise ArgumentError,
            'Code must include `export default` that exports plugin definition!'
    end
  end
end
