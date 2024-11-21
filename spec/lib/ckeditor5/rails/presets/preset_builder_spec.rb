# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Presets::PresetBuilder do
  let(:builder) { described_class.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(builder.version).to be_nil
      expect(builder.premium?).to be false
      expect(builder.cdn).to eq(:jsdelivr)
      expect(builder.translations).to eq([:en])
      expect(builder.license_key).to be_nil
      expect(builder.type).to eq(:classic)
      expect(builder.ckbox).to be_nil
      expect(builder.editable_height).to be_nil
      expect(builder.config).to eq({ plugins: [], toolbar: [] })
    end

    it 'accepts a configuration block' do
      builder = described_class.new do
        version '35.0.0'
        premium true
        translations :en, :pl
      end

      expect(builder.version).to eq('35.0.0')
      expect(builder.premium?).to be true
      expect(builder.translations).to eq(%i[en pl])
    end
  end

  describe '#initialize_copy' do
    let(:original) do
      described_class.new do
        version '35.0.0'
        translations :en, :pl
        ckbox '1.0.0'
        toolbar :bold, :italic
        plugins :Essentials
      end
    end
    let(:copy) { original.dup }

    it 'creates a deep copy' do
      expect(copy.translations.object_id).not_to eq(original.translations.object_id)
      expect(copy.ckbox.object_id).not_to eq(original.ckbox.object_id)
      expect(copy.config[:plugins].object_id).not_to eq(original.config[:plugins].object_id)
      expect(copy.config[:toolbar].object_id).not_to eq(original.config[:toolbar].object_id)
    end

    it 'maintains the same values' do
      expect(copy.version).to eq(original.version)
      expect(copy.translations).to eq(original.translations)
      expect(copy.ckbox).to eq(original.ckbox)

      # Compare toolbar separately
      expect(copy.config[:toolbar][:items]).to eq(original.config[:toolbar][:items])
      expect(copy.config[:toolbar][:shouldNotGroupWhenFull]).to eq(original.config[:toolbar][:shouldNotGroupWhenFull])

      # Compare plugin names
      copy_names = copy.config[:plugins].map { |p| p.name.to_s }
      original_names = original.config[:plugins].map { |p| p.name.to_s }
      expect(copy_names).to eq(original_names)
    end
  end

  describe 'configuration methods' do
    describe '#automatic_upgrades' do
      it 'enables automatic upgrades' do
        builder.automatic_upgrades
        expect(builder.automatic_upgrades?).to be true
      end

      it 'detects latest safe version when enabled' do
        allow(CKEditor5::Rails::VersionDetector).to receive(:latest_safe_version)
          .with('35.0.0')
          .and_return('35.1.0')

        builder.automatic_upgrades
        builder.version '35.0.0'

        expect(builder.version).to eq('35.1.0')
      end
    end

    describe '#license_key' do
      it 'sets license key and switches to cloud CDN for non-GPL licenses' do
        builder.license_key('commercial-key')
        expect(builder.license_key).to eq('commercial-key')
        expect(builder.cdn).to eq(:cloud)
      end

      it 'keeps current CDN for GPL license' do
        builder.cdn(:jsdelivr)
        builder.license_key('GPL')
        expect(builder.cdn).to eq(:jsdelivr)
      end
    end

    describe '#menubar' do
      it 'configures menubar visibility' do
        builder.menubar(visible: true)
        expect(builder.config[:menuBar]).to eq({ isVisible: true })
        expect(builder.menubar?).to be true
      end
    end

    describe '#toolbar' do
      it 'configures toolbar items' do
        builder.toolbar(:bold, :italic, should_group_when_full: false)
        expect(builder.config[:toolbar]).to eq({
                                                 items: %i[bold italic],
                                                 shouldNotGroupWhenFull: true
                                               })
      end

      it 'doesnt override existing toolbar if no items provided' do
        original_config = { items: [:bold], shouldNotGroupWhenFull: true }
        builder.config[:toolbar] = original_config
        builder.toolbar
        expect(builder.config[:toolbar]).to eq(original_config)
      end

      it 'overrides existing toolbar if items provided' do
        builder.config[:toolbar] = { items: [:bold], shouldNotGroupWhenFull: true }
        builder.toolbar(:italic)
        expect(builder.config[:toolbar][:items]).to eq([:italic])
      end

      it 'accepts a configuration block' do
        builder.toolbar do
          append :bold, :italic
          prepend :undo
          remove :|
        end
        expect(builder.config[:toolbar][:items]).to include(:bold, :italic, :undo)
      end
    end

    describe '#plugins' do
      it 'adds plugins' do
        builder.plugins(:Essentials, :Paragraph)
        plugin_names = builder.config[:plugins].map { |p| p.name.to_s }
        expect(plugin_names).to eq(%w[Essentials Paragraph])
      end

      it 'accepts a configuration block' do
        builder.plugins do
          append :Essentials
          prepend :Paragraph
          remove :Base64UploadAdapter
        end
        plugin_names = builder.config[:plugins].map { |p| p.name.to_s }
        expect(plugin_names).to eq(%w[Paragraph Essentials])
      end
    end

    describe '#simple_upload_adapter' do
      it 'configures simple upload adapter' do
        builder.simple_upload_adapter('/custom/upload')
        expect(builder.config[:simpleUpload]).to eq({ uploadUrl: '/custom/upload' })

        plugin_names = builder.config[:plugins].map(&:name)
        expect(plugin_names).to include(:SimpleUploadAdapter)
      end
    end
  end

  describe '#inline_plugin' do
    let(:plugin_code) do
      <<~JAVASCRIPT
        import Plugin from 'ckeditor5/src/plugin';
        export default class CustomPlugin extends Plugin {
          init() {
            // plugin initialization
          }
        }
      JAVASCRIPT
    end

    it 'adds inline plugin to configuration' do
      builder.inline_plugin(:CustomPlugin, plugin_code)

      plugin = builder.config[:plugins].first
      expect(plugin).to be_a(CKEditor5::Rails::Editor::PropsInlinePlugin)
      expect(plugin.name).to eq(:CustomPlugin)
      expect(plugin.code).to eq(plugin_code)
    end

    it 'allows multiple inline plugins' do
      builder.inline_plugin(:Plugin1, plugin_code)
      builder.inline_plugin(:Plugin2, plugin_code)

      plugin_names = builder.config[:plugins].map(&:name)
      expect(plugin_names).to eq(%i[Plugin1 Plugin2])
    end
  end

  describe '#cdn' do
    it 'returns current cdn when called without arguments' do
      expect(builder.cdn).to eq(:jsdelivr)
    end

    it 'sets cdn when string/symbol provided' do
      builder.cdn(:cloud)
      expect(builder.cdn).to eq(:cloud)
    end

    context 'with block' do
      it 'accepts block with correct arity' do
        cdn_block = ->(bundle, version, path) { "#{bundle}/#{version}/#{path}" }
        builder.cdn(&cdn_block)
        expect(builder.cdn).to eq(cdn_block)
      end

      it 'raises error when block has wrong arity' do
        expect do
          builder.cdn { |bundle| bundle }
        end.to raise_error(ArgumentError, 'Block must accept exactly 3 arguments: bundle, version, path')
      end

      it 'raises error when block has wrong arity (too many args)' do
        expect do
          builder.cdn { |bundle, version, path, extra| bundle } # rubocop:disable Lint/UnusedBlockArgument
        end.to raise_error(ArgumentError, 'Block must accept exactly 3 arguments: bundle, version, path')
      end
    end
  end

  describe '#type' do
    it 'returns current type when called without arguments' do
      expect(builder.type).to eq(:classic)
    end

    it 'sets type when valid type provided' do
      allow(CKEditor5::Rails::Editor::Props).to receive(:valid_editor_type?)
        .with(:inline)
        .and_return(true)

      builder.type(:inline)
      expect(builder.type).to eq(:inline)
    end

    it 'raises error when invalid type provided' do
      allow(CKEditor5::Rails::Editor::Props).to receive(:valid_editor_type?)
        .with(:invalid)
        .and_return(false)

      expect do
        builder.type(:invalid)
      end.to raise_error(ArgumentError, 'Invalid editor type: invalid')
    end
  end

  describe '#to_h_with_overrides' do
    let(:builder) do
      described_class.new do
        version '35.0.0'
        premium true
        translations :en, :pl
      end
    end

    it 'returns hash with default values' do
      result = builder.to_h_with_overrides
      expect(result).to include(
        version: '35.0.0',
        premium: true,
        translations: %i[en pl]
      )
    end

    it 'applies overrides' do
      result = builder.to_h_with_overrides(
        version: '36.0.0',
        premium: false,
        translations: [:en]
      )
      expect(result).to include(
        version: '36.0.0',
        premium: false,
        translations: [:en]
      )
    end
  end

  describe '#language' do
    it 'returns language config when called without arguments' do
      builder.language(:pl, content: :en)
      expect(builder.language).to eq({ ui: :pl, content: :en })
    end

    it 'sets both UI and content language to same value by default' do
      builder.language(:pl)
      expect(builder.config[:language]).to eq({ ui: :pl, content: :pl })
    end

    it 'allows different UI and content languages' do
      builder.language(:pl, content: :en)
      expect(builder.config[:language]).to eq({ ui: :pl, content: :en })
    end
  end

  describe '#deep_copy_toolbar' do
    context 'with array toolbar' do
      it 'returns duplicated array' do
        original = %i[bold italic]
        copy = builder.send(:deep_copy_toolbar, original)
        expect(copy.object_id).not_to eq(original.object_id)
        expect(copy).to eq(original)
      end
    end

    context 'with hash toolbar' do
      it 'returns deep copy of toolbar config' do
        original = {
          items: %i[bold italic],
          shouldNotGroupWhenFull: true
        }
        copy = builder.send(:deep_copy_toolbar, original)

        expect(copy[:items].object_id).not_to eq(original[:items].object_id)
        expect(copy).to eq(original)
      end
    end

    context 'with nil toolbar' do
      it 'returns empty hash' do
        expect(builder.send(:deep_copy_toolbar, nil)).to eq({})
      end
    end
  end
end
