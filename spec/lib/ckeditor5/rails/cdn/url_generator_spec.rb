# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Cdn::UrlGenerator do
  let(:test_class) do
    Class.new do
      include CKEditor5::Rails::Cdn::UrlGenerator

      attr_writer :cdn
    end
  end

  let(:instance) { test_class.new }

  shared_examples 'a CDN provider' do |cdn, url_pattern|
    before { instance.cdn = cdn }

    it 'generates correct URL' do
      expect(instance.create_cdn_url('ckeditor5', '34.1.0', 'ckeditor.js'))
        .to eq(format(url_pattern, version: '34.1.0'))
    end
  end

  describe '#create_cdn_url' do
    context 'with open-source CDNs' do
      it_behaves_like 'a CDN provider', :jsdelivr,
                      'https://cdn.jsdelivr.net/npm/ckeditor5@%<version>s/dist/browser/ckeditor.js'

      it_behaves_like 'a CDN provider', :unpkg,
                      'https://unpkg.com/ckeditor5@%<version>s/dist/browser/ckeditor.js'

      context 'with translations' do
        it 'handles translation paths correctly' do
          instance.cdn = :jsdelivr
          expect(instance.create_cdn_url('ckeditor5', '34.1.0', 'translations/pl.js'))
            .to eq('https://cdn.jsdelivr.net/npm/ckeditor5@34.1.0/dist/translations/pl.js')
        end
      end
    end

    context 'with commercial CDNs' do
      it_behaves_like 'a CDN provider', :cloud,
                      'https://cdn.ckeditor.com/ckeditor5/%<version>s/ckeditor.js'

      it 'generates correct CKBox URL' do
        instance.cdn = :cloud
        expect(instance.create_cdn_url('ckbox', '34.1.0', 'ckeditor.js'))
          .to eq('https://cdn.ckbox.io/ckbox/34.1.0/ckeditor.js')
      end
    end

    context 'with invalid configuration' do
      it 'raises ArgumentError for unknown CDN provider' do
        instance.cdn = :invalid_cdn
        expect { instance.create_cdn_url('ckeditor5', '34.1.0', 'ckeditor.js') }
          .to raise_error(ArgumentError, 'Unknown provider: invalid_cdn')
      end
    end
  end
end
