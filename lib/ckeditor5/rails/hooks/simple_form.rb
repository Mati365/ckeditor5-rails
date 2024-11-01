# frozen_string_literal: true

module CKEditor5::Rails::Hooks
  module SimpleForm
    class CKEditor5Input < ::SimpleForm::Inputs::Base
      def input(wrapper_options = nil)
        merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
        @builder.template.ckeditor5_editor(**editor_options(merged_input_options))
      end

      private

      def editor_options(merged_input_options)
        {
          preset: input_options.fetch(:preset, :default),
          type: input_options.fetch(:type, :classic),
          config: input_options[:config],
          initial_data: object.try(attribute_name) || input_options[:initial_data],
          name: "#{object_name}[#{attribute_name}]",
          **merged_input_options
        }
      end
    end
  end
end
