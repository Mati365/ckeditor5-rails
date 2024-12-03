# frozen_string_literal: true

require_relative '../semver'
require_relative '../editor/props'
require_relative '../editor/helpers/config_helpers'
require_relative '../presets/manager'
require_relative '../assets/assets_bundle_html_serializer'

require_relative 'url_generator'
require_relative 'ckeditor_bundle'
require_relative 'ckbox_bundle'
require_relative 'concerns/bundle_builder'

module CKEditor5::Rails
  module Cdn::Helpers
    include Cdn::Concerns::BundleBuilder
    include ActionView::Helpers::TagHelper

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
    #   - lazy: Enable lazy loading of dependencies (slower but useful for async partials)
    #   - importmap: Whether to use importmap for dependencies (default: true)
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
      lazy: false,
      **kwargs
    )
      ensure_importmap_not_rendered!

      mapped_preset = merge_with_editor_preset(preset, **kwargs)
      bundle = create_preset_bundle(mapped_preset)

      @__ckeditor_context = {
        license_key: mapped_preset.license_key,
        bundle: bundle,
        preset: mapped_preset
      }

      build_assets_html_tags(bundle, importmap: importmap, lazy: lazy)
    end

    # Helper for dynamically loading CKEditor assets when working with Turbo/Stimulus.
    # Adds importmap containing imports from all presets and includes only web component
    # initialization code. Useful when dynamically adding editors to the page with
    # unknown preset configuration.
    #
    # @note Do not use this helper if ckeditor5_assets is already included on the page
    #       as it will cause duplicate imports.
    #
    # @example With Turbo/Stimulus dynamic editor loading
    #   <%= ckeditor5_lazy_javascript_tags %>
    #
    def ckeditor5_lazy_javascript_tags
      ensure_importmap_not_rendered!

      if importmap_available?
        @__ckeditor_context = {
          bundle: combined_bundle
        }

        return Assets::WebComponentBundle.instance.to_html
      end

      safe_join([
                  Assets::AssetsImportMap.new(combined_bundle).to_html,
                  Assets::WebComponentBundle.instance.to_html
                ])
    end

    # Dynamically generates helper methods for each third-party CDN provider.
    # These methods are shortcuts for including CKEditor assets from specific CDNs.
    # Generated methods follow the pattern: ckeditor5_<cdn>_assets
    #
    # @example Using JSDelivr CDN
    #   <%= ckeditor5_jsdelivr_assets %>
    #
    # @example Using UNPKG CDN with version
    #   <%= ckeditor5_unpkg_assets version: '34.1.0' %>
    #
    # @example Using JSDelivr CDN with custom options
    #   <%= ckeditor5_jsdelivr_assets preset: :custom, translations: [:pl] %>
    Cdn::UrlGenerator::CDN_THIRD_PARTY_GENERATORS.each_key do |key|
      define_method(:"ckeditor5_#{key.to_s.parameterize}_assets") do |**kwargs|
        ckeditor5_assets(**kwargs.merge(cdn: key))
      end
    end

    private

    def combined_bundle
      acc = Assets::AssetsBundle.new(scripts: [], stylesheets: [])

      Engine.presets.to_h.values.each_with_object(acc) do |preset, bundle|
        bundle << create_preset_bundle(preset)
      end

      acc
    end

    def merge_with_editor_preset(preset, language: nil, **kwargs)
      found_preset = Engine.find_preset!(preset)
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

    def importmap_available?
      respond_to?(:importmap_rendered?)
    end

    def ensure_importmap_not_rendered!
      return unless importmap_available? && importmap_rendered?

      raise ImportmapAlreadyRenderedError,
            'CKEditor5 assets must be included before javascript_importmap_tags. ' \
            'Please move ckeditor5_assets helper before javascript_importmap_tags in your layout.'
    end

    def build_assets_html_tags(bundle, importmap:, lazy: nil)
      serializer = Assets::AssetsBundleHtmlSerializer.new(
        bundle,
        importmap: importmap && !importmap_available?,
        lazy: lazy
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
