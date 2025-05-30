# frozen_string_literal: true

CKEditor5::Rails.configure do
  version '45.1.0'

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
    version '45.1.0'

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
    version '45.1.0'

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

    version '45.1.0'

    editable_height 260

    ckbox '2.6.0', theme: :lark

    toolbar :sourceEditing, :|, :heading, :|, :alignment, :bold, :italic, :underline, :strikethrough,
            :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
            :fontFamily, :fontSize, :|, :link, :anchor, :|,
            :fontColor, :fontBackgroundColor

    plugins :Essentials, :Heading, :Paragraph, :Bold, :Italic, :Underline, :Strikethrough,
            :Subscript, :Superscript, :RemoveFormat, :List, :Link, :Font, :Alignment,
            :FontFamily, :FontSize, :FontColor, :FontBackgroundColor, :SourceEditing, :Essentials, :Paragraph,
            :Image, :ImageUpload, :ImageToolbar, :ImageInsert,
            :ImageInsertViaUrl, :ImageBlock, :ImageCaption, :ImageInline, :ImageResize

    simple_upload_adapter

    custom_translations :en, {
      'Source' => I18n.t('source'),
      'Heading 1' => I18n.t('heading_1'),
      'Heading 2' => I18n.t('heading_2'),
      'Heading 3' => I18n.t('heading_3'),
      'Heading 4' => I18n.t('heading_4')
    }

    configure :heading, {
      options: [
        { model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph' },
        { model: 'heading1', view: 'h1', title: ckeditor5_translation_ref('Heading 1'),
          class: 'ck-heading_heading1' },
        { model: 'heading2', view: 'h2', title: ckeditor5_translation_ref('Heading 2'),
          class: 'ck-heading_heading2' },
        { model: 'heading3', view: 'h3', title: ckeditor5_translation_ref('Heading 3'),
          class: 'ck-heading_heading3' },
        { model: 'heading4', view: 'h4', title: ckeditor5_translation_ref('Heading 4'),
          class: 'ck-heading_heading4' }
      ]
    }

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

    version '45.1.0'

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
