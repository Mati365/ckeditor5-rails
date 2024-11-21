# frozen_string_literal: true

require 'net/http'
require 'json'
require_relative '../../lib/ckeditor5/rails/version'

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

  # Aktualizacja obu wersji w tym samym pliku
  updated_content = content
                    .gsub(/DEFAULT_CKEDITOR_VERSION = ['"].*['"]/,
                          "DEFAULT_CKEDITOR_VERSION = '#{new_version}'")
                    .gsub(/VERSION = ['"].*['"]/,
                          "VERSION = '#{increment_version(CKEditor5::Rails::VERSION)}'")

  File.write(version_file_path, updated_content)

  # Update README.md
  readme_path = 'README.md'
  readme_content = File.read(readme_path)
  updated_readme = readme_content.gsub(
    /version ['"][\d.]+['"]/,
    "version '#{new_version}'"
  )
  File.write(readme_path, updated_readme)
end

def increment_version(version)
  major, minor, patch = version.split('.')
  patch = patch.to_i + 1
  "#{major}.#{minor}.#{patch}"
end

def commit_and_tag_changes(new_version)
  system('git config --global user.email "github-actions[bot]@users.noreply.github.com"')
  system('git config --global user.name "github-actions[bot]"')

  system('git add lib/ckeditor5/rails/version.rb README.md')
  system(%(git commit -m "chore: update CKEditor to version #{new_version}"))

  new_gem_version = increment_version(CKEditor5::Rails::VERSION)
  tag_message = "v#{new_gem_version}"
  system("git tag -a #{tag_message} -m 'Release #{tag_message}'")
  system('git push origin main --tags')
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
    update_version_file(latest_version)
    commit_and_tag_changes(latest_version)
    puts 'Updated version and created new tag'
  else
    puts "Version is up to date (#{current_version})"
  end
end

main
