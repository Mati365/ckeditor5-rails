# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Assets::AssetsBundleHtmlSerializer do
  let(:test_bundle_class) do
    Class.new(CKEditor5::Rails::Assets::AssetsBundle) do
      attr_accessor :scripts, :stylesheets

      def initialize(scripts, stylesheets)
        @scripts = scripts
        @stylesheets = stylesheets
        super()
      end
    end
  end

  let(:bundle) { test_bundle_class.new(scripts, stylesheets) }

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
  let(:preloads) { bundle.preloads }

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

    it 'includes window scripts' do
      expect(html).to include(
        '<script src="https://cdn.com/script1.js" nonce="true" crossorigin="anonymous">'
      )
    end

    it 'includes import map' do
      expect(html).to include('type="importmap"')
      expect(html).to include('"@ckeditor/script2":"https://cdn.com/script2.js"')
    end

    it 'includes stylesheet links' do
      stylesheets.each do |url|
        expect(html).to include("<link href=\"#{url}\" rel=\"stylesheet\" crossorigin=\"anonymous\">")
      end
    end

    it 'includes preload links' do
      expect(html).to include(
        '<link href="https://cdn.com/style1.css" rel="preload" as="style" crossorigin="anonymous">'
      )

      expect(html).to include(
        '<link href="https://cdn.com/style2.css" rel="preload" as="style" crossorigin="anonymous">'
      )

      expect(html).to include(
        '<link href="https://cdn.com/script1.js" rel="preload" as="script" crossorigin="anonymous">'
      )

      expect(html).to include(
        '<link href="https://cdn.com/script2.js" rel="preload" as="script" crossorigin="anonymous">'
      )
    end

    it 'includes web component script' do
      expect(html).to include('<script type="module" nonce="true">')
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
end
