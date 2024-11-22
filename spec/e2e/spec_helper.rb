# frozen_string_literal: true

require 'capybara'
require 'capybara/rspec'
require 'capybara/cuprite'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../sandbox/config/environment', __dir__)

require 'capybara/rails'

Capybara.app = Rails.application

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    headless: ENV['HEADLESS'] == 'true',
    browser_options: {
      'no-sandbox': nil,
      'disable-gpu': nil,
      'enable-logging': nil
    },
    process_timeout: 20,
    timeout: 20,
    inspector: true
  )
end

Capybara.server = :webrick
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite

# Add eventually helper for async operations
def eventually(timeout: 5, delay: 0.1)
  deadline = Time.zone.now + timeout
  loop do
    yield
    break
  rescue RSpec::Expectations::ExpectationNotMetError, StandardError => e
    raise e if Time.zone.now >= deadline

    sleep delay
  end
end
