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
      # Creates a CKEditor 5 field for the specified form attribute.
      #
      # @param method [Symbol] The model attribute to edit
      # @param options [Hash] Options for customizing the editor
      #
      # @option options [Symbol] :preset (:default) The preset configuration to use
      # @option options [Symbol] :type (:classic) Editor type (classic, inline, balloon, decoupled)
      # @option options [Hash] :config Custom editor configuration
      # @option options [String] :initial_data Initial content for the editor
      # @option options [Boolean] :required (false) Whether the field is required
      # @option options [String] :class CSS classes for the editor
      # @option options [String] :style Inline CSS styles
      #
      # @example Basic usage
      #   <%= form_for @post do |f| %>
      #     <%= f.ckeditor5 :content %>
      #   <% end %>
      #
      # @example With custom styling and required field
      #   <%= form_for @post do |f| %>
      #     <%= f.ckeditor5 :content,
      #           style: 'width: 700px',
      #           required: true,
      #           initial_data: 'Hello World!'
      #     %>
      #   <% end %>
      #
      # @example Using custom preset and type
      #   <%= form_for @post do |f| %>
      #     <%= f.ckeditor5 :content,
      #           preset: :custom,
      #           type: :inline,
      #           class: 'custom-editor'
      #     %>
      #   <% end %>
      #
      # @example Simple Form integration
      #   <%= simple_form_for @post do |f| %>
      #     <%= f.input :content,
      #           as: :ckeditor5,
      #           input_html: { style: 'width: 600px' },
      #           required: true
      #     %>
      #   <% end %>
      def ckeditor5(method, options = {})
        EditorInputBuilder.new(object_name, object, @template)
                          .build_editor(method, options)
      end
    end
  end
end
