# frozen_string_literal: true

module CKEditor5::Rails
  module Editor::ConfigHelpers
    def ckeditor5_element_ref(selector)
      { '$element': selector }
    end
  end
end
