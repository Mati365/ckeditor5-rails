# frozen_string_literal: true

module CKEditor5::Rails
  class PresetsManager
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

    def define_default_preset
      define :default do
        shape :classic

        menubar

        toolbar :undo, :redo, :|, :heading, :|, :bold, :italic, :underline, :|,
                :link, :insertImage, :ckbox, :mediaEmbed, :insertTable, :blockQuote, :|,
                :bulletedList, :numberedList, :todoList, :outdent, :indent

        plugins :AccessibilityHelp, :Autoformat, :AutoImage, :Autosave,
                :BlockQuote, :Bold, :CKBox, :CKBoxImageEdit, :CloudServices,
                :Essentials, :Heading, :ImageBlock, :ImageCaption, :ImageInline,
                :ImageInsert, :ImageInsertViaUrl, :ImageResize, :ImageStyle,
                :ImageTextAlternative, :ImageToolbar, :ImageUpload, :Indent,
                :IndentBlock, :Italic, :Link, :LinkImage, :List, :ListProperties,
                :MediaEmbed, :Paragraph, :PasteFromOffice, :PictureEditing,
                :SelectAll, :Table, :TableCaption, :TableCellProperties,
                :TableColumnResize, :TableProperties, :TableToolbar,
                :TextTransformation, :TodoList, :Underline, :Undo, :Base64UploadAdapter
      end
    end
  end

  class PresetBuilder
    attr_reader :type, :config

    def initialize
      @type = :classic
      @config = {
        plugins: [],
        toolbar: []
      }
    end

    def shape(type)
      raise ArgumentError, "Invalid editor type: #{type}" unless Editor::Props.valid_editor_type?(type)

      @type = type
    end

    def configure(key, value)
      @config[key] = value
    end

    def menubar(visible: true)
      @config[:menuBar] = {
        isVisible: visible
      }
    end

    def toolbar(*items)
      @config[:toolbar] = items
    end

    def plugin(name, premium: false)
      @config[:plugins] << Editor::PropsPlugin.new(name, premium: premium)
    end

    def plugins(*names, premium: false)
      names.each { |name| plugin(name, premium: premium) }
    end

    def language(lang)
      @config[:language] = lang
    end
  end
end
