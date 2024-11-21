# frozen_string_literal: true

module CKEditor5::Rails::Editor::Helpers
  module Config
    def ckeditor5_element_ref(selector)
      { '$element': selector }
    end

    def ckeditor5_preset(name = nil, &block)
      return CKEditor5::Rails::Engine.find_preset(name) if name

      raise ArgumentError, 'Configuration block is required for preset definition' unless block_given?

      CKEditor5::Rails::Presets::PresetBuilder.new(&block)
    end
  end
end
