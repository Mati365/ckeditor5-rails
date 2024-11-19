# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'slim'
require 'simple_form'

Bundler.require

module Sandbox
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.encoding = 'utf-8'
  end
end
