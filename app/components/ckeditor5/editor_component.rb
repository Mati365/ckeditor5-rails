# frozen_string_literal: true

class Ckeditor5::EditorComponent < ViewComponent::Base
  def initialize(message:)
    super
    @message = message
  end

  def call
    content_tag(:p, @message)
  end
end
