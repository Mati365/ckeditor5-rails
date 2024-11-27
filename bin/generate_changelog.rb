#!/usr/bin/env ruby

require 'date'

def get_commits_since_last_bump
  `git log --pretty=format:"%H|||%s|||%h" $(git log --grep="^Bump version" -n 1 --pretty=format:%H)..HEAD`
    .split("\n")
    .map { |line| line.split('|||') }
    .map { |hash, subject, short_hash| [hash, subject.strip, short_hash] }
    .reject { |_, subject, _| subject.start_with?('Bump version') }
end

def get_repo_url
  remote_url = `git config --get remote.origin.url`.strip
  repo_path = remote_url.sub(/\.git$/, '').sub(/^.*github\.com[:|\/]/, '')
  "https://github.com/#{repo_path}"
end

def categorize_commits(commits)
  categories = {
    'Features' => [],
    'Bug Fixes' => [],
    'Documentation' => [],
    'Other Changes' => []
  }

  commits.each do |hash, subject, short_hash|
    category = case subject.downcase
              when /^(feature:|feat:)/i then 'Features'
              when /^fix:/i then 'Bug Fixes'
              when /^docs:/i then 'Documentation'
              else 'Other Changes'
              end

    # Remove the prefix from the subject (case insensitive)
    clean_subject = subject.sub(/^(feature:|feat:|fix:|docs:)\s*/i, '')
    categories[category] << [clean_subject, hash, short_hash]
  end

  # If no conventional commits found, add generic entry
  if categories.values.all?(&:empty?)
    categories['Bug Fixes'] << ['General improvements and bug fixes',
                               commits.first&.first || 'HEAD',
                               commits.first&.last || 'HEAD']
  else
    categories.delete_if { |_, v| v.empty? }
  end

  categories
end

def generate_changelog_entry(version)
  commits = get_commits_since_last_bump
  categories = categorize_commits(commits)
  repo_url = get_repo_url

  output = []
  output << "## [#{version}] - #{Date.today.strftime('%Y-%m-%d')}"
  output << ""

  categories.each do |category, entries|
    output << "### #{category}"
    output << ""
    entries.each do |subject, hash, short_hash|
      output << "* #{subject} ([#{short_hash}](#{repo_url}/commit/#{hash}))"
    end
    output << ""
  end

  output.join("\n")
end

def update_changelog(version)
  new_entry = generate_changelog_entry(version)
  changelog_path = File.join(Dir.pwd, 'CHANGELOG.md')

  current_content = File.exist?(changelog_path) ? File.read(changelog_path) : "# Changelog\n\n"

  # Insert new entry after the first line
  content_lines = current_content.lines
  content_lines.insert(2, "#{new_entry}\n")

  File.write(changelog_path, content_lines.join)
end

if ARGV[0]
  update_changelog(ARGV[0])
else
  puts "Usage: #{$0} VERSION"
  exit 1
end
