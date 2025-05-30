# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.start do
  enable_coverage :branch
  enable_coverage :line

  add_filter 'sandbox/'
  add_filter 'spec/'
  add_filter 'lib/ckeditor5/rails/version.rb' # Fix bug in coverage calculation
  add_group 'Library', 'lib/'

  track_files 'lib/**/*.rb'

  minimum_coverage 100

  formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ]

  formatter SimpleCov::Formatter::MultiFormatter.new(formatters)
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../sandbox/config/application', __dir__)

require 'pry'
require 'spec_helper'
require 'rspec/rails'
require 'rspec/expectations'
require 'rspec-html-matchers'

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

Rails.application.initialize! unless Rails.application.initialized?

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 10

  config.order = :random

  Kernel.rand config.seed

  config.before(:each) do
    Rails.application.load_seed
  end

  config.include RSpecHtmlMatchers
end
