# frozen_string_literal: true

module CKEditor5::Rails::Editor
  class InvalidEditableHeightError < ArgumentError; end

  class EditableHeightNormalizer
    def initialize(editor_type)
      @editor_type = editor_type
    end

    def normalize(value)
      return nil if value.nil?

      validate_editor_type!
      convert_to_pixel_value(value)
    end

    private

    attr_reader :editor_type

    def validate_editor_type!
      return if editor_type == :classic

      raise InvalidEditableHeightError,
            'editable_height can be used only with ClassicEditor'
    end

    def convert_to_pixel_value(value)
      case value
      when Integer then "#{value}px"
      when String then convert_string_to_pixel_value(value)
      else
        raise_invalid_height_error(value)
      end
    end

    def convert_string_to_pixel_value(value)
      return value if value.match?(/^\d+px$/)

      raise_invalid_height_error(value)
    end

    def raise_invalid_height_error(value)
      raise InvalidEditableHeightError,
            "editable_height must be an integer representing pixels or string ending with 'px'\n" \
            "(e.g. 500 or '500px'). Got: #{value.inspect}"
    end
  end
end
