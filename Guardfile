# frozen_string_literal: true

guard :process, name: 'Rails', dir: 'sandbox', command: 'bundle exec rails server' do
  watch('sandbox/Gemfile.lock')
  watch(%r{^sandbox/lib/(.+)\.rb$})
  watch(%r{^sandbox/app/(.+)\.rb$})
  watch(%r{^sandbox/config/(.+)\.rb$})
  watch(%r{^lib/(.+)\.rb$})
  watch(/.*\.gemspec/)
end
