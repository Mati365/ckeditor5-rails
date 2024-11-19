# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../sandbox/config/application', __dir__)

require 'pry'
require 'spec_helper'
require 'rspec/rails'
require 'rspec/expectations'

Rails.application.initialize!

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

  # Add database cleaner configuration
  config.before(:each) do
    Rails.application.load_seed
  end
end
