# frozen_string_literal: true

require 'net/http'
require 'json'
require_relative '../lib/ckeditor5/rails/version'

def fetch_latest_ckeditor_version
  uri = URI('https://registry.npmjs.org/ckeditor5/latest')
  response = Net::HTTP.get(uri)
  JSON.parse(response)['version']
rescue StandardError => e
  puts "Error fetching CKEditor version: #{e.message}"
  nil
end

def update_version_file(new_version)
  version_file_path = 'lib/ckeditor5/rails/version.rb'
  content = File.read(version_file_path)

  new_gem_version = increment_version(CKEditor5::Rails::VERSION)
  updated_content = content
                    .gsub(/VERSION = ['"].*['"]/,
                          "VERSION = '#{new_gem_version}'")
                    .gsub(/DEFAULT_CKEDITOR_VERSION = ['"].*['"]/,
                          "DEFAULT_CKEDITOR_VERSION = '#{new_version}'")

  File.write(version_file_path, updated_content)

  # Update README.md
  readme_path = 'README.md'
  readme_content = File.read(readme_path)
  updated_readme = readme_content.gsub(
    /version ['"][\d.]+['"]/,
    "version '#{new_version}'"
  )

  File.write(readme_path, updated_readme)
  new_gem_version
end

def increment_version(version)
  major, minor, patch = version.split('.')
  patch = patch.to_i + 1
  "#{major}.#{minor}.#{patch}"
end

def commit_changes(new_gem_version, new_version) # rubocop:disable Metrics/AbcSize
  system('git config --global user.email "github-actions[bot]@users.noreply.github.com"')
  system('git config --global user.name "github-actions[bot]"')

  puts 'Running bundle install...'
  system('bundle config set frozen false')

  unless system('bundle install')
    puts 'Bundle install failed!'
    exit 1
  end

  system('git add lib/ckeditor5/rails/version.rb README.md Gemfile.lock')
  system(%(git commit -m "feat: Update CKEditor to version #{new_version}"))

  puts 'Generating changelog...'
  unless system('chmod +x bin/generate_changelog.rb') &&
         system("ruby bin/generate_changelog.rb #{new_gem_version}")
    puts 'Changelog generation failed!'
    exit 1
  end

  system('git add CHANGELOG.md')
  system(%(git commit -m "Bump version to #{new_gem_version} and update dependencies"))

  system('git push origin main')
end

def main
  current_version = CKEditor5::Rails::DEFAULT_CKEDITOR_VERSION
  latest_version = fetch_latest_ckeditor_version

  if latest_version.nil?
    puts 'Failed to fetch latest version'
    exit 1
  end

  if latest_version != current_version
    puts "New version detected: #{latest_version} (current: #{current_version})"

    new_gem_version = update_version_file(latest_version)
    commit_changes(new_gem_version, latest_version)

    puts '::set-output name=version_updated::true'
    puts "::set-output name=new_version::#{new_gem_version}"
  else
    puts "Version is up to date (#{current_version})"
    puts '::set-output name=version_updated::false'
  end
end

main
