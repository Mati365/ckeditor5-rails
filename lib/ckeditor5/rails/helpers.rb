# frozen_string_literal: true

require_relative 'cdn/helpers'
require_relative 'cloud/helpers'
require_relative 'builder/helpers'

module CKEditor5::Rails
  module Helpers
    include Cdn::Helpers
    include Cloud::Helpers
    include Builder::Helpers
  end
end
