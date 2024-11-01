# frozen_string_literal: true

module CKEditor5::Rails
  module Presets
    class PresetBuilder
      attr_reader :config

      def initialize
        @version = nil
        @premium = false
        @cdn = :jsdelivr
        @translations = []
        @license_key = nil
        @type = :classic
        @ckbox = nil
        @config = {
          plugins: [],
          toolbar: []
        }
      end

      def to_h_with_overrides(**overrides)
        {
          version: overrides.fetch(:version, version),
          premium: overrides.fetch(:premium, premium),
          cdn: overrides.fetch(:cdn, cdn),
          translations: overrides.fetch(:translations, translations),
          license_key: overrides.fetch(:license_key, license_key),
          type: overrides.fetch(:type, type),
          ckbox: overrides.fetch(:ckbox, ckbox),
          config: config.merge(overrides.fetch(:config, {}))
        }
      end

      def ckbox(version = nil, theme: :lark)
        return @ckbox if version.nil?

        @ckbox = { version: version, theme: theme }
      end

      def license_key(license_key = nil)
        return @license_key if license_key.nil?

        @license_key = license_key
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
        return @version.to_s if version.nil?

        @version = Semver.new(version)
      end

      def cdn(cdn = nil)
        return @cdn if cdn.nil?

        @cdn = cdn
      end

      def type(type = nil)
        return @type if type.nil?
        raise ArgumentError, "Invalid editor type: #{type}" unless Editor::Props.valid_editor_type?(type)

        @type = type
      end

      def configure(key, value)
        @config[key] = value
      end

      def menubar(visible: true)
        @config[:menuBar] = {
          isVisible: visible
        }
      end

      def toolbar(*items, should_group_when_full: true, &block)
        if @config[:toolbar].blank? || !items.empty?
          @config[:toolbar] = {
            items: items,
            shouldNotGroupWhenFull: !should_group_when_full
          }
        end

        return unless block

        builder = ToolbarBuilder.new(@config[:toolbar])
        builder.instance_eval(&block)
      end

      def inline_plugin(name, code)
        @config[:plugins] << Editor::PropsInlinePlugin.new(name, code)
      end

      def plugin(name, **kwargs)
        @config[:plugins] << Editor::PropsPlugin.new(name, **kwargs)
      end

      def plugins(*names, **kwargs)
        names.each { |name| plugin(name, **kwargs) }
      end

      def language(ui, content: ui) # rubocop:disable Naming/MethodParameterName
        @config[:language] = {
          ui: ui,
          content: content
        }
      end
    end
  end
end
