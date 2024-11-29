# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Assets::AssetsBundle do
  describe '#initialize' do
    it 'initializes with empty arrays by default' do
      bundle = described_class.new
      expect(bundle.scripts).to eq([])
      expect(bundle.stylesheets).to eq([])
    end

    it 'accepts scripts and stylesheets' do
      bundle = described_class.new(scripts: [:script], stylesheets: [:stylesheet])
      expect(bundle.scripts).to eq([:script])
      expect(bundle.stylesheets).to eq([:stylesheet])
    end
  end

  describe '#empty?' do
    it 'returns true when no assets are present' do
      bundle = described_class.new
      expect(bundle).to be_empty
    end

    it 'returns false when scripts are present' do
      bundle = described_class.new(scripts: [:script])
      expect(bundle).not_to be_empty
    end

    it 'returns false when stylesheets are present' do
      bundle = described_class.new(stylesheets: [:stylesheet])
      expect(bundle).not_to be_empty
    end
  end

  describe '#translations_scripts' do
    let(:translation_script) do
      instance_double(CKEditor5::Rails::Assets::JSUrlImportMeta, translation?: true)
    end
    let(:regular_script) { instance_double(CKEditor5::Rails::Assets::JSUrlImportMeta, translation?: false) }

    it 'returns only translation scripts' do
      bundle = described_class.new(scripts: [translation_script, regular_script])
      expect(bundle.translations_scripts).to eq([translation_script])
    end
  end

  describe '#<<' do
    let(:script1) { instance_double(CKEditor5::Rails::Assets::JSUrlImportMeta) }
    let(:script2) { instance_double(CKEditor5::Rails::Assets::JSUrlImportMeta) }
    let(:stylesheet1) { '/path/to/style1.css' }
    let(:stylesheet2) { '/path/to/style2.css' }
    let(:bundle1) { described_class.new(scripts: [script1], stylesheets: [stylesheet1]) }
    let(:bundle2) { described_class.new(scripts: [script2], stylesheets: [stylesheet2]) }

    it 'raises TypeError when argument is not an AssetsBundle' do
      expect { bundle1 << 'not a bundle' }.to raise_error(TypeError)
    end

    it 'merges scripts and stylesheets from both bundles' do
      bundle1 << bundle2

      expect(bundle1.scripts).to eq([script1, script2])
      expect(bundle1.stylesheets).to eq([stylesheet1, stylesheet2])
    end
  end

  describe '#preloads' do
    let(:script1) { CKEditor5::Rails::Assets::JSUrlImportMeta.new('/js/script1.js', import_name: 'script1') }
    let(:script2) { CKEditor5::Rails::Assets::JSUrlImportMeta.new('/js/script2.js', import_name: 'script2') }
    let(:stylesheet1) { '/css/style1.css' }
    let(:stylesheet2) { '/css/style2.css' }
    let(:bundle) do
      described_class.new(
        scripts: [script1, script2],
        stylesheets: [stylesheet1, stylesheet2]
      )
    end

    it 'returns array of stylesheet paths and script urls' do
      expect(bundle.preloads).to eq([
                                      '/css/style1.css',
                                      '/css/style2.css',
                                      { as: 'script', rel: 'modulepreload', href: '/js/script1.js' },
                                      { as: 'script', rel: 'modulepreload', href: '/js/script2.js' }
                                    ])
    end
  end
end

RSpec.describe CKEditor5::Rails::Assets::JSUrlImportMeta do
  let(:url) { '/path/to/script.js' }

  describe '#initialize' do
    it 'creates instance with import_name' do
      meta = described_class.new(url, import_name: 'module')
      expect(meta.import_name).to eq('module')
    end

    it 'creates instance with window_name' do
      meta = described_class.new(url, window_name: 'MyModule')
      expect(meta.window_name).to eq('MyModule')
    end

    it 'marks as translation when specified' do
      meta = described_class.new(url, translation: true, import_name: 'module')
      expect(meta).to be_translation
    end
  end

  describe '#to_h' do
    it 'returns hash with url and import meta' do
      meta = described_class.new(url, import_name: 'module', import_as: 'alias')
      expect(meta.to_h).to eq({
                                url: url,
                                import_name: 'module',
                                import_as: 'alias'
                              })
    end
  end

  describe '#preloads' do
    it 'returns preload hash' do
      meta = described_class.new(url, window_name: 'module')
      expect(meta.preloads).to eq({ as: 'script', rel: 'preload', href: url })
    end

    it 'returns modulepreload hash when esm' do
      meta = described_class.new(url, import_name: 'module')
      expect(meta.preloads).to include({ as: 'script', rel: 'modulepreload', href: url })
    end
  end
end

RSpec.describe CKEditor5::Rails::Assets::JSImportMeta do
  describe '#initialize' do
    it 'raises error when neither import_name nor window_name is provided' do
      expect { described_class.new }.to raise_error(ArgumentError)
    end

    it 'raises error when import_as is present without import_name' do
      expect { described_class.new(import_as: 'alias', window_name: 'Module') }
        .to raise_error(ArgumentError)
    end

    it 'creates valid instance with import_name' do
      meta = described_class.new(import_name: 'module')
      expect(meta).to be_esm
    end

    it 'creates valid instance with window_name' do
      meta = described_class.new(window_name: 'Module')
      expect(meta).to be_window
    end
  end

  describe '#to_h' do
    it 'returns hash with only present values' do
      meta = described_class.new(import_name: 'module', import_as: 'alias')
      expect(meta.to_h).to eq({
                                import_name: 'module',
                                import_as: 'alias'
                              })
    end
  end
end
