# frozen_string_literal: true

module CKEditor5::Rails::Hooks
  module SimpleForm
    # Custom input type for Simple Form integration with CKEditor 5.
    # This class enables seamless integration with Simple Form, allowing use of CKEditor 5
    # as a form input with all its features and configurations.
    #
    # @example Basic usage in a form
    #   <%= simple_form_for @post do |f| %>
    #     <%= f.input :content,
    #       as: :ckeditor5,
    #       input_html: { style: 'width: 600px' },
    #       required: true
    #     %>
    #   <% end %>
    #
    # @example With custom preset and styling
    #   <%= simple_form_for @post do |f| %>
    #     <%= f.input :content,
    #       as: :ckeditor5,
    #       preset: :custom,
    #       type: :inline,
    #       input_html: {
    #         style: 'width: 600px',
    #         class: 'custom-editor',
    #         initial_data: 'Hello!'
    #       }
    #     %>
    #   <% end %>
    #
    # @example With validation and error handling
    #   <%= simple_form_for @post do |f| %>
    #     <%= f.input :content,
    #       as: :ckeditor5,
    #       required: true,
    #       input_html: { style: 'width: 600px' },
    #       error: 'Content cannot be blank'
    #     %>
    #   <% end %>
    class CKEditor5Input < ::SimpleForm::Inputs::Base
      # Renders the CKEditor 5 input field
      # @param wrapper_options [Hash] Options passed from the form wrapper
      # @return [String] Rendered editor HTML
      def input(wrapper_options = nil)
        merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
        @builder.template.ckeditor5_editor(**editor_options(merged_input_options))
      end

      private

      # Builds options hash for the editor
      # @param merged_input_options [Hash] Combined input options
      # @return [Hash] Options for CKEditor instance
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
