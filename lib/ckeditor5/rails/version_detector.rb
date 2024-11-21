# frozen_string_literal: true

require 'net/http'
require 'json'
require 'singleton'
require 'monitor'

require_relative 'version'
require_relative 'semver'

module CKEditor5::Rails
  class VersionDetector
    include Singleton

    NPM_PACKAGE = 'ckeditor5'
    CACHE_DURATION = 345_600 # 4 days in seconds

    class << self
      delegate :latest_safe_version, to: :instance
    end

    def initialize
      @cache = {}
      @monitor = Monitor.new
    end

    def clear_cache!
      @monitor.synchronize { @cache.clear }
    end

    def latest_safe_version(current_version)
      @monitor.synchronize do
        cache_key = "#{current_version}_latest"
        return @cache[cache_key][:version] if valid_cache_entry?(cache_key)

        version = find_latest_safe_version(current_version)
        @cache[cache_key] = { version: version, timestamp: Time.now.to_i }
        version
      end
    end

    private

    def valid_cache_entry?(key)
      entry = @cache[key]
      entry && (Time.now.to_i - entry[:timestamp] < CACHE_DURATION)
    end

    def find_latest_safe_version(current_version)
      versions = fetch_all_versions
      return nil if versions.empty?

      current_semver = Semver.new(current_version)
      versions
        .reject { |v| v.include?('nightly') || v.include?('dev') }
        .select { |v| v.match?(Semver::SEMVER_PATTERN) }
        .sort_by { |v| Semver.new(v) }
        .reverse
        .find { |v| current_semver.safe_update?(v) }
    end

    def fetch_all_versions
      uri = URI("https://registry.npmjs.org/#{NPM_PACKAGE}")
      response = fetch_with_timeout(uri)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        data['versions'].keys
      else
        warn 'Failed to fetch CKEditor versions'
        []
      end
    rescue StandardError => e
      warn "Error fetching versions: #{e.message}"
      []
    end

    def fetch_with_timeout(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.open_timeout = 1
      http.read_timeout = 1
      http.get(uri.request_uri)
    end
  end
end
