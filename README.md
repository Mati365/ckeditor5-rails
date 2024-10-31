# CKEditor 5 Rails Integration

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg?style=flat-square)](https://opensource.org/licenses/MIT)
![Gem Version](https://img.shields.io/gem/v/ckeditor5-rails?style=flat-square)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-green.svg?style=flat-square)](http://makeapullrequest.com)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/mati365/ckeditor5-rails?style=flat-square)
[![GitHub issues](https://img.shields.io/github/issues/mati365/ckeditor5-rails?style=flat-square)](https://github.com/Mati365/ckeditor5-rails/issues)

Unofficial CKEditor 5 Ruby on Rails integration gem. Provides seamless integration of CKEditor 5 with Rails applications through web components and helper methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ckeditor5'
```

## Basic Usage

### Presets

Override default preset configuration:

```rb
# config/initializers/ckeditor5.rb

CKEditor5::Rails::Engine.configure do |config|
  config.presets.override :default do |preset|
    preset.menubar visible: false
  end
end
```

Create new preset:

```rb
# config/initializers/ckeditor5.rb

CKEditor5::Rails::Engine.configure do |config|
  config.presets.define :custom do |preset|
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

# Somewhere in your view

= ckeditor5_editor preset: :custom
```

### CDN Configuration

#### jsDelivr (Default)

```slim
- content_for :head
  = ckeditor5_assets version: '43.2.0'
```

#### unpkg

```slim
- content_for :head
  = ckeditor5_unpkg_assets version: '43.2.0'
```

#### CKEditor Cloud

It's available only for licensed users.

```slim
- content_for :head
  = ckeditor5_assets version: '43.2.0', license_key: 'YOUR-LICENSE-KEY'
```

### Editor type

#### Classic Editor

```slim
- content_for :head
  = ckeditor5_assets version: '43.2.0' # Optional: translations: [ :pl, :es ]

= ckeditor5_editor
```

#### Multiroot Editor

```slim
= ckeditor5_editor type: :multiroot do
  = ckeditor5_toolbar
  br
  = ckeditor5_editable 'editable-a' do
    | This is a toolbar editable
  br
  = ckeditor5_editable 'editable-b'
```

## License

The MIT License (MIT)
Copyright (c) Mateusz Bagiński / Łukasz Modliński

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
