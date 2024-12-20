# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CKEditor5::Rails::Cdn::Helpers do
  let(:test_class) do
    Class.new do
      include CKEditor5::Rails::Cdn::Helpers

      def importmap_rendered?
        false
      end

      def content_security_policy_nonce
        'test-nonce'
      end
    end
  end

  let(:helper) { test_class.new }
  let(:preset) do
    CKEditor5::Rails::Presets::PresetBuilder.new do
      version '34.1.0'
      type :classic
      translations :pl
      cdn :cloud
      license_key nil
      premium false
    end
  end

  let(:context) do
    helper.instance_variable_get(:@__ckeditor_context)
  end

  let(:bundle_html) { '<script src="test.js"></script>' }
  let(:serializer) do
    instance_double(CKEditor5::Rails::Assets::AssetsBundleHtmlSerializer, to_html: bundle_html)
  end

  before do
    allow(CKEditor5::Rails::Engine).to receive(:find_preset!).and_return(preset)
    allow(CKEditor5::Rails::Assets::AssetsBundleHtmlSerializer).to receive(:new).and_return(serializer)
  end

  after do
    RSpec::Mocks.space.proxy_for(CKEditor5::Rails::Engine).reset
    RSpec::Mocks.space.proxy_for(CKEditor5::Rails::Assets::AssetsBundleHtmlSerializer).reset
  end

  describe '#ckeditor5_assets' do
    context 'with valid preset' do
      it 'creates base bundle' do
        expect(CKEditor5::Rails::Cdn::CKEditorBundle).to receive(:new)
          .with(
            instance_of(CKEditor5::Rails::Semver),
            'ckeditor5',
            translations: %i[pl en],
            cdn: :cloud
          )
          .and_call_original

        helper.ckeditor5_assets(preset: :default)
      end

      context 'with premium features' do
        let(:preset) do
          CKEditor5::Rails::Presets::PresetBuilder.new do
            version '34.1.0'
            type :classic
            translations :pl
            cdn :cloud
            premium true
          end
        end

        it 'creates base and premium bundles' do
          expect(CKEditor5::Rails::Cdn::CKEditorBundle).to receive(:new)
            .with(
              instance_of(CKEditor5::Rails::Semver),
              'ckeditor5',
              translations: %i[pl en],
              cdn: :cloud
            )
            .and_call_original
            .ordered

          expect(CKEditor5::Rails::Cdn::CKEditorBundle).to receive(:new)
            .with(
              instance_of(CKEditor5::Rails::Semver),
              'ckeditor5-premium-features',
              translations: %i[pl en],
              cdn: :cloud
            )
            .and_call_original
            .ordered

          helper.ckeditor5_assets(preset: :default)
        end
      end

      context 'with ckbox' do
        let(:preset) do
          CKEditor5::Rails::Presets::PresetBuilder.new do
            version '34.1.0'
            type :classic
            translations :pl
            cdn :cloud
            ckbox '1.0.0', theme: :lark
          end
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

      context 'with plugins having preload assets' do
        let(:plugin_bundle) { CKEditor5::Rails::Assets::AssetsBundle.new(scripts: ['plugin.js']) }
        let(:plugin) { instance_double('Plugin', preload_assets_bundle: plugin_bundle) }
        let(:plugin_without_preload) { instance_double('Plugin', preload_assets_bundle: nil) }

        before do
          allow(preset).to receive_message_chain(:plugins, :items)
            .and_return([plugin, plugin_without_preload])
        end

        it 'includes plugin preload assets in the bundle' do
          helper.ckeditor5_assets(preset: :default)
          expect(context[:bundle].scripts).to include('plugin.js')
        end

        it 'merges plugin assets with the main bundle' do
          expect(serializer).to receive(:to_html)
          helper.ckeditor5_assets(preset: :default)

          bundle = context[:bundle]
          expect(bundle.scripts).to include('plugin.js')
        end
      end
    end

    context 'when overriding preset values' do
      let(:preset) do
        CKEditor5::Rails::Presets::PresetBuilder.new do
          version '34.1.0'
          type :classic
          language :pl
          cdn :cloud
          license_key 'preset-license'
          premium false
        end
      end

      it 'allows overriding preset values' do
        helper.ckeditor5_assets(preset: :default, license_key: 'overridden-license')

        expect(context[:preset].license_key).to eq('overridden-license')
      end

      it 'preserves non-overridden preset values' do
        helper.ckeditor5_assets(preset: :default, license_key: 'overridden-license')
        preset_context = context[:preset]

        expect(preset_context.version).to eq('34.1.0')
        expect(preset_context.premium?).to be false
        expect(preset_context.cdn).to eq(:cloud)
        expect(preset_context.translations).to eq(%i[en pl])
        expect(preset_context.type).to eq(:classic)
      end

      it 'allows to override language using language parameter' do
        preset.language(:en)
        helper.ckeditor5_assets(preset: :default, language: :pl)

        expect(context[:preset].language).to eq({ ui: :pl, content: :pl })
      end

      it 'should not override language if it\'s specified in preset and not passed to helper' do
        preset.language(:en)
        helper.ckeditor5_assets(preset: :default)

        expect(context[:preset].language).to eq({ ui: :en, content: :en })
      end

      it 'should use I18n.locale as default language if it\'s not specified in preset' do
        preset.configure :language, nil

        allow(I18n).to receive(:locale).and_return(:pl)

        helper.ckeditor5_assets(preset: :default)

        expect(context[:preset].language).to eq({ ui: :pl, content: :pl })
      end
    end

    context 'with missing required parameters' do
      before do
        allow(helper).to receive(:merge_with_editor_preset).and_return({})
      end

      it 'raises error about missing required parameters' do
        expect { helper.ckeditor5_assets(preset: :default) }
          .to raise_error(NoMatchingPatternKeyError)
      end
    end

    context 'destructure non-matching preset override' do
      before do
        RSpec::Mocks.space.proxy_for(CKEditor5::Rails::Engine).reset
      end

      it 'raises error' do
        expect { helper.ckeditor5_assets(preset: :invalid) }
          .to raise_error(CKEditor5::Rails::PresetNotFoundError)
        RSpec::Mocks.space.proxy_for(CKEditor5::Rails::Engine).reset
      end
    end

    context 'with empty preset' do
      let(:preset) { CKEditor5::Rails::Presets::PresetBuilder.new }

      it 'raises error about missing version and type' do
        expect { helper.ckeditor5_assets(preset: :default) }
          .to raise_error(ArgumentError, /forgot to define version/)
      end
    end

    context 'when Rails.application.importmap is defined' do
      before do
        allow(helper).to receive(:importmap_available?).and_return(true)
        allow(helper).to receive(:importmap_rendered?).and_return(false)
      end

      it 'returns nil and stores html tags in context' do
        result = helper.ckeditor5_assets(preset: :default)
        expect(result).to be_nil
        expect(context[:html_tags]).to eq(bundle_html)
      end

      it 'raise exception if importmap_rendered?' do
        allow(helper).to receive(:importmap_rendered?).and_return(true)
        expect { helper.ckeditor5_assets(preset: :default) }
          .to raise_error(CKEditor5::Rails::Cdn::Helpers::ImportmapAlreadyRenderedError)
      end
    end

    context 'when importmap_available? is true returns html' do
      before do
        allow(helper).to receive(:importmap_available?).and_return(nil)
      end

      it 'returns html directly' do
        result = helper.ckeditor5_assets(preset: :default)
        expect(result).to eq(bundle_html)
        expect(context[:html_tags]).to be_nil
      end
    end
  end

  describe '#ckeditor5_lazy_javascript_tags' do
    let(:web_component_html) do
      '<script type="module" src="web-component.js">web component code</script>'.html_safe
    end

    let(:import_map_html) { '<script type="importmap">{"imports":{}}</script>'.html_safe }

    let(:web_component_bundle) do
      instance_double(CKEditor5::Rails::Assets::WebComponentBundle, to_html: web_component_html)
    end
    let(:import_map_bundle) do
      instance_double(CKEditor5::Rails::Assets::AssetsImportMap, to_html: import_map_html)
    end
    let(:preset_manager) { instance_double(CKEditor5::Rails::Presets::Manager) }
    let(:test_preset1) { instance_double(CKEditor5::Rails::Presets::PresetBuilder) }
    let(:test_preset2) { instance_double(CKEditor5::Rails::Presets::PresetBuilder) }

    before do
      allow(CKEditor5::Rails::Assets::WebComponentBundle).to receive(:instance).and_return(
        web_component_bundle
      )

      allow(CKEditor5::Rails::Assets::AssetsImportMap).to receive(:new).and_return(
        import_map_bundle
      )

      allow(CKEditor5::Rails::Engine).to receive(:presets).and_return(preset_manager)
      allow(preset_manager).to receive(:to_h).and_return({
                                                           test1: test_preset1,
                                                           test2: test_preset2
                                                         })

      allow(helper).to receive(:create_preset_bundle).with(test_preset1)
                                                     .and_return(CKEditor5::Rails::Assets::AssetsBundle.new(
                                                                   scripts: ['test1.js']
                                                                 ))

      allow(helper).to receive(:create_preset_bundle).with(test_preset2)
                                                     .and_return(CKEditor5::Rails::Assets::AssetsBundle.new(
                                                                   scripts: ['test2.js']
                                                                 ))
    end

    context 'when importmap is available' do
      before do
        allow(helper).to receive(:importmap_available?).and_return(true)
        allow(helper).to receive(:importmap_rendered?).and_return(false)
      end

      it 'stores bundle in context and returns web component script' do
        result = helper.ckeditor5_lazy_javascript_tags

        expect(result).to have_tag('script', with: {
                                     type: 'module',
                                     src: 'web-component.js'
                                   })
        expect(context[:bundle].scripts).to match_array(['test1.js', 'test2.js'])
      end

      it 'raises error when importmap is already rendered' do
        allow(helper).to receive(:importmap_rendered?).and_return(true)

        expect { helper.ckeditor5_lazy_javascript_tags }
          .to raise_error(CKEditor5::Rails::Cdn::Helpers::ImportmapAlreadyRenderedError)
      end
    end

    context 'when importmap is not available' do
      before do
        allow(helper).to receive(:importmap_available?).and_return(false)
      end

      it 'returns both importmap and web component scripts as one string' do
        result = helper.ckeditor5_lazy_javascript_tags

        expect(result).to have_tag('script', with: { type: 'importmap' },
                                             text: '{"imports":{}}')

        expect(result).to have_tag('script', with: {
                                     type: 'module',
                                     src: 'web-component.js'
                                   })
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
