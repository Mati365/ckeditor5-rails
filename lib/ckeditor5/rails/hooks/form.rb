# frozen_string_literal: true

module CKEditor5::Rails::Hooks
  module Form
    module FormBuilderExtension
      def ckeditor5(method, options = {})
        value = if object.respond_to?(method)
                  object.send(method)
                else
                  options[:initial_data]
                end

        html_options = options.merge(
          name: object_name,
          required: options.delete(:required),
          initial_data: value
        )

        @template.ckeditor5_editor(**html_options)
      end
    end
  end
end
