# frozen_string_literal: true

class CKEditor5::Rails::ImportMap
  attr_reader :assets_bundles

  def initialize(assets_bundles = [])
    @assets_bundles = assets_bundles
    validate_assets_bundles!
  end

  def import_map
    @import_map ||= {
      imports: assets_bundles.each_with_object({}) do |bundle, acc|
        acc[bundle.import_name] = bundle.scripts.first
      end
    }
  end

  def import_map_html
    <<~HTML
      <script type="importmap">
        #{import_map.to_json}
      </script>
    HTML
  end

  private

  def validate_assets_bundles!
    assets_bundles.each do |bundle|
      next if bundle.scripts.length == 1

      raise ArgumentError, "Bundle #{bundle.import_name} should have exactly one script"
    end
  end
end
