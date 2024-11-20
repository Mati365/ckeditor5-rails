# frozen_string_literal: true

require_relative 'cdn/helpers'
require_relative 'editor/helpers'
require_relative 'context/helpers'

module CKEditor5::Rails
  module Helpers
    include Cdn::Helpers
    include Editor::Helpers::Config
    include Editor::Helpers::Editor
    include Context::Helpers
  end
end
