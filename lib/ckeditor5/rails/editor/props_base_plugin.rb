# frozen_string_literal: true

module CKEditor5::Rails
  module Editor
    class PropsBasePlugin
      include Concerns::Checksum

      attr_reader :name

      def initialize(name)
        @name = name
      end

      def to_h
        raise NotImplementedError, 'This method must be implemented in a subclass'
      end
    end
  end
end
