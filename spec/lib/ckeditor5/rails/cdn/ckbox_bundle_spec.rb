# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Cdn::CKBoxBundle do
  let(:version) { CKEditor5::Rails::Semver.new('2.6.0') }
  let(:cdn) { :jsdelivr }
  let(:theme) { :lark }
  let(:translations) { [] }
  let(:bundle) { described_class.new(version, theme: theme, cdn: cdn, translations: translations) }

  describe '#initialize' do
    context 'with valid parameters' do
      it 'creates bundle successfully' do
        expect { bundle }.not_to raise_error
      end
    end

    context 'with invalid parameters' do
      it 'raises error for invalid version' do
        expect { described_class.new('invalid', theme: theme) }
          .to raise_error(ArgumentError, 'version must be semver')
      end

      it 'raises error for invalid theme type' do
        expect { described_class.new(version, theme: 123) }
          .to raise_error(ArgumentError, 'theme must be a string or symbol')
      end

      it 'raises error for invalid translations type' do
        expect { described_class.new(version, theme: theme, translations: 'invalid') }
          .to raise_error(ArgumentError, 'translations must be an array')
      end
    end
  end

  describe '#scripts' do
    it 'returns array with main script' do
      expect(bundle.scripts.first).to be_a(CKEditor5::Rails::Assets::JSUrlImportMeta)
      expect(bundle.scripts.first.url).to include('ckbox.js')
      expect(bundle.scripts.first.window_name).to eq('CKBox')
    end

    context 'with translations' do
      let(:translations) { [:pl] }

      it 'includes translation scripts' do
        translation_script = bundle.scripts.last
        expect(translation_script.url).to include('translations/pl.js')
        expect(translation_script.window_name).to eq('CKBOX_TRANSLATIONS')
        expect(translation_script.translation?).to be true
      end
    end
  end

  describe '#stylesheets' do
    it 'returns array with theme stylesheet' do
      expect(bundle.stylesheets.first).to include('styles/themes/lark.css')
    end

    context 'with custom theme' do
      let(:theme) { :custom }

      it 'uses custom theme in stylesheet path' do
        expect(bundle.stylesheets.first).to include('styles/themes/custom.css')
      end
    end
  end
end
