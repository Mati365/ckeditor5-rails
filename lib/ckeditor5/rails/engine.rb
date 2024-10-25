# frozen_string_literal: true

require 'rails/engine'

module CKEditor5::Rails
  class Engine < ::Rails::Engine
    config.ckeditor5 = ActiveSupport::OrderedOptions.new

    initializer 'helper' do
      ActiveSupport.on_load(:action_view) do
        include Helpers
      end
    end
  end
end
