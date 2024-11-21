# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Assets::AssetsBundle do
  let(:concrete_class) do
    Class.new(described_class) do
      def scripts
        []
      end

      def stylesheets
        []
      end
    end
  end

  describe '#initialize' do
    it 'raises error when required methods are not implemented' do
      expect { described_class.new }.to raise_error(NotImplementedError)
    end

    it 'initializes successfully when required methods are implemented' do
      expect { concrete_class.new }.not_to raise_error
    end
  end

  describe '#empty?' do
    subject(:bundle) { concrete_class.new }

    it 'returns true when no assets are present' do
      expect(bundle).to be_empty
    end
  end

  describe '#translations_scripts' do
    let(:bundle) { concrete_class.new }
    let(:translation_script) { instance_double(CKEditor5::Rails::Assets::JSExportsMeta, translation?: true) }
    let(:regular_script) { instance_double(CKEditor5::Rails::Assets::JSExportsMeta, translation?: false) }

    before do
      allow(bundle).to receive(:scripts).and_return([translation_script, regular_script])
    end

    it 'returns only translation scripts' do
      expect(bundle.translations_scripts).to eq([translation_script])
    end
  end

  describe '#<<' do
    let(:script1) { instance_double(CKEditor5::Rails::Assets::JSExportsMeta) }
    let(:script2) { instance_double(CKEditor5::Rails::Assets::JSExportsMeta) }
    let(:stylesheet1) { '/path/to/style1.css' }
    let(:stylesheet2) { '/path/to/style2.css' }

    let(:bundle1) do
      Class.new(described_class) do
        attr_writer :scripts, :stylesheets

        def scripts
          @scripts ||= []
        end

        def stylesheets
          @stylesheets ||= []
        end
      end.new
    end

    let(:bundle2) do
      Class.new(described_class) do
        attr_writer :scripts, :stylesheets

        def scripts
          @scripts ||= []
        end

        def stylesheets
          @stylesheets ||= []
        end
      end.new
    end

    before do
      bundle1.scripts = [script1]
      bundle1.stylesheets = [stylesheet1]
      bundle2.scripts = [script2]
      bundle2.stylesheets = [stylesheet2]
    end

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
    let(:script1) { instance_double(CKEditor5::Rails::Assets::JSExportsMeta, url: '/js/script1.js') }
    let(:script2) { instance_double(CKEditor5::Rails::Assets::JSExportsMeta, url: '/js/script2.js') }
    let(:stylesheet1) { '/css/style1.css' }
    let(:stylesheet2) { '/css/style2.css' }

    let(:bundle) do
      Class.new(described_class) do
        attr_writer :scripts, :stylesheets

        def scripts
          @scripts ||= []
        end

        def stylesheets
          @stylesheets ||= []
        end
      end.new
    end

    before do
      bundle.scripts = [script1, script2]
      bundle.stylesheets = [stylesheet1, stylesheet2]
    end

    it 'returns array of stylesheet paths and script urls' do
      expect(bundle.preloads).to eq([
                                      '/css/style1.css',
                                      '/css/style2.css',
                                      '/js/script1.js',
                                      '/js/script2.js'
                                    ])
    end
  end
end

RSpec.describe CKEditor5::Rails::Assets::JSExportsMeta do
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
