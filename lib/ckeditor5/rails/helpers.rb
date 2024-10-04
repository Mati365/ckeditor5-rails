# frozen_string_literal: true

require_relative 'cdn/helpers'
require_relative 'cloud/helpers'
require_relative 'editor/helpers'

module CKEditor5::Rails
  module Helpers
    include Cdn::Helpers
    include Cloud::Helpers
    include Editor::Helpers
  end
end
