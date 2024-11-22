# frozen_string_literal: true

group :rails do
  guard :process, name: 'Rails', dir: 'sandbox', command: 'bundle exec rails server' do
    watch('sandbox/Gemfile.lock')
    watch(%r{^sandbox/lib/(.+)\.rb$})
    watch(%r{^sandbox/app/(.+)\.rb$})
    watch(%r{^sandbox/config/(.+)\.rb$})
    watch(%r{^lib/(.+)\.rb$})
    watch(/.*\.gemspec/)
  end
end

group :rspec do
  guard :rspec, name: 'RSpec', cmd: 'bundle exec rspec', all_on_start: true do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb') { 'spec' }
  end
end

group :e2e do
  guard :process, name: 'capybara', command: 'bundle exec rake e2e' do
    watch(%r{^spec/e2e/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/e2e/spec_helper.rb') { 'spec' }
  end
end
