# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'ckeditor5/rails'

Gem::Specification.new do |s|
  s.name = 'ckeditor5'
  s.version = CKEditor5::Rails::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = 'CKEditor 5 for Rails'
  s.authors = [
    'Mateusz Bagiński',
    'Łukasz Modliński'
  ]

  s.license = 'GPL-2.0'
  s.email = 'cziken58@gmail.com'
  s.homepage = 'https://github.com/Mati365/ckeditor5-rails'
  s.required_ruby_version = '>= 3.0.0'

  s.extra_rdoc_files = ['README.md']
  s.test_files = Dir['test/**/*']
  s.files = Dir['lib/**/*'] + ['LICENSE', 'Gemfile', 'README.md']

  s.require_paths = ['lib']
  s.add_runtime_dependency 'rails', '>= 6.0', '< 8.0'
end
