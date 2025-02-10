# frozen_string_literal: true

module CKEditor5
  module Rails
    class Semver
      SEMVER_PATTERN = /\A\d+\.\d+\.\d+\z/

      attr_reader :major, :minor, :patch

      include Comparable

      def initialize(version_string)
        if version_string.is_a?(Semver)
          @major = version_string.major
          @minor = version_string.minor
          @patch = version_string.patch
          return
        end

        validate!(version_string)
        @major, @minor, @patch = version_string.split('.').map(&:to_i)
      end

      def <=>(other)
        return nil unless other.is_a?(Semver)

        [major, minor, patch] <=> [other.major, other.minor, other.patch]
      end

      def safe_update?(other_version)
        other = self.class.new(other_version)

        return false if other.major != major
        return true if other.minor > minor
        return true if other.minor == minor && other.patch > patch

        false
      end

      def version
        "#{major}.#{minor}.#{patch}"
      end

      alias to_s :version

      private

      def validate!(version_string)
        return if version_string.is_a?(String) && version_string.match?(SEMVER_PATTERN)

        raise ArgumentError, 'invalid version format'
      end
    end
  end
end
