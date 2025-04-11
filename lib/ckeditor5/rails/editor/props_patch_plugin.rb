# frozen_string_literal: true

require_relative '../semver'
require_relative 'props_inline_plugin'

module CKEditor5::Rails::Editor
  class PropsPatchPlugin < PropsInlinePlugin
    attr_reader :min_version, :max_version

    def initialize(name, code, min_version: nil, max_version: nil, compress: true)
      super(name, code, compress: compress)

      @min_version = min_version && CKEditor5::Rails::Semver.new(min_version)
      @max_version = max_version && CKEditor5::Rails::Semver.new(max_version)
    end

    def self.applicable_for_version?(editor_version, min_version: nil, max_version: nil)
      return true if min_version.nil? && max_version.nil?

      current_version = CKEditor5::Rails::Semver.new(editor_version)

      min_check = min_version.nil? || current_version >= CKEditor5::Rails::Semver.new(min_version)
      max_check = max_version.nil? || current_version <= CKEditor5::Rails::Semver.new(max_version)

      min_check && max_check
    end

    def applicable_for_version?(editor_version)
      self.class.applicable_for_version?(
        editor_version,
        min_version: @min_version&.to_s,
        max_version: @max_version&.to_s
      )
    end
  end
end
