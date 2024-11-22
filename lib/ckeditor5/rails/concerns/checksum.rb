# frozen_string_literal: true

require 'digest'
require 'json'

module CKEditor5::Rails::Concerns
  module Checksum
    private

    def calculate_object_checksum(obj)
      json = JSON.generate(obj)
      Digest::SHA256.hexdigest(json)
    end
  end
end
