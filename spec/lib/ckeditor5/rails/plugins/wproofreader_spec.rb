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

      it 'returns correct preload assets bundle' do
        bundle = plugin.preload_assets_bundle
        expect(bundle.stylesheets).to eq(["#{default_cdn}@#{default_version}/dist/browser/index.css"])
        expect(bundle.scripts.first.url).to eq("#{default_cdn}@#{default_version}/dist/browser/index.js")
      end

      it 'returns correct hash representation' do
        expected_hash = {
          type: :external,
          stylesheets: ["#{default_cdn}@#{default_version}/dist/browser/index.css"],
          translation: false,
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

      it 'returns correct preload assets bundle with custom CDN' do
        bundle = plugin.preload_assets_bundle
        expect(bundle.stylesheets).to eq(["#{custom_cdn}@#{custom_version}/dist/browser/index.css"])
        expect(bundle.scripts.first.url).to eq("#{custom_cdn}@#{custom_version}/dist/browser/index.js")
      end

      it 'returns correct hash representation with custom CDN' do
        expected_hash = {
          type: :external,
          stylesheets: ["#{custom_cdn}@#{custom_version}/dist/browser/index.css"],
          translation: false,
          url: "#{custom_cdn}@#{custom_version}/dist/browser/index.js",
          import_name: "#{custom_cdn}@#{custom_version}/dist/browser/index.js",
          import_as: 'WProofreader'
        }
        expect(plugin.to_h).to eq(expected_hash)
      end
    end
  end
end
