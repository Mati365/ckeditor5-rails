# CKEditor 5 Rails Integration

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg?style=flat-square)](https://opensource.org/licenses/MIT)
![Gem Version](https://img.shields.io/gem/v/ckeditor5?style=flat-square)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-green.svg?style=flat-square)](http://makeapullrequest.com)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/mati365/ckeditor5-rails?style=flat-square)
[![GitHub issues](https://img.shields.io/github/issues/mati365/ckeditor5-rails?style=flat-square)](https://github.com/Mati365/ckeditor5-rails/issues)

Unofficial CKEditor 5 Ruby on Rails integration gem. Provides seamless integration of CKEditor 5 with Rails applications through web components and helper methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ckeditor5'
```

## Presets

Presets are predefined configurations of CKEditor 5, allowing quick setup with specific features. The gem includes a `:default` preset with common features like bold, italic, underline, and link for the classic editor.

You can override the default preset or create your own by defining a new preset in the `config/initializers/ckeditor5.rb` file using the `config.presets.define` method.

The example below shows how to define a custom preset with a classic editor and a custom toolbar:

```rb
# config/initializers/ckeditor5.rb

CKEditor5::Rails::Engine.configure do |config|
  config.presets.define :custom
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
```

In order to override existing presets, you can use the `config.presets.override` method. The method takes the name of the preset you want to override and a block with the new configuration. In example below, we override the `:default` preset to hide the menubar.

```rb
# config/initializers/ckeditor5.rb

CKEditor5::Rails::Engine.configure do |config|
  config.presets.override :default do
    menubar visible: false
  end
end
```

You can generate your preset using the CKEditor 5 [online builder](https://ckeditor.com/ckeditor-5/online-builder/). After generating the configuration, you can copy it to the `config/initializers/ckeditor5.rb` file.

### Available Configuration Methods

#### `shape(type)` method

Defines the type of editor. Available options:

- `:classic` - standard editor
- `:inline` - inline editor
- `:balloon` - balloon editor
- `:multiroot` - editor with multiple editing areas

The example below shows how to define a multiroot editor:

```rb
config.presets.define :custom do
  shape :multiroot
end
```

#### `plugins(*names)` method

Defines the plugins to be included in the editor. You can specify multiple plugins by passing their names as arguments.

```rb
config.presets.define :custom do
  plugins :Bold, :Italic, :Underline, :Link
end
```

#### `toolbar(*items, should_group_when_full: true)` method

Defines the toolbar items. You can use predefined items like `:undo`, `:redo`, `:|` or specify custom items. There are a few special items:

- `:_` - breakpoint
- `:|` - separator

The `should_group_when_full` keyword argument determines whether the toolbar should group items when there is not enough space. It's set to `true` by default.

```rb
config.presets.define :custom do
  # ... other configuration

  toolbar :undo, :redo, :|, :heading, :|, :bold, :italic, :underline, :|,
          :link, :insertImage, :ckbox, :mediaEmbed, :insertTable, :blockQuote, :|,
          :bulletedList, :numberedList, :todoList, :outdent, :indent
end
```

Keep in mind that the order of items is important, and you should install the corresponding plugins. You can find the list of available plugins in the [CKEditor 5 documentation](https://ckeditor.com/docs/ckeditor5/latest/framework/architecture/plugins.html).

Defines the toolbar items. You can use predefined items like `:undo`, `:redo`, `:|` or specify custom items. There are few special items:

- `:_` - breakpoint
- `:|` - separator

```rb
config.presets.define :custom do
  # ... other configuration

  toolbar :undo, :redo, :|, :heading, :|, :bold, :italic, :underline, :|,
          :link, :insertImage, :ckbox, :mediaEmbed, :insertTable, :blockQuote, :|,
          :bulletedList, :numberedList, :todoList, :outdent, :indent
end
```

Keep in mind that the order of items is important, and you should install the corresponding plugins. You can find the list of available plugins in the [CKEditor 5 documentation](https://ckeditor.com/docs/ckeditor5/latest/framework/architecture/plugins.html).

#### `menubar(visible: true)` method

Defines the visibility of the menubar. By default, it's set to `true`.

```rb
config.presets.define :custom do
  # ... other configuration

  toolbar :undo, :redo, :|, :heading, :|, :bold, :italic, :underline, :|,
          :link, :insertImage, :ckbox, :mediaEmbed, :insertTable, :blockQuote, :|,
          :bulletedList, :numberedList, :todoList, :outdent, :indent
end
```

#### `language(ui, content:)` method

Defines the language of the editor. You can pass the language code as an argument. Keep in mind that the UI and content language can be different. The example below shows how to set the Polish language for the UI and content:

```rb
config.presets.define :custom do
  language :pl
end
```

In order to set the language for the content, you can pass the `content` keyword argument:

```rb
config.presets.define :custom do
  language :en, content: :pl
end
```

#### `configure(name, value)` method

Allows you to set custom configuration options. You can pass the name of the option and its value as arguments. The example below show how to set the default protocol for the link plugin to `https://`:

```rb
config.presets.define :custom do
  configure :link, {
    defaultProtocol: 'https://'
  }
end
```

#### `plugin(name, premium:, import_name:)` method

Defines a plugin to be included in the editor. You can pass the name of the plugin as an argument. The `premium` keyword argument determines whether the plugin is premium. The `import_name` keyword argument specifies the name of the package to import the plugin from.

The example below show how to import Bold plugin from the `ckeditor5` npm package:

```rb
config.presets.define :custom do
  plugin :Bold
end
```

In order to import a plugin from a custom package, you can pass the `import_name` keyword argument:

```rb
config.presets.define :custom do
  plugin :YourPlugin, import_name: 'your-package'
end
```

## License

The MIT License (MIT)
Copyright (c) Mateusz Bagiński / Łukasz Modliński

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
