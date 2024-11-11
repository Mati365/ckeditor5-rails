# frozen_string_literal: true

module CKEditor5::Rails::Hooks
  module Form
    class EditorInputBuilder
      def initialize(object_name, object, template)
        @object_name = object_name
        @object = object
        @template = template
      end

      def build_editor(method, options = {})
        html_options = build_html_options(method, options)
        add_validation_classes!(method, html_options)
        @template.ckeditor5_editor(**html_options)
      end

      private

      attr_reader :object_name, :object, :template

      def build_html_options(method, options)
        {
          name: build_field_name(method, options),
          initial_data: fetch_initial_data(method, options),
          id: options[:id] || "#{object_name}_#{method}".parameterize,
          **options
        }
      end

      def build_field_name(method, options)
        return options[:as] || method.to_s if object_name.blank?

        "#{object_name}[#{options[:as] || method}]"
      end

      def fetch_initial_data(method, options)
        return object.send(method) if object.respond_to?(method)

        options[:initial_data]
      end

      def add_validation_classes!(method, html_options)
        return unless object.respond_to?(:errors) && object.errors[method].present?

        html_options[:class] = [html_options[:class], 'is-invalid'].compact.join(' ')
      end
    end

    module FormBuilderExtension
      def ckeditor5(method, options = {})
        EditorInputBuilder.new(object_name, object, @template)
                          .build_editor(method, options)
      end
    end
  end
end
