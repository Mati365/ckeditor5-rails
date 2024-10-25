# frozen_string_literal: true

module CKEditor5::Rails
  module Cloud
    class CKEditor < CKEditorBaseBundle
      def initialize(version, translations = [])
        super(
          version: version,
          translations: translations,
          import_name: 'ckeditor5',
          window_name: 'CKEDITOR'
        )
      end
    end
  end
end
