# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = 'spec/e2e/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:e2e) do |t|
  t.pattern = 'spec/e2e/**/*_spec.rb'
end

task default: %i[spec e2e]
