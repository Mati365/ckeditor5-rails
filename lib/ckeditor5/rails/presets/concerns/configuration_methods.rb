# frozen_string_literal: true

require 'active_support'

module CKEditor5::Rails
  module Presets
    module Concerns
      module ConfigurationMethods
        extend ActiveSupport::Concern

        included do
          attr_reader :config
        end

        def configure(key, value)
          config[key] = value
        end
      end
    end
  end
end
