# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Hooks::Importmap::ImportmapTagsHelper do
  let(:test_class) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include CKEditor5::Rails::Hooks::Importmap::ImportmapTagsHelper

      def javascript_importmap_module_preload_tags(*)
        '<script type="modulepreload">preload</script>'
      end

      def javascript_import_module_tag(*)
        '<script type="module">import</script>'
      end

      def javascript_inline_importmap_tag(json)
        "<script type=\"importmap\">#{json}</script>"
      end
    end
  end

  let(:helper) { test_class.new }
  let(:importmap) { double('Importmap', to_json: '{"imports":{}}') }

  before do
    allow(Rails.application).to receive(:importmap).and_return(importmap)
  end

  describe '#javascript_importmap_tags' do
    context 'without CKEditor context' do
      it 'generates basic importmap tags' do
        result = helper.javascript_importmap_tags

        expect(result).to include('modulepreload')
        expect(result).to include('module')
        expect(helper).to be_importmap_rendered
      end
    end

    context 'with CKEditor context' do
      let(:bundle) do
        CKEditor5::Rails::Assets::AssetsBundle.new(
          scripts: [
            CKEditor5::Rails::Assets::JSUrlImportMeta.new(
              'https://cdn.com/script.js',
              import_name: '@ckeditor/module'
            )
          ]
        )
      end

      let(:html_tags) { '<script src="ckeditor.js"></script>' }

      before do
        helper.instance_variable_set(:@__ckeditor_context, {
                                       bundle: bundle,
                                       html_tags: html_tags
                                     })
      end

      it 'merges CKEditor importmap with base importmap' do
        result = CGI.unescapeHTML(helper.javascript_importmap_tags)

        expect(result).to include('@ckeditor/module')
        expect(result).to include('https://cdn.com/script.js')
        expect(result).to include(html_tags)
      end

      it 'handles invalid JSON gracefully' do
        allow(importmap).to receive(:to_json).and_return('invalid json')

        expect(Rails.logger).to receive(:error).with(/Failed to merge import maps/)
        helper.javascript_importmap_tags
      end
    end
  end

  describe '#importmap_rendered?' do
    it 'returns false by default' do
      expect(helper).not_to be_importmap_rendered
    end

    it 'returns true after rendering importmap' do
      helper.javascript_importmap_tags
      expect(helper).to be_importmap_rendered
    end
  end

  describe '#merge_import_maps_json (private)' do
    it 'correctly merges two valid import maps' do
      map_a = '{"imports":{"a":"1"}}'
      map_b = '{"imports":{"b":"2"}}'

      result = JSON.parse(helper.send(:merge_import_maps_json, map_a, map_b))
      expect(result['imports']).to eq('a' => '1', 'b' => '2')
    end

    it 'returns second map when first is invalid' do
      map_a = 'invalid json'
      map_b = '{"imports":{"b":"2"}}'

      expect(Rails.logger).to receive(:error).with(/Failed to merge import maps/)
      result = helper.send(:merge_import_maps_json, map_a, map_b)
      expect(result).to eq(map_b)
    end
  end
end
