# frozen_string_literal: true

module CKEditor5::Rails::Builder
  class InitializerTranslations
    attr_reader :bundle

    def initialize(bundle)
      @bundle = bundle
    end

    def esm_imports
      @esm_imports ||= bundle.translations_scripts.map do |script|
        next unless script.translation?

        JsBuilder.create_esm_default_import(
          script.import_name,
          parameterize_import_name(script.import_name)
        )
      end.join("\n")
    end

    def js_config_translations
      return @js_config_translations if defined?(@js_config_translations)

      imports = bundle.translations_scripts.map do |script|
        next unless script.translation?

        parameterize_import_name(script.import_name)
      end

      @js_config_translations = "[ #{imports.join(', ')} ]".delete('"')
    end

    private

    def parameterize_import_name(name)
      name.parameterize.gsub('-', '_').camelize
    end
  end
end
