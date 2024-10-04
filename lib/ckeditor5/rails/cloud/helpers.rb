# frozen_string_literal: true

module CKEditor5::Rails
  module Cloud
    module Helpers
      def ckeditor5_cloud_assets(license_key:, **kwargs)
        raise 'Cloud assets are not permitted in GPL license!' if license_key == 'GPL'

        ckeditor5_cdn_assets(cdn: :cloud, license_key: license_key, **kwargs)
      end
    end
  end
end
