# frozen_string_literal: true

require 'capybara'
require 'capybara/rspec'
require 'capybara/cuprite'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../sandbox/config/environment', __dir__)

require 'capybara/rails'

Capybara.app = Rails.application

Capybara.register_driver(:cuprite) do |app|
  driver = Capybara::Cuprite::Driver.new(
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

  process = driver.browser.process
  puts ''
  puts "Browser: #{process.browser_version}"
  puts "Protocol: #{process.protocol_version}"
  puts "V8: #{process.v8_version}"
  puts "Webkit: #{process.webkit_version}"
  driver
end

Capybara.server = :webrick
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }
