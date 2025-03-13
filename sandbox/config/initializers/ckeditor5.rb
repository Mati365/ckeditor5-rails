# frozen_string_literal: true

CKEditor5::Rails.configure do
  presets.define :custom do
    version '43.3.0'
    gpl

    toolbar :sourceEditing, :|, :cut, :copy, :|, :undo, :redo, :|,
            :findAndReplace, :selectAll, :|, :bold, :italic, :underline, :strikethrough,
            :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
            :outdent, :indent, :blockQuote, :|, :alignment, :link, :anchor, :|,
            :insertTable, :horizontalLine, :|, :fontFamily, :fontSize, :heading, :|, :fontColor, :fontBackgroundColor, should_group_when_full: false

    plugins :Essentials, :Paragraph, :Heading, :Bold, :Italic, :Underline, :Strikethrough,
            :Subscript, :Superscript, :RemoveFormat, :FindAndReplace, :SelectAll, :Alignment,
            :List, :Indent, :BlockQuote, :Link, :Table, :PlainTableOutput, :TableToolbar, :TableCaption, :TableProperties,
            :TableCellProperties, :HorizontalLine, :Font, :FontFamily, :FontSize,
            :FontColor, :FontBackgroundColor, :SourceEditing, :Indent, :IndentBlock
    translations :de, :en, :es, :fr, :it, :ja, :nl, :pt, :zh

    configure :fontFamily, {
      options: [
        'default',
        'Arial, Helvetica, sans-serif',
        'Calibri',
        'Comic Sans MS, cursive, sans-serif',
        'Courier New, Courier, monospace',
        'Georgia, serif',
        'Lucida Sans Unicode, Lucida Grande, sans-serif',
        'Tahoma, Geneva, sans-serif',
        'Times New Roman, Times, serif',
        'Trebuchet MS, Helvetica, sans-serif',
        'Verdana, Geneva, sans-serif'
      ]
    }

    configure :fontSize, {
      options: [
        'default',
        8,
        9,
        10,
        11,
        12,
        14,
        16,
        18,
        20,
        22,
        24,
        26,
        28,
        36,
        48,
        72
      ]
    }

    configure :heading, {
      options: [
        { model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph' },
        { model: 'heading1', view: 'h1', title: 'Heading 1', class: 'ck-heading_heading1' },
        { model: 'heading2', view: 'h2', title: 'Heading 2', class: 'ck-heading_heading2' },
        { model: 'heading3', view: 'h3', title: 'Heading 3', class: 'ck-heading_heading3' },
        { model: 'heading4', view: 'h4', title: 'Heading 4', class: 'ck-heading_heading4' },
        { model: 'heading5', view: 'h5', title: 'Heading 5', class: 'ck-heading_heading5' },
        { model: 'heading6', view: 'h6', title: 'Heading 6', class: 'ck-heading_heading6' },
        { model: 'formatted', view: 'pre', title: 'Formatted', class: 'ck-heading_formatted' },
        { model: 'address', view: 'address', title: 'Address', class: 'ck-heading_address' },
        { model: 'div', view: 'div', title: 'Normal (DIV)', class: 'ck-heading_div' }
      ]
    }

    configure :table, {
      contentToolbar: %w[
        tableColumn
        tableRow
        mergeTableCells
        tableProperties
        tableCellProperties
        toggleTableCaption
      ]
    }

    configure :link, {
      decorators: {
        openInNewTab: {
          mode: 'manual',
          label: 'Open in a new tab',
          attributes: {
            target: '_blank',
            rel: 'noopener noreferrer'
          }
        }
      }
    }
  end

  presets.define :basic, inherit: false do
    version '43.3.0'
    gpl

    toolbar :sourceEditing, :|, :cut, :copy, :|, :undo, :redo, :|,
            :findAndReplace, :selectAll, :|, :bold, :italic, :underline, :strikethrough,
            :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
            :outdent, :indent, :blockQuote, :|, :alignment, :link, :anchor, :|,
            :insertTable, :horizontalLine, :|, :fontFamily, :fontSize, :heading, :|, :fontColor, :fontBackgroundColor, should_group_when_full: false

    plugins :Essentials, :Paragraph, :Heading, :Bold, :Italic, :Underline, :Strikethrough,
            :Subscript, :Superscript, :RemoveFormat, :FindAndReplace, :SelectAll, :Alignment,
            :List, :Indent, :BlockQuote, :Link, :Table, :TableToolbar, :TableCaption, :TableProperties,
            :TableCellProperties, :HorizontalLine, :Font, :FontFamily, :FontSize,
            :FontColor, :FontBackgroundColor, :SourceEditing, :Indent, :IndentBlock
    translations :de, :en, :es, :fr, :it, :ja, :nl, :pt, :zh

    configure :fontFamily, {
      options: [
        'default',
        'Arial, Helvetica, sans-serif',
        'Calibri',
        'Comic Sans MS, cursive, sans-serif',
        'Courier New, Courier, monospace',
        'Georgia, serif',
        'Lucida Sans Unicode, Lucida Grande, sans-serif',
        'Tahoma, Geneva, sans-serif',
        'Times New Roman, Times, serif',
        'Trebuchet MS, Helvetica, sans-serif',
        'Verdana, Geneva, sans-serif'
      ]
    }

    configure :fontSize, {
      options: [
        'default',
        8,
        9,
        10,
        11,
        12,
        14,
        16,
        18,
        20,
        22,
        24,
        26,
        28,
        36,
        48,
        72
      ]
    }

    configure :heading, {
      options: [
        { model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph' },
        { model: 'heading1', view: 'h1', title: 'Heading 1', class: 'ck-heading_heading1' },
        { model: 'heading2', view: 'h2', title: 'Heading 2', class: 'ck-heading_heading2' },
        { model: 'heading3', view: 'h3', title: 'Heading 3', class: 'ck-heading_heading3' },
        { model: 'heading4', view: 'h4', title: 'Heading 4', class: 'ck-heading_heading4' },
        { model: 'heading5', view: 'h5', title: 'Heading 5', class: 'ck-heading_heading5' },
        { model: 'heading6', view: 'h6', title: 'Heading 6', class: 'ck-heading_heading6' },
        { model: 'formatted', view: 'pre', title: 'Formatted', class: 'ck-heading_formatted' },
        { model: 'address', view: 'address', title: 'Address', class: 'ck-heading_address' },
        { model: 'div', view: 'div', title: 'Normal (DIV)', class: 'ck-heading_div' }
      ]
    }

    configure :table, {
      contentToolbar: %w[
        tableColumn
        tableRow
        mergeTableCells
        tableProperties
        tableCellProperties
        toggleTableCaption
      ]
    }

    configure :link, {
      decorators: {
        openInNewTab: {
          mode: 'manual',
          label: 'Open in a new tab',
          attributes: {
            target: '_blank',
            rel: 'noopener noreferrer'
          }
        }
      }
    }
  end

  presets.define :ultrabasic, inherit: false do
    version '43.3.0'
    gpl

    toolbar :sourceEditing, :|, :bold, :italic, :underline, :strikethrough,
            :subscript, :superscript, :removeFormat, :|, :bulletedList, :numberedList,
            :fontFamily, :fontSize, :|, :link, :anchor, :|,
            :fontColor, :fontBackgroundColor, should_group_when_full: false

    plugins :Essentials, :Paragraph, :Bold, :Italic, :Underline, :Strikethrough,
            :Subscript, :Superscript, :RemoveFormat, :List, :Link, :Font,
            :FontFamily, :FontSize, :FontColor, :FontBackgroundColor, :SourceEditing, :Essentials, :Paragraph

    translations :de, :en, :es, :fr, :it, :ja, :nl, :pt, :zh

    configure :fontFamily, {
      options: [
        'default',
        'Arial, Helvetica, sans-serif',
        'Calibri',
        'Comic Sans MS, cursive, sans-serif',
        'Courier New, Courier, monospace',
        'Georgia, serif',
        'Lucida Sans Unicode, Lucida Grande, sans-serif',
        'Tahoma, Geneva, sans-serif',
        'Times New Roman, Times, serif',
        'Trebuchet MS, Helvetica, sans-serif',
        'Verdana, Geneva, sans-serif'
      ]
    }

    configure :fontSize, {
      options: [
        'default',
        8,
        9,
        10,
        11,
        12,
        14,
        16,
        18,
        20,
        22,
        24,
        26,
        28,
        36,
        48,
        72
      ]
    }

    configure :link, {
      decorators: {
        openInNewTab: {
          mode: 'manual',
          label: 'Open in a new tab',
          attributes: {
            target: '_blank',
            rel: 'noopener noreferrer'
          }
        }
      }
    }
  end

  presets.define :book, inherit: false do
    version '43.3.0'
    gpl

    toolbar :bold, :italic, :underline, :strikethrough, :removeFormat, :|,
            :bulletedList, :numberedList, :|, :fontFamily, :fontSize, :|,
            :alignment, :link, :anchor, :|, :fontColor, :fontBackgroundColor, should_group_when_full: false

    plugins :Essentials, :Paragraph, :Bold, :Italic, :Underline, :Strikethrough,
            :RemoveFormat, :List, :Link, :Font, :FontFamily, :FontSize,
            :FontColor, :FontBackgroundColor, :Alignment

    translations :de, :en, :es, :fr, :it, :ja, :nl, :pt, :zh

    configure :fontFamily, {
      options: [
        'default',
        'Arial, Helvetica, sans-serif',
        'Calibri',
        'Comic Sans MS, cursive, sans-serif',
        'Courier New, Courier, monospace',
        'Georgia, serif',
        'Lucida Sans Unicode, Lucida Grande, sans-serif',
        'Tahoma, Geneva, sans-serif',
        'Times New Roman, Times, serif',
        'Trebuchet MS, Helvetica, sans-serif',
        'Verdana, Geneva, sans-serif'
      ]
    }

    configure :fontSize, {
      options: [
        'default',
        8,
        9,
        10,
        11,
        12,
        14,
        16,
        18,
        20,
        22,
        24,
        26,
        28,
        36,
        48,
        72
      ]
    }

    configure :link, {
      decorators: {
        openInNewTab: {
          mode: 'manual',
          label: 'Open in a new tab',
          attributes: {
            target: '_blank',
            rel: 'noopener noreferrer'
          }
        }
      }
    }
  end

  presets.define :welcome, inherit: false do
    version '43.3.0'
    gpl

    toolbar :undo, :redo, :|, :sourceEditing, :fontFamily, :fontSize, :heading, :|,
            :bold, :italic, :underline, :strikethrough, :removeFormat, :|,
            :fontColor, :fontBackgroundColor, :|, :alignment, :|,
            :link, :|, :bulletedList, :numberedList, :outdent, :indent,
            :blockQuote, :|, :insertImageViaUrl, :fileManager, :|, :mediaEmbed, :insertTable, :horizontalLine, should_group_when_full: false

    plugins :Essentials, :Paragraph, :Bold, :Italic, :Underline, :Strikethrough,
            :RemoveFormat, :Link, :List, :Indent, :BlockQuote, :ImageToolbar,
            :Font, :FontFamily, :FontSize, :FontColor, :FontBackgroundColor,
            :Alignment, :Table, :TableToolbar, :TableCaption, :TableProperties,
            :TableCellProperties, :LinkImage, :MediaEmbed, :Image, :ImageInsert,
            :ImageCaption, :ImageStyle, :ImageResize, :HorizontalLine, :SourceEditing,
            :Heading, :Indent, :IndentBlock

    plugin :FileManagerPlugin, window_name: :imageUpload
    plugin :CustomSimpleUploadAdapter, window_name: :simpleUploadAdapter

    plugins do
      remove(:Base64UploadAdapter)
    end

    configure :simpleUpload, {
      uploadUrl: '/ckeditor/pictures'
    }

    translations :de, :en, :es, :fr, :it, :ja, :nl, :pt, :zh

    configure :fontFamily, {
      options: [
        'default',
        'Arial, Helvetica, sans-serif',
        'Calibri',
        'Comic Sans MS, cursive, sans-serif',
        'Courier New, Courier, monospace',
        'Georgia, serif',
        'Lucida Sans Unicode, Lucida Grande, sans-serif',
        'Tahoma, Geneva, sans-serif',
        'Times New Roman, Times, serif',
        'Trebuchet MS, Helvetica, sans-serif',
        'Verdana, Geneva, sans-serif'
      ]
    }

    configure :fontSize, {
      options: [
        'default',
        8,
        9,
        10,
        11,
        12,
        14,
        16,
        18,
        20,
        22,
        24,
        26,
        28,
        36,
        48,
        72
      ]
    }

    configure :heading, {
      options: [
        { model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph' },
        { model: 'heading1', view: 'h1', title: 'Heading 1', class: 'ck-heading_heading1' },
        { model: 'heading2', view: 'h2', title: 'Heading 2', class: 'ck-heading_heading2' },
        { model: 'heading3', view: 'h3', title: 'Heading 3', class: 'ck-heading_heading3' },
        { model: 'heading4', view: 'h4', title: 'Heading 4', class: 'ck-heading_heading4' },
        { model: 'heading5', view: 'h5', title: 'Heading 5', class: 'ck-heading_heading5' },
        { model: 'heading6', view: 'h6', title: 'Heading 6', class: 'ck-heading_heading6' },
        { model: 'formatted', view: 'pre', title: 'Formatted', class: 'ck-heading_formatted' },
        { model: 'address', view: 'address', title: 'Address', class: 'ck-heading_address' },
        { model: 'div', view: 'div', title: 'Normal (DIV)', class: 'ck-heading_div' }
      ]
    }

    configure :link, {
      decorators: {
        openInNewTab: {
          mode: 'manual',
          label: 'Open in a new tab',
          attributes: {
            target: '_blank',
            rel: 'noopener noreferrer'
          }
        }
      }
    }

    configure :table, {
      contentToolbar: %w[
        tableColumn
        tableRow
        mergeTableCells
        tableProperties
        tableCellProperties
        toggleTableCaption
      ]
    }

    configure :mediaEmbed, {
      previewsInData: true
    }

    configure :image, {
      toolbar: [
        'imageStyle:block',
        'imageStyle:side',
        '|',
        'imageStyle:alignLeft', 'imageStyle:alignRight',
        '|',
        'resizeImage',
        '|',
        'toggleImageCaption',
        'imageTextAlternative',
        '|',
        'linkImage'
      ]
    }
  end
end
