# frozen_string_literal: true

require 'rails/engine'

module Ckeditor5
  class Engine < ::Rails::Engine
    config.autoload_paths = %W[
      #{root}/lib
    ]

    config.eager_load_paths = %W[
      #{root}/app/components
    ]

    def self.root
      Pathname(File.expand_path(File.join('..', '..', '..'), __dir__))
    end
  end
end
