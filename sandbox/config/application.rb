# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'propshaft'
require 'slim'
require 'simple_form'
require 'pry'
require 'pry-rails'
require 'importmap-rails'
require 'turbo-rails'
require 'stimulus-rails'

Bundler.require

module Sandbox
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.encoding = 'utf-8'
    config.autoload_lib(ignore: %w[assets tasks])
  end
end
