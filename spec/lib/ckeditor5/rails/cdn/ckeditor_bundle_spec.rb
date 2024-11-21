# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Cdn::CKEditorBundle do
  let(:version) { CKEditor5::Rails::Semver.new('34.1.0') }
  let(:import_name) { '@ckeditor/ckeditor5-build-classic' }
  let(:translations) { %w[pl de] }
  let(:cdn) { 'https://cdn.example.com' }

  before do
    allow(CKEditor5::Rails::Engine.default_preset).to receive(:cdn).and_return(cdn)
    allow_any_instance_of(described_class).to receive(:create_cdn_url) do |_, pkg, ver, file|
      "#{cdn}/npm/#{pkg}@#{ver}/build/#{file}"
    end
  end

  describe '#initialize' do
    it 'creates instance with valid parameters' do
      expect do
        described_class.new(version, import_name, translations: translations)
      end.not_to raise_error
    end

    it 'raises error when version is not Semver' do
      expect do
        described_class.new('34.1.0', import_name)
      end.to raise_error(ArgumentError, 'version must be semver')
    end

    it 'raises error when import_name is not string' do
      expect do
        described_class.new(version, :invalid)
      end.to raise_error(ArgumentError, 'import_name must be a string')
    end

    it 'raises error when translations is not array' do
      expect do
        described_class.new(version, import_name, translations: 'invalid')
      end.to raise_error(ArgumentError, 'translations must be an array')
    end
  end

  describe '#scripts' do
    subject(:bundle) { described_class.new(version, import_name, translations: translations) }

    it 'returns main script and translation scripts' do
      expect(bundle.scripts.count).to eq(3)
      expect(bundle.scripts.first.url).to eq("#{cdn}/npm/#{import_name}@#{version}/build/#{import_name}.js")
      expect(bundle.scripts.first).not_to be_translation
    end

    it 'includes translation scripts' do
      translation_scripts = bundle.scripts.select(&:translation?)
      expect(translation_scripts.count).to eq(2)
      expect(translation_scripts.map(&:url)).to contain_exactly(
        "#{cdn}/npm/#{import_name}@#{version}/build/translations/pl.js",
        "#{cdn}/npm/#{import_name}@#{version}/build/translations/de.js"
      )
    end
  end

  describe '#stylesheets' do
    subject(:bundle) { described_class.new(version, import_name) }

    it 'returns stylesheet URL' do
      expect(bundle.stylesheets).to eq(
        ["#{cdn}/npm/#{import_name}@#{version}/build/#{import_name}.css"]
      )
    end
  end
end
