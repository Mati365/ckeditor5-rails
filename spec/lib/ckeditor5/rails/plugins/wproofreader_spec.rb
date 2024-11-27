# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Plugins::WProofreader do
  let(:default_cdn) { 'https://cdn.jsdelivr.net/npm/@webspellchecker/wproofreader-ckeditor5' }
  let(:default_version) { '3.1.2' }

  describe '#initialize' do
    context 'with default parameters' do
      subject(:plugin) { described_class.new }

      it 'has correct name' do
        expect(plugin.name).to eq(:WProofreader)
      end

      it 'returns correct preload assets urls' do
        expected_urls = [
          "#{default_cdn}@#{default_version}/dist/browser/index.css",
          "#{default_cdn}@#{default_version}/dist/browser/index.js"
        ]
        expect(plugin.preload_assets_urls).to eq(expected_urls)
      end

      it 'returns correct hash representation' do
        expected_hash = {
          type: :external,
          stylesheets: ["#{default_cdn}@#{default_version}/dist/browser/index.css"],
          url: "#{default_cdn}@#{default_version}/dist/browser/index.js",
          import_name: "#{default_cdn}@#{default_version}/dist/browser/index.js",
          import_as: 'WProofreader'
        }
        expect(plugin.to_h).to eq(expected_hash)
      end
    end

    context 'with custom parameters' do
      let(:custom_cdn) { 'https://custom-cdn.com/wproofreader' }
      let(:custom_version) { '4.0.0' }
      subject(:plugin) { described_class.new(version: custom_version, cdn: custom_cdn) }

      it 'returns correct preload assets urls with custom CDN' do
        expected_urls = [
          "#{custom_cdn}@#{custom_version}/dist/browser/index.css",
          "#{custom_cdn}@#{custom_version}/dist/browser/index.js"
        ]
        expect(plugin.preload_assets_urls).to eq(expected_urls)
      end

      it 'returns correct hash representation with custom CDN' do
        expected_hash = {
          type: :external,
          stylesheets: ["#{custom_cdn}@#{custom_version}/dist/browser/index.css"],
          url: "#{custom_cdn}@#{custom_version}/dist/browser/index.js",
          import_name: "#{custom_cdn}@#{custom_version}/dist/browser/index.js",
          import_as: 'WProofreader'
        }
        expect(plugin.to_h).to eq(expected_hash)
      end
    end
  end
end
