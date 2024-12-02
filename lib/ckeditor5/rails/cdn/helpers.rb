# frozen_string_literal: true

require_relative '../semver'
require_relative '../editor/props'
require_relative '../editor/helpers/config_helpers'
require_relative '../presets/manager'
require_relative '../assets/assets_bundle_html_serializer'

require_relative 'url_generator'
require_relative 'ckeditor_bundle'
require_relative 'ckbox_bundle'

module CKEditor5::Rails
  module Cdn::Helpers
    class ImportmapAlreadyRenderedError < ArgumentError; end

    # The `ckeditor5_assets` helper includes CKEditor 5 assets in your application.
    # It's responsible for generating the necessary JavaScript and CSS imports based on
    # the specified preset and configuration.
    #
    # @param [Symbol, PresetBuilder] preset The name of the preset to use (default: :default)
    #   or a PresetBuilder object created using ckeditor5_preset helper
    # @param [Hash] kwargs Additional configuration options:
    #   - version: Specify a custom CKEditor version
    #   - cdn: Select CDN provider (:jsdelivr, :unpkg, etc.)
    #   - translations: Array of language codes to include
    #   - ckbox: Configuration hash for CKBox integration
    #   - license_key: Commercial license key
    #   - premium: Enable premium features
    #   - language: Set editor UI language (e.g. :pl, :es)
    #
    # @example Basic usage with default preset
    #   <%= ckeditor5_assets %>
    #   <%= ckeditor5_editor %>
    #
    # @example Simple editor with custom configuration
    #   <%= ckeditor5_assets preset: :basic %>
    #   <%= ckeditor5_editor toolbar: [:bold, :italic], plugins: [:Bold, :Italic] %>
    #
    # @example Using custom preset with translations and language
    #   <%= ckeditor5_assets preset: :custom, translations: [:pl, :es], language: :pl %>
    #
    # @example Commercial usage with license key
    #   <%= ckeditor5_assets license_key: 'your-license-key' %>
    #
    # @example Using preset builder object
    #   <% @preset = ckeditor5_preset do
    #     version '43.3.1'
    #     toolbar :bold, :italic
    #     plugins :Bold, :Italic
    #   end %>
    #   <%= ckeditor5_assets preset: @preset %>
    #
    # @example Editor only configuration with different types
    #   <%= ckeditor5_assets preset: :basic %>
    #   <%= ckeditor5_editor type: :classic %>
    #   <%= ckeditor5_editor type: :inline %>
    #   <%= ckeditor5_editor type: :balloon %>
    #
    def ckeditor5_assets(
      preset: :default,
      importmap: true,
      **kwargs
    )
      ensure_importmap_not_rendered!

      mapped_preset = merge_with_editor_preset(preset, **kwargs)
      mapped_preset => {
        cdn:,
        version:,
        translations:,
        ckbox:,
        license_key:,
        premium:
      }

      bundle = build_base_cdn_bundle(cdn, version, translations)
      bundle << build_premium_cdn_bundle(cdn, version, translations) if premium
      bundle << build_ckbox_cdn_bundle(ckbox) if ckbox
      bundle << build_plugins_cdn_bundle(mapped_preset.plugins.items)

      @__ckeditor_context = {
        license_key: license_key,
        bundle: bundle,
        preset: mapped_preset
      }

      build_html_tags(bundle, importmap)
    end

    Cdn::UrlGenerator::CDN_THIRD_PARTY_GENERATORS.each_key do |key|
      define_method(:"ckeditor5_#{key.to_s.parameterize}_assets") do |**kwargs|
        ckeditor5_assets(**kwargs.merge(cdn: key))
      end
    end

    private

    def merge_with_editor_preset(preset, language: nil, **kwargs)
      found_preset = Engine.find_preset(preset)

      if found_preset.blank?
        raise ArgumentError,
              "Poor thing. You forgot to define your #{preset} preset. " \
              'Please define it in initializer. Thank you!'
      end

      new_preset = found_preset.clone.merge_with_hash!(**kwargs)

      # Assign default language if not present
      if language.present?
        new_preset.language(language)
      elsif !new_preset.language?
        new_preset.language(I18n.locale)
      end

      %i[version type].each do |key|
        next if new_preset.public_send(key).present?

        raise ArgumentError,
              "Poor thing. You forgot to define #{key}. Make sure you passed `#{key}:` parameter to " \
              "`ckeditor5_assets` or defined default one in your `#{preset}` preset!"
      end

      new_preset
    end

    def build_base_cdn_bundle(cdn, version, translations)
      Cdn::CKEditorBundle.new(
        Semver.new(version),
        'ckeditor5',
        translations: translations,
        cdn: cdn
      )
    end

    def build_premium_cdn_bundle(cdn, version, translations)
      Cdn::CKEditorBundle.new(
        Semver.new(version),
        'ckeditor5-premium-features',
        translations: translations,
        cdn: cdn
      )
    end

    def build_ckbox_cdn_bundle(ckbox)
      Cdn::CKBoxBundle.new(
        Semver.new(ckbox[:version]),
        theme: ckbox[:theme] || :lark,
        cdn: ckbox[:cdn] || :ckbox
      )
    end

    def build_plugins_cdn_bundle(plugins)
      plugins.each_with_object(Assets::AssetsBundle.new(scripts: [], stylesheets: [])) do |plugin, bundle|
        bundle << plugin.preload_assets_bundle if plugin.preload_assets_bundle.present?
      end
    end

    def importmap_available?
      respond_to?(:importmap_rendered?)
    end

    def ensure_importmap_not_rendered!
      return unless importmap_available? && importmap_rendered?

      raise ImportmapAlreadyRenderedError,
            'CKEditor5 assets must be included before javascript_importmap_tags. ' \
            'Please move ckeditor5_assets helper before javascript_importmap_tags in your layout.'
    end

    def build_html_tags(bundle, importmap)
      serializer = Assets::AssetsBundleHtmlSerializer.new(
        bundle,
        importmap: importmap && !importmap_available?
      )

      html = serializer.to_html

      if importmap_available?
        @__ckeditor_context[:html_tags] = html
        nil
      else
        html
      end
    end
  end
end
