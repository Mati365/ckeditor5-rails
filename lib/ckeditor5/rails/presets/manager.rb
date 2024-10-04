# frozen_string_literal: true

require_relative 'preset_builder'
require_relative 'toolbar_builder'

module CKEditor5::Rails::Presets
  class Manager
    attr_reader :presets

    def initialize
      @presets = {}
      define_default_preset
    end

    def define(name, &block)
      preset = PresetBuilder.new
      preset.instance_eval(&block)
      @presets[name] = preset
    end

    def override(name, &block)
      @presets[name].instance_eval(&block)
    end

    def default
      @presets[:default] || {}
    end

    def [](name)
      @presets[name] || {}
    end

    private

    def define_default_preset # rubocop:disable Metrics/MethodLength
      define :default do
        gpl
        type :classic
        menubar

        toolbar :undo, :redo, :|, :heading, :|, :bold, :italic, :underline, :|,
                :link, :insertImage, :mediaEmbed, :insertTable, :blockQuote, :|,
                :bulletedList, :numberedList, :todoList, :outdent, :indent

        plugins :AccessibilityHelp, :Autoformat, :AutoImage, :Autosave,
                :BlockQuote, :Bold, :CloudServices,
                :Essentials, :Heading, :ImageBlock, :ImageCaption, :ImageInline,
                :ImageInsert, :ImageInsertViaUrl, :ImageResize, :ImageStyle,
                :ImageTextAlternative, :ImageToolbar, :ImageUpload, :Indent,
                :IndentBlock, :Italic, :Link, :LinkImage, :List, :ListProperties,
                :MediaEmbed, :Paragraph, :PasteFromOffice, :PictureEditing,
                :SelectAll, :Table, :TableCaption, :TableCellProperties,
                :TableColumnResize, :TableProperties, :TableToolbar,
                :TextTransformation, :TodoList, :Underline, :Undo, :Base64UploadAdapter

        configure :image, {
          toolbar: ['imageTextAlternative', 'imageStyle:inline', 'imageStyle:block', 'imageStyle:side']
        }
      end
    end
  end
end
