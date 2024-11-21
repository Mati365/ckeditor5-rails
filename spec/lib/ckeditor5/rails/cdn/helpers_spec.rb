# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Cdn::Helpers do
  let(:test_class) { Class.new { include CKEditor5::Rails::Cdn::Helpers } }
  let(:helper) { test_class.new }
  let(:preset) do
    instance_double(
      CKEditor5::Rails::Presets::PresetBuilder,
      to_h_with_overrides: {
        cdn: :cloud,
        version: '34.1.0',
        type: 'classic',
        translations: %w[pl],
        ckbox: nil,
        license_key: nil,
        premium: false
      }
    )
  end
  let(:bundle_html) { '<script src="test.js"></script>' }
  let(:serializer) do
    instance_double(CKEditor5::Rails::Assets::AssetsBundleHtmlSerializer, to_html: bundle_html)
  end

  before do
    allow(CKEditor5::Rails::Engine).to receive(:find_preset).and_return(preset)
    allow(CKEditor5::Rails::Assets::AssetsBundleHtmlSerializer).to receive(:new).and_return(serializer)
  end

  describe '#ckeditor5_assets' do
    context 'with valid preset' do
      it 'returns serialized bundle html' do
        expect(helper.ckeditor5_assets(preset: :default)).to eq(bundle_html)
      end

      it 'creates base bundle' do
        expect(CKEditor5::Rails::Cdn::CKEditorBundle).to receive(:new)
          .with(
            instance_of(CKEditor5::Rails::Semver),
            'ckeditor5',
            translations: %w[pl],
            cdn: :cloud
          )
          .and_call_original

        helper.ckeditor5_assets(preset: :default)
      end

      context 'with premium features' do
        let(:preset) do
          instance_double(
            CKEditor5::Rails::Presets::PresetBuilder,
            to_h_with_overrides: {
              cdn: :cloud,
              version: '34.1.0',
              type: 'classic',
              translations: %w[pl],
              ckbox: nil,
              license_key: nil,
              premium: true
            }
          )
        end

        it 'creates base and premium bundles' do
          expect(CKEditor5::Rails::Cdn::CKEditorBundle).to receive(:new)
            .with(
              instance_of(CKEditor5::Rails::Semver),
              'ckeditor5',
              translations: %w[pl],
              cdn: :cloud
            )
            .and_call_original
            .ordered

          expect(CKEditor5::Rails::Cdn::CKEditorBundle).to receive(:new)
            .with(
              instance_of(CKEditor5::Rails::Semver),
              'ckeditor5-premium-features',
              translations: %w[pl],
              cdn: :cloud
            )
            .and_call_original
            .ordered

          helper.ckeditor5_assets(preset: :default)
        end
      end

      context 'with ckbox' do
        let(:preset) do
          instance_double(
            CKEditor5::Rails::Presets::PresetBuilder,
            to_h_with_overrides: {
              cdn: :cloud,
              version: '34.1.0',
              type: 'classic',
              translations: %w[pl],
              ckbox: { version: '1.0.0', theme: :lark },
              license_key: nil,
              premium: false
            }
          )
        end

        it 'creates ckbox bundle' do
          expect(CKEditor5::Rails::Cdn::CKBoxBundle).to receive(:new)
            .with(
              instance_of(CKEditor5::Rails::Semver),
              theme: :lark,
              cdn: :ckbox
            )
            .and_call_original

          helper.ckeditor5_assets(preset: :default)
        end
      end
    end

    context 'with invalid preset' do
      before do
        allow(CKEditor5::Rails::Engine).to receive(:find_preset).and_return(nil)
      end

      it 'raises error' do
        expect { helper.ckeditor5_assets(preset: :invalid) }
          .to raise_error(ArgumentError, /forgot to define your invalid preset/)
      end
    end

    context 'with missing required parameters' do
      let(:preset) do
        instance_double(
          CKEditor5::Rails::Presets::PresetBuilder,
          to_h_with_overrides: { cdn: :cloud }
        )
      end

      it 'raises error when version is missing' do
        expect { helper.ckeditor5_assets(preset: :default) }
          .to raise_error(ArgumentError, /forgot to define version/)
      end
    end
  end

  describe 'cdn helper methods' do
    it 'generates helper methods for third-party CDNs' do
      expect(helper).to respond_to(:ckeditor5_unpkg_assets)
      expect(helper).to respond_to(:ckeditor5_jsdelivr_assets)
    end

    it 'calls main helper with proper cdn parameter' do
      expect(helper).to receive(:ckeditor5_assets).with(cdn: :unpkg, version: '34.1.0')
      helper.ckeditor5_unpkg_assets(version: '34.1.0')
    end
  end
end
