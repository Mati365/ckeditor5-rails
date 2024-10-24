# frozen_string_literal: true

module CKEditor5::Rails::Helpers
  def ckeditor5_assets
    javascript_tag(noonce: true) do
      concat "console.log('ssdasd');".html_safe
    end
  end
end
