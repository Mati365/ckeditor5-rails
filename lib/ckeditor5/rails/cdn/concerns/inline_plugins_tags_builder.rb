# frozen_string_literal: true

module CKEditor5::Rails
  module Cdn::Concerns
    module InlinePluginsTagsBuilder
      # Includes JavaScript code for inline plugins that use CommonJS module format.
      # This helper generates script tags that initialize plugins before CKEditor loads.
      #
      # @param preset [PresetBuilder, nil] Optional preset to filter plugins from.
      #   If nil, includes plugins from all registered presets.
      # @return [ActiveSupport::SafeBuffer] HTML script tags with plugin initializers
      # @example Including CJS plugins for specific preset
      #   <%= ckeditor5_inline_plugins_tags(@my_preset) %>
      # @example Including CJS plugins from all presets
      #   <%= ckeditor5_inline_plugins_tags %>
      def ckeditor5_inline_plugins_tags(preset = nil)
        plugins = if preset
                    preset.plugins.items
                  else
                    Engine.presets.to_h.values.flat_map { |p| p.plugins.items }
                  end

        # Filter inline plugins and deduplicate by name in one chain
        initializers = plugins
                       .select { |plugin| plugin.is_a?(Editor::PropsInlinePlugin) }
                       .uniq(&:name)
                       .map do |plugin|
          Editor::InlinePluginWindowInitializer.new(plugin).to_html(
            nonce: content_security_policy_nonce
          )
        end

        safe_join(initializers)
      end
    end
  end
end
