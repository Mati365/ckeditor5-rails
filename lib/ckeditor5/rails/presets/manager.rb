# frozen_string_literal: true

require_relative 'toolbar_builder'
require_relative 'plugins_builder'
require_relative 'preset_builder'

module CKEditor5::Rails::Presets
  class Manager
    attr_reader :presets

    alias to_h presets

    # Initializes a new Manager instance and sets up the default preset
    def initialize
      @presets = {}
      define_default_preset
    end

    # Define a new preset configuration
    #
    # @param name [Symbol] Name of the preset
    # @param inherit [Boolean] Whether to inherit from default preset
    # @example Define custom preset inheriting from default
    #   presets.define :custom do
    #     menubar visible: false
    #     toolbar :bold, :italic
    #   end
    # @example Define preset from scratch
    #   presets.define :blank, inherit: false do
    #     version '43.3.1'
    #     gpl
    #     type :classic
    #   end
    # @return [PresetBuilder] Created preset instance
    def define(name, inherit: true, &block)
      preset = if inherit && default.present?
                 default.clone
               else
                 PresetBuilder.new
               end

      preset.instance_eval(&block)
      @presets[name] = preset
    end

    # Override existing preset configuration
    #
    # @param name [Symbol] Name of the preset to override
    # @example Override existing preset
    #   presets.override :custom do
    #     menubar visible: false
    #     toolbar do
    #       remove :underline, :heading
    #     end
    #   end
    def override(name, &block)
      @presets[name].instance_eval(&block)
    end

    alias extend override

    # Get the default preset configuration
    # @return [PresetBuilder, nil] Default preset or nil if not defined
    def default
      @presets[:default]
    end

    # Get a preset by name
    # @param name [Symbol] Name of the preset
    # @return [PresetBuilder, nil] Found preset or nil if not found
    def [](name)
      @presets[name]
    end

    private

    # Defines the default preset with common editor settings
    # @example Basic configuration
    #   CKEditor5::Rails.configure do
    #     presets.define :default do
    #       version '43.3.1'
    #       gpl
    #       type :classic
    #       menubar
    #     end
    #   end
    def define_default_preset
      define :default do
        # Set default version from gem constant
        version CKEditor5::Rails::DEFAULT_CKEDITOR_VERSION

        # Enable automatic version upgrades for security patches
        automatic_upgrades

        # Use GPL license and classic editor type
        gpl
        type :classic
        menubar

        # Configure default toolbar items
        toolbar :undo, :redo, :|, :heading, :|, :bold, :italic, :underline, :|,
                :link, :insertImage, :mediaEmbed, :insertTable, :blockQuote, :|,
                :bulletedList, :numberedList, :todoList, :outdent, :indent

        # Configure default plugins
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

        # Configure default image toolbar
        configure :image, {
          toolbar: ['imageTextAlternative', 'imageStyle:inline', 'imageStyle:block', 'imageStyle:side']
        }
      end
    end
  end
end
