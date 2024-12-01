# frozen_string_literal: true

module CKEditor5::Rails::Hooks
  module Importmap
    module ImportmapTagsHelper
      def javascript_importmap_tags(entry_point = 'application', importmap: Rails.application.importmap)
        @importmap_rendered = true
        serialized_tags = [
          javascript_importmap_module_preload_tags(importmap, entry_point: entry_point),
          javascript_import_module_tag(entry_point)
        ]

        importmap_json = prepare_importmap_json(importmap)

        process_ckeditor_context(serialized_tags, importmap_json) if @__ckeditor_context.present?
        safe_join(serialized_tags, "\n")
      end

      def importmap_rendered?
        @importmap_rendered
      end

      def reset_importmap_rendered!
        @importmap_rendered = false
      end

      private

      def prepare_importmap_json(importmap)
        importmap.to_json(resolver: self)
      end

      def process_ckeditor_context(serialized_tags, importmap_json)
        bundle = @__ckeditor_context.fetch(:bundle)
        merged_json = merge_ckeditor_importmap(bundle, importmap_json)

        serialized_tags.prepend(javascript_inline_importmap_tag(merged_json))
        serialized_tags.append(@__ckeditor_context[:html_tags])
      end

      def merge_ckeditor_importmap(bundle, base_importmap_json)
        ckeditor_json = CKEditor5::Rails::Assets::AssetsImportMap.new(bundle).to_json
        merge_import_maps_json(ckeditor_json, base_importmap_json)
      end

      def merge_import_maps_json(a_json, b_json)
        a = JSON.parse(a_json)
        b = JSON.parse(b_json)
        a['imports'].merge!(b['imports'])
        a.to_json
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to merge import maps: #{e.message}"
        b_json
      end
    end
  end
end
