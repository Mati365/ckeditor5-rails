# frozen_string_literal: true

require 'singleton'
require 'digest'

require_relative 'props_base_plugin'

module CKEditor5::Rails::Editor
  class PropsInlinePlugin < PropsBasePlugin
    attr_reader :code

    def initialize(name, code)
      super(name)

      @code = code
      validate_code!

      InlinePluginsSignaturesRegistry.instance.register(code)
    end

    def to_h
      {
        type: :inline,
        name: name,
        code: code
      }
    end

    private

    def validate_code!
      raise ArgumentError, 'Code must be a String' unless code.is_a?(String)

      return if code.include?('export default')

      raise ArgumentError,
            'Code must include `export default` that exports plugin definition!'
    end
  end

  class InlinePluginsSignaturesRegistry
    include Singleton

    def initialize
      @signatures = Set.new
    end

    def register(code)
      signature = generate_signature(code)
      @signatures.add(signature)
      signature
    end

    def to_a
      @signatures.to_a
    end

    private

    def generate_signature(code)
      Digest::SHA256.hexdigest(code)
    end
  end
end
