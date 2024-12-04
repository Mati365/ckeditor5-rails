# Changelog

## [1.23.0] - 2024-12-04

### Features

* Compress webcomponent JS script. ([7a8e15f](https://github.com/Mati365/ckeditor5-rails/commit/7a8e15fa09141dee038c43fac169e65fa9bacdb1))

## [1.22.0] - 2024-12-04

### Features

* It's now possible to define groups in toolbar using `group` method. ([dc8b915](https://github.com/Mati365/ckeditor5-rails/commit/dc8b9154f39967ec46bf9802bdc745df822a5427))

### Documentation

* Add section about groups in the toolbar. ([2a85d7d](https://github.com/Mati365/ckeditor5-rails/commit/2a85d7dfb87c157c514b7a90265342de16d66ced))

## [1.21.0] - 2024-12-03

### Features

* Add `ckeditor5_lazy_javascript_tags` helper, improve support for Turbo. ([1718b60](https://github.com/Mati365/ckeditor5-rails/commit/1718b60b874cf73454992a6e85b57d41ac3c8f8c))

### Bug Fixes

* not working `editable_height` in presets. ([0c3e213](https://github.com/Mati365/ckeditor5-rails/commit/0c3e2133a6a0b6ab3a5689b7cabd8e9f249eddc4))

### Documentation

* Improve turbolinks docs ([29309d7](https://github.com/Mati365/ckeditor5-rails/commit/29309d7b94c2b5e588828977f60ea82c5023ca1b))

### Other Changes

* Add missing e2e tests ([f8e774f](https://github.com/Mati365/ckeditor5-rails/commit/f8e774fd7f9238ea9a6148785b76861a919116d8))
* Add lazy initialization of the editor. ([570e7d3](https://github.com/Mati365/ckeditor5-rails/commit/570e7d3e131482a3bc073fadf13f37642896bdbe))
* Add AJAX demos. ([64166d7](https://github.com/Mati365/ckeditor5-rails/commit/64166d7ffe77d9be798b2fdd80534014fd8af13a))
* Update README.md ([e3b4290](https://github.com/Mati365/ckeditor5-rails/commit/e3b42900f6adc652d268cab47e6fb817d2b794e2))

## [1.20.1] - 2024-12-02

### Features

* Update CKEditor to version 44.0.0 ([d10d6ed](https://github.com/Mati365/ckeditor5-rails/commit/d10d6ed1571bea9e43fc5909853ff30be73ea70d))

### Documentation

* Update head placement info. ([b4207d3](https://github.com/Mati365/ckeditor5-rails/commit/b4207d326b554ff7a8b30e7258b1bedd8d8f07dc))

### Other Changes

* Update README.md ([bf1ebed](https://github.com/Mati365/ckeditor5-rails/commit/bf1ebed508619eb043b499b9adbb1cd62add2e6d))

### Tests

* Tests: Stabilize importmap tests ([87f233c](https://github.com/Mati365/ckeditor5-rails/commit/87f233cc24f0377459942174fc8e3714ea2e4e71))

## [1.20.0] - 2024-12-02

### Features

* Add support for Rails 8. ([edd00a1](https://github.com/Mati365/ckeditor5-rails/commit/edd00a1517ba065a11cd955e8789edacb3ee9f76))
* more stable e2e tests. ([f035365](https://github.com/Mati365/ckeditor5-rails/commit/f035365b409c0acb3e4049a49155f6bb7163d266))

### Bug Fixes

* Not working importmap fallback ([0d78e89](https://github.com/Mati365/ckeditor5-rails/commit/0d78e89155019a7c0300e5c6828f56e3efa848ca))
* reorder imports ([ce305e6](https://github.com/Mati365/ckeditor5-rails/commit/ce305e628c0e6f921c175858e96a375898edfd53))

### Documentation

* Add info about `importmap-rails` ([8236e4a](https://github.com/Mati365/ckeditor5-rails/commit/8236e4ac4f43e8b51723d0b7f09d871e9bed2012))
* Add documentation to public exposed methods. ([8f063cf](https://github.com/Mati365/ckeditor5-rails/commit/8f063cfd2437fe3139dc101d61cdceef9c9cab4d))
* remove duplicated sections from changelog. ([d4cdea3](https://github.com/Mati365/ckeditor5-rails/commit/d4cdea3482d21f5942bff8a5c14ac4539f4ac138))

### Other Changes

* Tests: Improve coverage for Rails 8 importmap integration ([162e54b](https://github.com/Mati365/ckeditor5-rails/commit/162e54b08bb97cb88f5830795a7f4a7c04516927))
* Tests: Improve stability of e2e tests. ([da90136](https://github.com/Mati365/ckeditor5-rails/commit/da901363a4feaf8912817eba01b555653211751b))
* Rename script ([868b707](https://github.com/Mati365/ckeditor5-rails/commit/868b7070c4a4d393026e1a8ea1a6090538b472d3))

## [1.19.5] - 2024-11-29

### Features

* Update CKEditor to version 43.3.1 ([9ad58a8](https://github.com/Mati365/ckeditor5-rails/commit/9ad58a8d6b1d5c86a2defb1ddec879910fa79542))

### Bug Fixes

* wrong checkout in version checker ([e84c7c3](https://github.com/Mati365/ckeditor5-rails/commit/e84c7c369d9815fb25a2ac81325215e525317199))

## [1.19.0] - 2024-11-29

### Features

* Faster loading of assets due to use `modulepreload`, automatic detection of premium features in preset. ([03810e6](https://github.com/Mati365/ckeditor5-rails/commit/03810e6e2734a43ef64542236d41d7bc0ed9ff15))

### Documentation

* Add spellcheck section. ([f49f33a](https://github.com/Mati365/ckeditor5-rails/commit/f49f33af5be1c87ebb479c1bab90bd7983846bd3))
* Adjust spellcheck docs. ([e6ae24a](https://github.com/Mati365/ckeditor5-rails/commit/e6ae24a1b5ad98cf3747d0ecdd04fea0d6261c3c))

### Other Changes

* Fix calls convention. ([49e92da](https://github.com/Mati365/ckeditor5-rails/commit/49e92da76e9a627d84055274a8d1209c9a99fd17))

## [1.18.3] - 2024-11-28

### Features

* use editor language if no lang provided in wproofreader. ([934b096](https://github.com/Mati365/ckeditor5-rails/commit/934b0968c5e9ec3cfa3f51f72a14cae963fa7fd7))

## [1.18.1] - 2024-11-27

### Bug Fixes

* missing `wproofreader` in initializer config proxy ([9a5b8d1](https://github.com/Mati365/ckeditor5-rails/commit/9a5b8d1402af3f004e5fce6f4e587ffb4d70c378))
* incorrect changelog generate ([e1c41ed](https://github.com/Mati365/ckeditor5-rails/commit/e1c41edaa06a4510ca4b83db76c78e985af2d7fe))
* wrong example of wproofreader cdn in docs ([dce8af4](https://github.com/Mati365/ckeditor5-rails/commit/dce8af4f1cac822a1aa99ad2b18717b82c0ef351))

## [1.18.0] - 2024-11-27

### Features

* add `external_plugin` props helper ([a71202e](https://github.com/Mati365/ckeditor5-rails/commit/a71202ed9b557735dc10e544d68443706664a6da))
* add `wproofreader` props helper ([7858cb0](https://github.com/Mati365/ckeditor5-rails/commit/7858cb01e159d87de3cdcde63ef38514b75565ea))

### Other Changes

* Minor ref of `PropsPlugin` ([563c56e](https://github.com/Mati365/ckeditor5-rails/commit/563c56e2297a2b175bbb3cba64cffc410da01099))
* Introduce `PropsBasePlugin` ([536d27e](https://github.com/Mati365/ckeditor5-rails/commit/536d27ed29734a3c5b534fda257a9681dc9e8b36))
* Adjust changelog ([ba9968b](https://github.com/Mati365/ckeditor5-rails/commit/ba9968bb43ca812e8cc5619fab50f56446ba05c0))

## [1.17.4] - 2024-11-27

### Other Changes

* Add `CHANGELOG.md` ([8925a47](https://github.com/Mati365/ckeditor5-rails/commit/8925a47062fe9922f88f06ed98ceb47e65e96bbd))
* Add metadata to gemspec. ([089bff1](https://github.com/Mati365/ckeditor5-rails/commit/089bff125cac9b938ce32dd9952760fd97d020a3))
