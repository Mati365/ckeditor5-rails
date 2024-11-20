# frozen_string_literal: true

class CKEditor5::Rails::Semver
  attr_reader :version

  alias to_s :version

  def initialize(version)
    @version = version.to_s
    validate!
  end

  private

  def validate!
    raise ArgumentError, 'invalid version format' unless version.match?(/\A\d+\.\d+\.\d+\z/)
  end
end
