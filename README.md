# ckeditor5

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg?style=flat-square)](https://opensource.org/licenses/MIT)
![Gem Version](https://img.shields.io/gem/v/ckeditor5-rails?style=flat-square)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-green.svg?style=flat-square)](http://makeapullrequest.com)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/mati365/ckeditor5-rails?style=flat-square)
[![GitHub issues](https://img.shields.io/github/issues/mati365/ckeditor5-rails?style=flat-square)](https://github.com/Mati365/ckeditor5-rails/issues)

Unofficial CKEditor 5 Ruby on Rails integration.

## Install

Add this line to your application's Gemfile:

```ruby
gem ckeditor5
```

## :construction: Planned features

- [ ] Add support for CKEditor 5 `Classic` / `Multi-Root` / `Balloon` / `Inline` / `Document editors`.
- [ ] Add support for CKEditor 5 Watchdog and Context.
- [ ] Add support for CKEditor 5 CDN and NPM packages.
- [ ] Add support for CKEditor 5 Collaboration.
- [ ] Add support for SSR.

## :construction: Planned usage

Classic editor:

```slim
= render ckeditor5 :classic, id: 'editor', config: { toolbar: 'bold italic | link' }
```

## License

The MIT License (MIT)
Copyright (c) Mateusz Bagiński / Łukasz Modliński

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
