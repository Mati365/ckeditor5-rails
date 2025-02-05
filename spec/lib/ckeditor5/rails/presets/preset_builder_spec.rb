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
      expect(copy.config[:toolbar][:shouldNotGroupWhenFull]).to eq(
        original.config[:toolbar][:shouldNotGroupWhenFull]
      )

      # Compare plugin names
      copy_names = copy.config[:plugins].map { |p| p.name.to_s }
      original_names = original.config[:plugins].map { |p| p.name.to_s }
      expect(copy_names).to eq(original_names)
    end
  end

  describe '#override' do
    it 'returns a new instance with overridden values' do
      builder.version '35.0.0'
      builder.translations :en, :pl

      overridden = builder.override do
        version '36.0.0'
        translations :de
      end

      expect(builder.version).to eq('35.0.0')
      expect(overridden.version).to eq('36.0.0')
      expect(overridden.translations).to eq([:de])
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

      it 'doesn\'t override existing toolbar if no items provided' do
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

      it 'returns ToolbarBuilder instance if no block provided' do
        expect(builder.toolbar).to be_a(CKEditor5::Rails::Presets::ToolbarBuilder)
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

      it 'returns PluginsBuilder instance if no block provided' do
        expect(builder.plugins).to be_a(CKEditor5::Rails::Presets::PluginsBuilder)
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

    describe '#block_toolbar' do
      it 'configures block toolbar items' do
        builder.block_toolbar(:heading, :paragraph, should_group_when_full: false)
        expect(builder.config[:blockToolbar]).to eq({
                                                      items: %i[heading paragraph],
                                                      shouldNotGroupWhenFull: true
                                                    })
      end

      it 'accepts a configuration block' do
        builder.block_toolbar do
          append :table
          remove :paragraph
        end
        expect(builder.config[:blockToolbar][:items]).to include(:table)
      end

      it 'returns ToolbarBuilder instance if no block provided' do
        expect(builder.block_toolbar).to be_a(CKEditor5::Rails::Presets::ToolbarBuilder)
      end
    end

    describe '#balloon_toolbar' do
      it 'configures balloon toolbar items' do
        builder.balloon_toolbar(:bold, :italic, should_group_when_full: false)
        expect(builder.config[:balloonToolbar]).to eq({
                                                        items: %i[bold italic],
                                                        shouldNotGroupWhenFull: true
                                                      })
      end

      it 'accepts a configuration block' do
        builder.balloon_toolbar do
          append :textColor
          remove :italic
        end
        expect(builder.config[:balloonToolbar][:items]).to include(:textColor)
      end

      it 'returns ToolbarBuilder instance if no block provided' do
        expect(builder.balloon_toolbar).to be_a(CKEditor5::Rails::Presets::ToolbarBuilder)
      end
    end
  end

  describe '#inline_plugin' do
    let(:plugin_code) do
      <<~JAVASCRIPT
        const { Plugin } = await import( 'ckeditor5' );

        return class CustomPlugin extends Plugin {
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
      expect(plugin.code).to eq(
        '(async()=>{const{Plugin:t}=await import("ckeditor5");return class i extends t{init(){}}})();'
      )
    end

    it 'allows multiple inline plugins' do
      builder.inline_plugin(:Plugin1, plugin_code)
      builder.inline_plugin(:Plugin2, plugin_code)

      plugin_names = builder.config[:plugins].map(&:name)
      expect(plugin_names).to eq(%i[Plugin1 Plugin2])
    end

    it 'should raise UnsupportedESModuleError when ES module is passed' do
      expect do
        builder.inline_plugin(:CustomPlugin, 'export default class CustomPlugin {}')
      end.to raise_error(CKEditor5::Rails::Presets::Concerns::PluginMethods::UnsupportedESModuleError)
    end

    it 'should raise MissingInlinePluginError when plugin code is invalid' do
      expect do
        builder.inline_plugin(:CustomPlugin, 'return class CustomPlugin {}')
      end.to raise_error(CKEditor5::Rails::Presets::Concerns::PluginMethods::MissingInlinePluginError)
    end
  end

  describe '#plugin' do
    it 'adds normalized plugin to config' do
      plugin = builder.plugin('Test')

      expect(builder.config[:plugins]).to include(plugin)
      expect(plugin).to be_a(CKEditor5::Rails::Editor::PropsPlugin)
    end

    it 'accepts plugin options' do
      plugin = builder.plugin('Test', premium: true)

      expect(plugin.to_h[:import_name]).to eq('ckeditor5-premium-features')
    end

    it 'sets premium flag when premium option provided' do
      builder.plugin('Test', premium: true)
      expect(builder.premium?).to be true
    end
  end

  describe '#external_plugin' do
    it 'adds external plugin to config' do
      plugin = builder.external_plugin('Test', script: 'https://example.org/script.js')

      expect(builder.config[:plugins]).to include(plugin)
      expect(plugin).to be_a(CKEditor5::Rails::Editor::PropsExternalPlugin)
    end

    it 'accepts plugin options' do
      plugin = builder.external_plugin(
        'Test',
        script: 'https://example.org/script.js',
        import_as: 'ABC',
        stylesheets: ['https://example.org/style.css']
      )

      expect(plugin.to_h[:import_name]).to eq('https://example.org/script.js')
      expect(plugin.to_h[:import_as]).to eq('ABC')
      expect(plugin.to_h[:stylesheets]).to include('https://example.org/style.css')
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

  describe '#merge_with_hash!' do
    it 'merges hash with current configuration' do
      builder.merge_with_hash!(version: '32.0.0', type: :inline)
      expect(builder.version).to eq('32.0.0')
      expect(builder.type).to eq(:inline)
    end

    it 'returns self' do
      expect(builder.merge_with_hash!(version: '35.0.0')).to eq(builder)
    end

    it 'preserves existing values when not overridden' do
      builder.version '34.0.0'
      builder.translations :en, :pl
      builder.premium true

      builder.merge_with_hash!(type: :inline)

      expect(builder.version).to eq('34.0.0')
      expect(builder.translations).to eq(%i[en pl])
      expect(builder.premium?).to be true
    end

    it 'merges ckbox configuration' do
      builder.merge_with_hash!(ckbox: { version: '1.0.0', theme: :lark })
      expect(builder.ckbox).to eq({ version: '1.0.0', theme: :lark })
    end

    it 'merges config options deeply' do
      original_config = { plugins: [:Essentials], toolbar: { items: [:bold] } }
      new_config = { menuBar: { isVisible: true } }

      builder.merge_with_hash!(config: original_config)
      builder.merge_with_hash!(config: new_config)

      expect(builder.config[:plugins]).to eq([:Essentials])
      expect(builder.config[:toolbar]).to eq({ items: [:bold] })
      expect(builder.config[:menuBar]).to eq({ isVisible: true })
    end
  end

  describe '#language?' do
    it 'returns false when language is not set' do
      expect(builder.language?).to be false
    end

    it 'returns true when language is set' do
      builder.language(:pl)
      expect(builder.language?).to be true
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

    it 'normalizes language codes to lowercase symbols when string provided' do
      builder.language('PL', content: 'EN')
      expect(builder.config[:language]).to eq({ ui: :pl, content: :en })
    end

    it 'adds normalized UI language to translations' do
      builder.language('PL')
      expect(builder.translations).to include(:pl)
      expect(builder.translations).not_to include('PL')
    end

    it 'handles mixed string and symbol inputs' do
      builder.language('PL', content: :EN)
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

  describe 'wproofreader' do
    it 'configures WProofreader plugin' do
      builder.wproofreader(version: '1.0.0', cdn: 'https://cdn.example.com')

      sync_plugin = builder.config[:plugins].first

      expect(sync_plugin).to be_a(CKEditor5::Rails::Plugins::WProofreaderSync)

      plugin = builder.config[:plugins].last

      expect(plugin).to be_a(CKEditor5::Rails::Editor::PropsExternalPlugin)
      expect(plugin.name).to eq(:WProofreader)
      expect(plugin.to_h[:import_name]).to eq('https://cdn.example.com@1.0.0/dist/browser/index.js')
      expect(plugin.to_h[:stylesheets]).to eq(['https://cdn.example.com@1.0.0/dist/browser/index.css'])
    end

    it 'sets proper editor configuration in wproofreader key' do
      builder.wproofreader(version: '1.0.0', cdn: 'https://cdn.example.com', language: 'en')

      expect(builder.config[:wproofreader]).to eq({ language: 'en' })
    end
  end

  describe '#special_characters' do
    it 'configures special characters with groups and items' do # rubocop:disable Metrics/BlockLength
      builder.special_characters do
        group 'Emoji', label: 'Emoticons' do
          item 'smiley', '😊'
          item 'heart', '❤️'
        end

        group 'Arrows',
              items: [
                { title: 'right', character: '→' },
                { title: 'left', character: '←' }
              ]

        group 'Mixed',
              items: [{ title: 'star', character: '⭐' }],
              label: 'Mixed Characters' do
          item 'heart', '❤️'
        end

        order :Text, :Arrows, :Emoji, :Mixed
      end

      expect(builder.config[:specialCharactersBootstrap]).to eq({
                                                                  groups: [
                                                                    {
                                                                      name: 'Emoji',
                                                                      items: [
                                                                        { title: 'smiley', character: '😊' },
                                                                        { title: 'heart', character: '❤️' }
                                                                      ],
                                                                      options: { label: 'Emoticons' }
                                                                    },
                                                                    {
                                                                      name: 'Arrows',
                                                                      items: [
                                                                        { title: 'right', character: '→' },
                                                                        { title: 'left', character: '←' }
                                                                      ],
                                                                      options: {}
                                                                    },
                                                                    {
                                                                      name: 'Mixed',
                                                                      items: [
                                                                        { title: 'star', character: '⭐' },
                                                                        { title: 'heart', character: '❤️' }
                                                                      ],
                                                                      options: { label: 'Mixed Characters' }
                                                                    }
                                                                  ],
                                                                  order: %w[Text Arrows Emoji Mixed],
                                                                  packs: []
                                                                })

      plugin_names = builder.config[:plugins].map(&:name)
      expect(plugin_names).to include(:SpecialCharacters)
      expect(plugin_names).to include(:SpecialCharactersBootstrap)
    end

    it 'enables special characters packs' do
      builder.special_characters do
        packs :Text, :Mathematical, :Currency
      end

      plugin_names = builder.config[:plugins].map(&:name)
      expect(plugin_names).to include(
        :SpecialCharactersBootstrap,
        :SpecialCharacters,
        'SpecialCharactersText',
        'SpecialCharactersMathematical',
        'SpecialCharactersCurrency'
      )
    end
  end
end
