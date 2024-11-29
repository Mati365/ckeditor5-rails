# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Assets::AssetsBundleHtmlSerializer do
  let(:scripts) do
    [
      CKEditor5::Rails::Assets::JSUrlImportMeta.new(
        'https://cdn.com/script1.js',
        window_name: 'CKEditor5'
      ),
      CKEditor5::Rails::Assets::JSUrlImportMeta.new(
        'https://cdn.com/script2.js',
        import_name: '@ckeditor/script2'
      )
    ]
  end

  let(:stylesheets) { ['https://cdn.com/style1.css', 'https://cdn.com/style2.css'] }
  let(:bundle) { CKEditor5::Rails::Assets::AssetsBundle.new(scripts: scripts, stylesheets: stylesheets) }

  subject(:serializer) { described_class.new(bundle) }

  describe '#initialize' do
    context 'with invalid bundle' do
      let(:bundle) { 'not a bundle' }

      it 'raises TypeError' do
        expect { serializer }.to raise_error(TypeError, 'bundle must be an instance of AssetsBundle')
      end
    end
  end

  describe '#to_html' do
    subject(:html) { serializer.to_html }

    it 'includes window script tags' do
      expect(html).to have_tag('script', with: {
                                 src: 'https://cdn.com/script1.js',
                                 nonce: 'true',
                                 crossorigin: 'anonymous'
                               })
    end

    it 'includes import map' do
      expect(html).to have_tag('script', with: { type: 'importmap' }) do
        with_text(%r{"@ckeditor/script2":"https://cdn\.com/script2\.js"})
      end
    end

    it 'includes import map with correct attributes' do
      expect(html).to have_tag('script', with: {
                                 type: 'importmap',
                                 nonce: 'true'
                               })
    end

    it 'does not include URL-like imports in import map' do
      bundle = CKEditor5::Rails::Assets::AssetsBundle.new(
        scripts: [
          CKEditor5::Rails::Assets::JSUrlImportMeta.new(
            'https://cdn.com/script.js',
            import_name: 'https://example.com/module'
          ),
          CKEditor5::Rails::Assets::JSUrlImportMeta.new(
            'https://cdn.com/script.js',
            import_name: 'module'
          )
        ]
      )
      html = described_class.new(bundle).to_html

      expect(html).to have_tag('script', with: { type: 'importmap' }) do
        with_text('{"imports":{"module":"https://cdn.com/script.js"}}')
      end
    end

    it 'includes only ESM scripts in import map' do
      bundle = CKEditor5::Rails::Assets::AssetsBundle.new(
        scripts: [
          CKEditor5::Rails::Assets::JSUrlImportMeta.new(
            'https://cdn.com/script1.js',
            window_name: 'WindowScript'
          ),
          CKEditor5::Rails::Assets::JSUrlImportMeta.new(
            'https://cdn.com/script2.js',
            import_name: '@ckeditor/module'
          )
        ]
      )
      html = described_class.new(bundle).to_html

      expect(html).to have_tag('script', with: { type: 'importmap' }) do
        with_text('{"imports":{"@ckeditor/module":"https://cdn.com/script2.js"}}')
      end
    end

    it 'includes stylesheet links' do
      stylesheets.each do |url|
        expect(html).to have_tag('link', with: {
                                   href: url,
                                   rel: 'stylesheet',
                                   crossorigin: 'anonymous'
                                 })
      end
    end

    it 'includes preload links' do
      scripts.each do |script|
        expect(html).to have_tag('link', with: {
                                   href: script.url,
                                   rel: script.esm? ? 'modulepreload' : 'preload',
                                   as: 'script',
                                   crossorigin: 'anonymous'
                                 })
      end

      stylesheets.each do |url|
        expect(html).to have_tag('link', with: {
                                   href: url,
                                   rel: 'preload',
                                   as: 'style',
                                   crossorigin: 'anonymous'
                                 })
      end
    end

    it 'includes web component script' do
      expect(html).to have_tag('script', with: {
                                 type: 'module',
                                 nonce: 'true'
                               })
    end

    it 'memoizes scripts import map' do
      first_call = serializer.send(:scripts_import_map_tag)
      second_call = serializer.send(:scripts_import_map_tag)

      expect(first_call.object_id).to eq(second_call.object_id)
    end
  end

  describe '.url_resource_preload_type' do
    it 'returns correct type for js files' do
      expect(described_class.url_resource_preload_type('file.js')).to eq('script')
    end

    it 'returns correct type for css files' do
      expect(described_class.url_resource_preload_type('file.css')).to eq('style')
    end

    it 'returns fetch for unknown extensions' do
      expect(described_class.url_resource_preload_type('file.unknown')).to eq('fetch')
    end
  end

  describe '#looks_like_url? (private)' do
    subject(:serializer) { described_class.new(CKEditor5::Rails::Assets::AssetsBundle.new) }

    it 'returns false for invalid URIs' do
      expect(serializer.send(:looks_like_url?, '@ckeditor/foo')).to be false
      expect(serializer.send(:looks_like_url?, 'http')).to be false
      expect(serializer.send(:looks_like_url?, 'invalid')).to be false
      expect(serializer.send(:looks_like_url?, 'http://[invalid')).to be false
      expect(serializer.send(:looks_like_url?, "http://example.com\nmalicious")).to be false
      expect(serializer.send(:looks_like_url?, 'http://<invalid>')).to be false
    end
  end
end
