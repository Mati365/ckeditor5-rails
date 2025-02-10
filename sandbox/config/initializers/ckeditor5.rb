# frozen_string_literal: true

CKEditor5::Rails.configure do # rubocop:disable Metrics/BlockLength
  version '44.1.0'

  presets.define :custom do
    toolbar :sourceEditing, :undo, :redo, :|, :bold, :italic, :underline, :strikethrough, :subscript,
            :superscript, :removeFormat, :|, :findAndReplace, :selectAll, :|, :heading, :|, :bulletedList,
            :numberedList, :todoList, :outdent, :indent, :|, :alignment, :blockQuote, :link, :insertTable,
            :imageUpload, :horizontalLine, :mediaEmbed, :|,
            :fontFamily, :fontSize, :fontColor, :fontBackgroundColor

    plugins :Essentials, :Paragraph, :Heading, :FindAndReplace, :SelectAll, :Bold, :Italic, :Underline,
            :Strikethrough, :RemoveFormat, :Subscript, :Superscript, :Alignment, :Link, :LinkImage,
            :BlockQuote, :Image, :ImageUpload, :ImageToolbar, :ImageInsert,
            :ImageInsertViaUrl, :ImageBlock, :ImageCaption, :ImageInline, :ImageResize, :HorizontalLine,
            :Table, :TableToolbar, :TableCaption, :TableProperties, :TableCellProperties, :TableColumnResize,
            :List, :ListProperties, :TodoList, :MediaEmbed, :Font, :FontFamily, :FontSize, :FontColor,
            :FontBackgroundColor, :Indent, :IndentBlock, :PasteFromOffice, :AutoImage, :Autosave,
            :CloudServices, :SourceEditing, :TextTransformation
  end

  presets.define :basic, inherit: false do
    version '44.1.0'

    toolbar :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
            :outdent, :indent, :blockQuote, :|, :alignment, :link, :anchor, :|,
            :insertTable, :horizontalLine, :|, :fontFamily, :fontSize, :heading, :|, :fontColor,
            :fontBackgroundColor

    plugins :Essentials, :Paragraph, :Heading, :Bold, :Italic, :Underline, :Strikethrough,
            :Subscript, :Superscript, :RemoveFormat, :FindAndReplace, :SelectAll, :Alignment,
            :List, :Indent, :BlockQuote, :Link, :Table, :TableToolbar, :HorizontalLine,
            :Font, :FontFamily, :FontSize, :FontColor, :FontBackgroundColor, :SourceEditing
  end

  presets.define :grouped_toolbar, inherit: false do
    version '44.1.0'

    toolbar do
      group :text_formatting, label: 'Text Formatting', icon: 'threeVerticalDots' do
        append :bold, :italic, :underline, :strikethrough, separator,
               :subscript, :superscript, :removeFormat
      end

      append separator

      append :bulletedList, :numberedList, :outdent, :indent, :blockQuote
      append :alignment, :link, :anchor, :insertTable, :horizontalLine

      append separator

      append :fontFamily, :fontSize, :heading, :fontColor, :fontBackgroundColor
    end

    plugins :Essentials, :Paragraph, :Heading, :Bold, :Italic, :Underline, :Strikethrough,
            :Subscript, :Superscript, :RemoveFormat, :FindAndReplace, :SelectAll, :Alignment,
            :List, :Indent, :BlockQuote, :Link, :Table, :TableToolbar, :HorizontalLine,
            :Font, :FontFamily, :FontSize, :FontColor, :FontBackgroundColor, :SourceEditing
  end

  presets.define :ultrabasic, inherit: false do
    automatic_upgrades

    version '44.1.0'

    editable_height 100

    ckbox '2.6.0', theme: :lark

    toolbar :sourceEditing, :|, :bold, :italic, :underline, :strikethrough,
            :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
            :fontFamily, :fontSize, :|, :link, :anchor, :|,
            :fontColor, :fontBackgroundColor

    plugins :Essentials, :Paragraph, :Bold, :Italic, :Underline, :Strikethrough,
            :Subscript, :Superscript, :RemoveFormat, :List, :Link, :Font,
            :FontFamily, :FontSize, :FontColor, :FontBackgroundColor, :SourceEditing, :Essentials, :Paragraph

    simple_upload_adapter

    plugin :MyCustomWindowPlugin, window_name: 'MyCustomWindowPlugin'

    inline_plugin 'MyCustomPlugin', <<~JS
      const { Plugin } = await import('ckeditor5');

      return class extends Plugin {
          init() {
            console.info('MyCustomPlugin was initialized');
            window.__customPlugin = true;
          }
      }
    JS
  end

  presets.define :balloon_block, inherit: false do
    automatic_upgrades

    version '44.1.0'

    editable_height 100

    plugins :Essentials, :Paragraph, :Bold, :Italic, :Underline, :Strikethrough,
            :Subscript, :Superscript, :RemoveFormat, :List, :Link, :Font,
            :FontFamily, :FontSize, :FontColor, :FontBackgroundColor, :SourceEditing, :Essentials, :Paragraph,
            :BlockToolbar

    block_toolbar :sourceEditing, :|, :bold, :italic, :underline, :strikethrough,
                  :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
                  :fontFamily, :fontSize, :|, :link, :anchor, :|,
                  :fontColor, :fontBackgroundColor
  end
end
