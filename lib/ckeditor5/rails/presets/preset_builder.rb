# frozen_string_literal: true

require_relative 'concerns/configuration_methods'
require_relative 'concerns/plugin_methods'
require_relative 'special_characters_builder'

module CKEditor5::Rails
  module Presets
    class PresetBuilder
      include Editor::Helpers::Config
      include Concerns::ConfigurationMethods
      include Concerns::PluginMethods

      # @example Basic initialization
      #   PresetBuilder.new do
      #     version '43.3.1'
      #     gpl
      #     type :classic
      #   end
      def initialize(disallow_inline_plugins: false, &block)
        @disallow_inline_plugins = disallow_inline_plugins
        @version = nil
        @premium = false
        @cdn = :jsdelivr
        @translations = [:en]
        @license_key = nil
        @type = :classic
        @ckbox = nil
        @editable_height = nil
        @automatic_upgrades = false
        @config = {
          plugins: [],
          toolbar: []
        }

        instance_eval(&block) if block_given?
      end

      # @example Copy preset and modify it
      #   original = PresetBuilder.new
      #   copied = original.initialize_copy(original)
      def initialize_copy(source)
        super

        @translations = source.translations.dup
        @ckbox = source.ckbox.dup if source.ckbox
        @config = {
          plugins: source.config[:plugins].map(&:dup),
          toolbar: deep_copy_toolbar(source.config[:toolbar])
        }.merge(
          source.config.except(:plugins, :toolbar).deep_dup
        )
      end

      # Check if preset is using premium features
      # @return [Boolean]
      def premium?
        @premium
      end

      # Check if preset is using GPL license
      # @return [Boolean]
      def gpl?
        license_key == 'GPL'
      end

      def deconstruct_keys(keys)
        keys.index_with do |key|
          public_send(key)
        end
      end

      # Create a new preset by overriding current configuration
      # @example Override existing preset
      #   preset.override do
      #     menubar visible: false
      #     toolbar do
      #       remove :underline, :heading
      #     end
      #   end
      # @return [PresetBuilder] New preset instance
      def override(&block)
        clone.tap do |preset|
          preset.instance_eval(&block)
        end
      end

      # Merge preset with configuration hash
      # @param overrides [Hash] Configuration options to merge
      # @return [self]
      def merge_with_hash!(**overrides)
        @version = Semver.new(overrides[:version]) if overrides.key?(:version)
        @premium = overrides.fetch(:premium, premium)
        @cdn = overrides.fetch(:cdn, cdn)
        @translations = overrides.fetch(:translations, translations)
        @license_key = overrides.fetch(:license_key, license_key)
        @type = overrides.fetch(:type, type)
        @editable_height = overrides.fetch(:editable_height, editable_height)
        @automatic_upgrades = overrides.fetch(:automatic_upgrades, automatic_upgrades)
        @ckbox = overrides.fetch(:ckbox, ckbox) if overrides.key?(:ckbox) || ckbox
        @config = config.merge(overrides.fetch(:config, {}))

        self
      end

      # Set or get editable height in pixels
      # @param height [Integer, nil] Height in pixels
      # @example Set editor height to 300px
      #   editable_height 300
      # @return [Integer, nil] Current height value
      def editable_height(height = nil)
        return @editable_height if height.nil?

        @editable_height = height
      end

      # Configure CKBox integration
      # @param version [String, nil] CKBox version
      # @param theme [Symbol] Theme name (:lark)
      # @example Enable CKBox with custom version
      #   ckbox '2.6.0', theme: :lark
      def ckbox(version = nil, theme: :lark)
        return @ckbox if version.nil?

        @ckbox = {
          version: version,
          theme: theme
        }
      end

      # Set or get license key
      # @param license_key [String, nil] License key
      # @example Set commercial license
      #   license_key 'your-license-key'
      # @return [String, nil] Current license key
      def license_key(license_key = nil)
        return @license_key if license_key.nil?

        @license_key = license_key

        cdn(:cloud) unless gpl?
      end

      # Set GPL license and disable premium features
      # @example Enable GPL license
      #   gpl
      def gpl
        license_key('GPL')
        premium(false)
      end

      # Enable or check premium features
      # @param premium [Boolean, nil] Enable/disable premium features
      # @example Enable premium features
      #   premium true
      # @return [Boolean] Premium status
      def premium(premium = nil)
        return @premium if premium.nil?

        @premium = premium
      end

      # Set or get translations
      # @param translations [Array<Symbol>] Language codes
      # @example Add Polish and Spanish translations
      #   translations :pl, :es
      # @return [Array<Symbol>] Current translations
      def translations(*translations)
        return @translations if translations.empty?

        @translations = translations.map { |t| t.to_sym.downcase }
      end

      # Set or get editor version
      # @param version [String, nil] Editor version
      # @example Set specific version
      #   version '43.3.1'
      # @return [String, nil] Current version
      def version(version = nil)
        return @version&.to_s if version.nil?

        if @automatic_upgrades && version
          detected = VersionDetector.latest_safe_version(version)
          @version = Semver.new(detected || version)
        else
          @version = Semver.new(version)
        end
      end

      # Enable or disable automatic version upgrades
      # @param enabled [Boolean] Enable/disable upgrades
      # @example Enable automatic upgrades
      #   automatic_upgrades enabled: true
      def automatic_upgrades(enabled: true)
        @automatic_upgrades = enabled
      end

      # Check if automatic upgrades are enabled
      # @return [Boolean]
      def automatic_upgrades?
        @automatic_upgrades
      end

      # Configure CDN source
      # @param cdn [Symbol, nil] CDN name or custom block
      # @example Use jsDelivr CDN
      #   cdn :jsdelivr
      # @example Custom CDN configuration
      #   cdn do |bundle, version, path|
      #     "https://custom-cdn.com/#{bundle}@#{version}/#{path}"
      #   end
      # @return [Symbol, Proc] Current CDN configuration
      def cdn(cdn = nil, &block)
        return @cdn if cdn.nil? && block.nil?

        if block_given?
          unless block.arity == 3
            raise ArgumentError,
                  'Block must accept exactly 3 arguments: bundle, version, path'
          end

          @cdn = block
        else
          @cdn = cdn
        end
      end

      # Set or get editor type
      # @param type [Symbol, nil] Editor type (:classic, :inline, :balloon, :decoupled)
      # @example Set editor type to inline
      #   type :inline
      # @raise [ArgumentError] If invalid type provided
      # @return [Symbol] Current editor type
      def type(type = nil)
        return @type if type.nil?
        raise ArgumentError, "Invalid editor type: #{type}" unless Editor::Props.valid_editor_type?(type)

        @type = type
      end

      # Configure menubar visibility
      # @param visible [Boolean] Show/hide menubar
      # @example Hide menubar
      #   menubar visible: false
      def menubar(visible: true)
        config[:menuBar] = {
          isVisible: visible
        }
      end

      # Check if menubar is visible
      # @return [Boolean]
      def menubar?
        config.dig(:menuBar, :isVisible) || false
      end

      # Configure toolbar items and grouping
      # @param items [Array<Symbol>] Toolbar items
      # @param should_group_when_full [Boolean] Enable grouping
      # @example Configure toolbar items
      #   toolbar :bold, :italic, :|, :link
      # @example Configure with block
      #   toolbar do
      #     append :selectAll
      #     remove :heading
      #   end
      # @return [ToolbarBuilder] Toolbar configuration
      def toolbar(*items, should_group_when_full: true, type: :toolbar, &block)
        if @config[type].blank? || !items.empty?
          @config[type] = {
            items: items,
            shouldNotGroupWhenFull: !should_group_when_full
          }
        end

        builder = ToolbarBuilder.new(@config[type][:items])
        builder.instance_eval(&block) if block_given?
        builder
      end

      # Configure block toolbar items and grouping
      # @param items [Array<Symbol>] Toolbar items to include
      # @param kwargs [Hash] Additional toolbar configuration options
      # @option kwargs [Boolean] :should_group_when_full Enable/disable toolbar item grouping
      # @yield Optional block for additional toolbar configuration
      # @return [ToolbarBuilder] Toolbar configuration
      # @example Configure block toolbar items
      #   block_toolbar :heading, :paragraph, :blockQuote
      # @example Configure with block
      #   block_toolbar do
      #     append :table
      #     remove :paragraph
      #   end
      def block_toolbar(*items, **kwargs, &block)
        toolbar(*items, **kwargs, type: :blockToolbar, &block)
      end

      # Configure balloon toolbar items and grouping
      # @param items [Array<Symbol>] Toolbar items to include
      # @param kwargs [Hash] Additional toolbar configuration options
      # @option kwargs [Boolean] :should_group_when_full Enable/disable toolbar item grouping
      # @yield Optional block for additional toolbar configuration
      # @return [ToolbarBuilder] Toolbar configuration
      # @example Configure balloon toolbar items
      #   balloon_toolbar :bold, :italic, :link
      # @example Configure with block
      #   balloon_toolbar do
      #     append :textColor
      #     remove :italic
      #   end
      def balloon_toolbar(*items, **kwargs, &block)
        toolbar(*items, **kwargs, type: :balloonToolbar, &block)
      end

      # Check if language is configured
      # @return [Boolean]
      def language?
        config[:language].present?
      end

      # Configure editor language
      # @param ui [Symbol, nil] UI language code
      # @param content [Symbol] Content language code
      # @example Set Polish UI and content language
      #   language :pl
      # @example Different UI and content languages
      #   language :pl, content: :en
      # @return [Hash, nil] Language configuration
      def language(ui = nil, content: ui) # rubocop:disable Naming/MethodParameterName
        return config[:language] if ui.nil?

        # Normalize language codes, as the translation packs used to be in lowercase
        ui = ui.to_sym.downcase
        content = content.to_sym.downcase

        @translations << ui unless @translations.map(&:to_sym).include?(ui)

        config[:language] = {
          ui: ui,
          content: content
        }
      end

      # Configure simple upload adapter
      # @param upload_url [String] Upload endpoint URL
      # @example Enable upload adapter
      #   simple_upload_adapter '/uploads'
      def simple_upload_adapter(upload_url = '/uploads')
        plugins do
          remove(:Base64UploadAdapter)
        end

        plugin(Plugins::SimpleUploadAdapter.new)
        configure(:simpleUpload, { uploadUrl: upload_url })
      end

      # Configure WProofreader plugin
      # @param version [String, nil] Plugin version
      # @param cdn [String, nil] CDN URL
      # @param config [Hash] Plugin configuration
      # @example Basic configuration
      #   wproofreader serviceId: 'your-service-ID',
      #              srcUrl: 'https://svc.webspellchecker.net/spellcheck31/wscbundle/wscbundle.js'
      def wproofreader(version: nil, cdn: nil, **config)
        configure :wproofreader, config
        plugins do
          prepend(Plugins::WProofreaderSync.new)
          append(Plugins::WProofreader.new(version: version, cdn: cdn))
        end
      end

      # Configure special characters plugin
      #
      # @yield Block for configuring special characters
      # @example Basic configuration with block
      #   special_characters do
      #     group 'Emoji', label: 'Emoticons' do
      #       item 'smiley', '😊'
      #       item 'heart', '❤️'
      #     end
      #     order :Text, :Emoji
      #   end
      # @example Configuration with direct items array
      #   special_characters do
      #     group 'Arrows',
      #           items: [
      #             { title: 'right', character: '→' },
      #             { title: 'left', character: '←' }
      #           ]
      #   end
      # @example Mixed configuration
      #   special_characters do
      #     group 'Mixed',
      #           items: [{ title: 'star', character: '⭐' }],
      #           label: 'Mixed Characters' do
      #       item 'heart', '❤️'
      #     end
      #   end
      def special_characters(&block)
        builder = SpecialCharactersBuilder.new
        builder.instance_eval(&block) if block_given?

        plugins do
          append(:SpecialCharacters)
          builder.packs_plugins.each { |pack| append(pack) }
          prepend(Plugins::SpecialCharactersBootstrap.new)
        end

        configure(:specialCharactersBootstrap, builder.to_h)
      end

      private

      def deep_copy_toolbar(toolbar)
        return toolbar.dup if toolbar.is_a?(Array)
        return {} if toolbar.nil?

        {
          items: toolbar[:items].dup,
          shouldNotGroupWhenFull: toolbar[:shouldNotGroupWhenFull]
        }
      end
    end
  end
end
