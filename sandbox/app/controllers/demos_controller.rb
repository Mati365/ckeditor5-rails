# frozen_string_literal: true

class DemosController < ApplicationController
  def index; end
  def classic; end

  def classic_controller_preset
    @preset = ckeditor5_preset do
      version '43.3.0'

      toolbar :sourceEditing, :|, :bold, :italic, :underline, :strikethrough,
              :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
              :fontFamily, :fontSize, :|, :link, :anchor, :|,
              :fontColor, :fontBackgroundColor, :|, :imageUpload

      plugins :Essentials, :Paragraph, :Bold, :Italic, :Underline, :Strikethrough,
              :Subscript, :Superscript, :RemoveFormat, :List, :Link, :Font,
              :FontFamily, :FontSize, :FontColor, :FontBackgroundColor, :SourceEditing, :Essentials,
              :Paragraph, :Base64UploadAdapter

      plugins :Image, :ImageUpload, :ImageToolbar, :ImageInsert,
              :ImageInsertViaUrl, :ImageBlock, :ImageCaption, :ImageInline, :ImageResize,
              :AutoImage, :LinkImage

      simple_upload_adapter
    end
  end

  def decoupled; end
  def form; end
  def multiroot; end
  def context; end
end