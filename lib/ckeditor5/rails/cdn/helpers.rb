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

      build_assets_html_tags(bundle, importmap, lazy: lazy)
    end

    private

    def combined_bundle
      return @combined_bundle if defined?(@combined_bundle)

      acc = Assets::AssetsBundle.new(scripts: [], stylesheets: [])

      Engine.presets.all.each_with_object(acc) do |preset, bundle|
        bundle.scripts.concat(create_preset_bundle(preset).scripts)
      end

      @combined_bundle = acc
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

    def build_assets_html_tags(bundle, importmap, lazy: nil)
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
