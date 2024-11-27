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
    def ckeditor5_assets(preset: :default, **kwargs)
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

      @__ckeditor_context = {
        license_key: license_key,
        bundle: bundle,
        preset: mapped_preset
      }

      Assets::AssetsBundleHtmlSerializer.new(bundle).to_html
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
  end
end
