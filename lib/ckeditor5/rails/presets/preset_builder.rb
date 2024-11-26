# frozen_string_literal: true

require_relative 'concerns/configuration_methods'
require_relative 'concerns/plugin_methods'

module CKEditor5::Rails
  module Presets
    class PresetBuilder
      include Editor::Helpers::Config
      include Concerns::ConfigurationMethods
      include Concerns::PluginMethods

      def initialize(&block)
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

      def premium?
        @premium
      end

      def gpl?
        license_key == 'GPL'
      end

      def deconstruct_keys(keys)
        keys.index_with do |key|
          public_send(key)
        end
      end

      def override(&block)
        clone.tap do |preset|
          preset.instance_eval(&block)
        end
      end

      def merge_with_hash!(language: nil, **overrides) # rubocop:disable Metrics/AbcSize
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

        language(language) if language

        self
      end

      def editable_height(height = nil)
        return @editable_height if height.nil?

        @editable_height = height
      end

      def ckbox(version = nil, theme: :lark)
        return @ckbox if version.nil?

        @ckbox = {
          version: version,
          theme: theme
        }
      end

      def license_key(license_key = nil)
        return @license_key if license_key.nil?

        @license_key = license_key

        cdn(:cloud) unless gpl?
      end

      def gpl
        license_key('GPL')
        premium(false)
      end

      def premium(premium = nil)
        return @premium if premium.nil?

        @premium = premium
      end

      def translations(*translations)
        return @translations if translations.empty?

        @translations = translations
      end

      def version(version = nil)
        return @version&.to_s if version.nil?

        if @automatic_upgrades && version
          detected = VersionDetector.latest_safe_version(version)
          @version = Semver.new(detected || version)
        else
          @version = Semver.new(version)
        end
      end

      def automatic_upgrades(enabled: true)
        @automatic_upgrades = enabled
      end

      def automatic_upgrades?
        @automatic_upgrades
      end

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

      def type(type = nil)
        return @type if type.nil?
        raise ArgumentError, "Invalid editor type: #{type}" unless Editor::Props.valid_editor_type?(type)

        @type = type
      end

      def menubar(visible: true)
        config[:menuBar] = {
          isVisible: visible
        }
      end

      def menubar?
        config.dig(:menuBar, :isVisible) || false
      end

      def toolbar(*items, should_group_when_full: true, &block)
        if @config[:toolbar].blank? || !items.empty?
          @config[:toolbar] = {
            items: items,
            shouldNotGroupWhenFull: !should_group_when_full
          }
        end

        builder = ToolbarBuilder.new(@config[:toolbar][:items])
        builder.instance_eval(&block) if block_given?
        builder
      end

      def language(ui = nil, content: ui) # rubocop:disable Naming/MethodParameterName
        return config[:language] if ui.nil?

        @translations << ui.to_sym unless @translations.map(&:to_sym).include?(ui.to_sym)

        config[:language] = {
          ui: ui,
          content: content
        }
      end

      def simple_upload_adapter(upload_url = '/uploads')
        plugins do
          remove(:Base64UploadAdapter)
        end

        plugin(Plugins::SimpleUploadAdapter.new)
        configure(:simpleUpload, { uploadUrl: upload_url })
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
