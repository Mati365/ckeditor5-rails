# Changelog

## [1.31.8] - 2025-08-12

### Features

* Update CKEditor to version 46.0.1 ([0a0e98d](https://github.com/Mati365/ckeditor5-rails/commit/0a0e98d8be677b5707819f73d191ece4b14b9642))

### Other Changes

* Update README.md ([3501367](https://github.com/Mati365/ckeditor5-rails/commit/35013677925c5dba54a918654f5f24d0d91badcb))
* Build(deps): Bump requests from 2.32.3 to 2.32.4 in /infra ([6810b5a](https://github.com/Mati365/ckeditor5-rails/commit/6810b5a5ab79b91ba71e38d79ae8c3fb82d55184))

## [1.31.7] - 2025-07-10

### Features

* Update CKEditor to version 46.0.0 ([6db0753](https://github.com/Mati365/ckeditor5-rails/commit/6db0753013374c9c7e53bdfb455f8dfe3dae0e0a))

### Bug Fixes

* add regression tests for chineese lang. ([1143a7f](https://github.com/Mati365/ckeditor5-rails/commit/1143a7fc8d329366eb52245a51a9102201eb8624))

### Tests

* Tests: less flaky context checks ([ec43689](https://github.com/Mati365/ckeditor5-rails/commit/ec43689b80407c626446ff83e3b8b22e0b8fec00))

## [1.31.6] - 2025-06-30

### Bug Fixes

* add missing normalization in inline initialziation ([f6859f0](https://github.com/Mati365/ckeditor5-rails/commit/f6859f0ca4e216643282e8233a1452af94f9b5d6))

## [1.31.5] - 2025-06-30

### Bug Fixes

* not working `zn-CN` language ([93ecb4b](https://github.com/Mati365/ckeditor5-rails/commit/93ecb4bbbe4b649489e644a2f9ba80172ec8ed97))

## [1.31.4] - 2025-06-25

### Features

* Update CKEditor to version 45.2.1 ([76e2363](https://github.com/Mati365/ckeditor5-rails/commit/76e23633cf1fffb8f7b9a5c2f99dc20f3f2f813b))

### Other Changes

* Update README.md ([796ae66](https://github.com/Mati365/ckeditor5-rails/commit/796ae66339dae0d1de7a6e869e868a9b30800fe9))

## [1.31.3] - 2025-06-04

### Features

* Update CKEditor to version 45.2.0 ([7d9002c](https://github.com/Mati365/ckeditor5-rails/commit/7d9002ceba2cb4c4adb243d2619f9cb38dbf90ba))
* bump editor in manual demos ([f23b26e](https://github.com/Mati365/ckeditor5-rails/commit/f23b26e5f695e0fc9bbaa5329123b73c538054f2))

## [1.31.2] - 2025-05-15

### Features

* Update CKEditor to version 45.1.0 ([568b034](https://github.com/Mati365/ckeditor5-rails/commit/568b034dc308375f05bdd27b9adec96d23819a21))

### Documentation

* Add minimum Ruby / Rails version info. ([b535931](https://github.com/Mati365/ckeditor5-rails/commit/b535931f9547c29fc477e1e56ad32d035ea8ddb9))

## [1.31.1] - 2025-05-13

### Bug Fixes

* Incorrect properties serialization on Ruby 2.5. ([af8d426](https://github.com/Mati365/ckeditor5-rails/commit/af8d426eff0960ae75412a6c44fac57f69ca2359))

## [1.31.0] - 2025-05-12

### Features

* Added support for Rails 5.x and Ruby 2.5 for legacy compatibility ([463fbc4](https://github.com/Mati365/ckeditor5-rails/commit/463fbc45254907a1ae5003a5e7f6a01e514efd0c))

### Other Changes

* syntax compatibility changes for ruby 2.5 ([867084a](https://github.com/Mati365/ckeditor5-rails/commit/867084affffb264058e2fa7bac6300c4583cf7d3))
* compatibility issue with syntax for private is fix. ([274577f](https://github.com/Mati365/ckeditor5-rails/commit/274577fd69f1abe2db7b5bcd2474314be48d238d))
* Trying if this gem works with rails 5 and ruby 2.5 ([3d0d8e5](https://github.com/Mati365/ckeditor5-rails/commit/3d0d8e52d45ab4c7b52cc93a0e13a06f1b788db5))
* Update README.md ([ffe13f4](https://github.com/Mati365/ckeditor5-rails/commit/ffe13f431a24e1324b98fc77fb799abfca7a3005))

### Tests

* Tests: Add tests for various versions of ruby. ([c4f9345](https://github.com/Mati365/ckeditor5-rails/commit/c4f93455e385b4b7e9f48cfe8e2b866bfb06f8c0))

## [1.30.0] - 2025-04-11

### Features

* Retore editor patching support. ([53da8c9](https://github.com/Mati365/ckeditor5-rails/commit/53da8c9baebbdff3694ad1007d6f81c45dea2150))

## [1.29.2] - 2025-04-08

### Features

* Update CKEditor to version 45.0.0 ([bbc2cb0](https://github.com/Mati365/ckeditor5-rails/commit/bbc2cb07ebf41fdee49354ff9c734e38949cb5a0))

### Documentation

* improve align of section ([493e749](https://github.com/Mati365/ckeditor5-rails/commit/493e7498b3613d427b90a2e82d486981fd162fb2))
* update `inline_plugin` and `menubar` docs. ([6eb6d48](https://github.com/Mati365/ckeditor5-rails/commit/6eb6d485cb3a2e9990a00081cbdc44c6608e3ac0))

## [1.29.1] - 2025-03-17

### Bug Fixes

* It was impossible to use `I18n.t` in gem configure method. Fill presets *after* initializae. ([1447eed](https://github.com/Mati365/ckeditor5-rails/commit/1447eed888bf245c5d10e86dd3efec28c1bdc1d9))

## [1.29.0] - 2025-03-17

### Features

* Add ability to disable compression for specific inline plugins using `compress:` kwarg. ([e2cd145](https://github.com/Mati365/ckeditor5-rails/commit/e2cd145e74309228987b7129b69c6aca9b8e3617))

## [1.82.3] - 2025-03-13

### Bug Fixes

* Change JS wrapper format. ([7768a07](https://github.com/Mati365/ckeditor5-rails/commit/7768a0791f7539079dc511838167cf310ac6fdf5))

## [1.28.2] - 2025-03-13

### Bug Fixes

* Revert `type: module` modification. ([3e2d3be](https://github.com/Mati365/ckeditor5-rails/commit/3e2d3be306e7194921be0c5cd9294bf10d8a595d))

## [1.28.1] - 2025-03-11

### Bug Fixes

* Make scripts unique in lazy bundle. ([a92be5c](https://github.com/Mati365/ckeditor5-rails/commit/a92be5ccb990a01984d02f8d659240ffe886e5be))
* Add `type: 'module' to inline plugin html. ([9b5a1ec](https://github.com/Mati365/ckeditor5-rails/commit/9b5a1ec2aaf527656def25549526cee0c64cf90b))

## [1.28.0] - 2025-03-11

### Bug Fixes

* Drop patches support due to server issues. ([a323c3d](https://github.com/Mati365/ckeditor5-rails/commit/a323c3d8fd20ac41aaa22837825e3b2021bcd0d1))

## [1.27.3] - 2025-03-08

### Bug Fixes

* No longer duplicate inline plugins tags when loaded using `ckeditor5_lazy_javascript_tags`. ([22f3dd6](https://github.com/Mati365/ckeditor5-rails/commit/22f3dd6b4e8c818fca9ae5358bdda81d66dc5072))

## [1.27.2] - 2025-03-06

### Features

* Update CKEditor to version 44.3.0 ([0094758](https://github.com/Mati365/ckeditor5-rails/commit/0094758b38054c2fa53e69dadbcd43be171438cd))

## [1.27.1] - 2025-02-21

### Features

* Update CKEditor to version 44.2.1 ([ba40337](https://github.com/Mati365/ckeditor5-rails/commit/ba40337351ed8847b8b5fc315eadd63642ea2199))

### Documentation

* Improve demo of the editor ([647c838](https://github.com/Mati365/ckeditor5-rails/commit/647c838b15360f234c94c6809f15098e8e0b9163))

## [1.27.0] - 2025-02-14

### Features

* Add `custom_translations` helper that allows to translate configuration entries ([7aaea4a](https://github.com/Mati365/ckeditor5-rails/commit/7aaea4a698fe8aeb3e1779bbd0bef24a99b7daf8))

## [1.26.2] - 2025-02-13

### Features

* Update CKEditor to version 44.2.0 ([31f29cd](https://github.com/Mati365/ckeditor5-rails/commit/31f29cd2dc3bf383a166de3526bf092b6679416d))
* Less strict inline plugin registration in controller ([30b9195](https://github.com/Mati365/ckeditor5-rails/commit/30b9195ab10242b296809d0ab32128a480a76983))

### Documentation

* Add few notes to documentation. ([33dcaf7](https://github.com/Mati365/ckeditor5-rails/commit/33dcaf74aabe47ecdc2cf229bdea553b4fe55ee7))
* Update link in `apply_integration_patches` section ([e85e991](https://github.com/Mati365/ckeditor5-rails/commit/e85e991de3afdff5af4fd8827c8f6fa00d17231d))

### Other Changes

* Update README.md ([f8cb474](https://github.com/Mati365/ckeditor5-rails/commit/f8cb47465dacf718d99b5718b17a9d9f39387714))

## [1.26.1] - 2025-02-10

### Bug Fixes

* Missing license key error no longer happen in lazy assets context ([1e056fb](https://github.com/Mati365/ckeditor5-rails/commit/1e056fb695047741b50e0f1c11b0bfb5bf119e16))
* No longer crash if no license passed to editor with version >= `44` ([bf8a739](https://github.com/Mati365/ckeditor5-rails/commit/bf8a7393b1a1b01ac042de5b07d9dd277363122d))

## [1.26.0] - 2025-02-10

### Bug Fixes

* Apply patch that fixes color picker behavior ([620cbc7](https://github.com/Mati365/ckeditor5-rails/commit/620cbc73b3da10a519f2744e6c34341c9995b49e))

### Documentation

* Adjust patch plugin docs ([ab5e7bf](https://github.com/Mati365/ckeditor5-rails/commit/ab5e7bfb44d0301042b9f79133f788dcb9cba2e9))

## [1.25.0] - 2025-02-05

### Features

* Add special characters helpers. ([fb27f3c](https://github.com/Mati365/ckeditor5-rails/commit/fb27f3c38045b318203689774c5457bb641b8a73))

## [1.24.10] - 2025-01-28

### Bug Fixes

* fix not working `window_name` attribute in plugins ([95cdb11](https://github.com/Mati365/ckeditor5-rails/commit/95cdb11bbfff0b3fd3408349d9dcbeb257493a8e))
* Add missing yaml dependency to dockerfile. ([90584a5](https://github.com/Mati365/ckeditor5-rails/commit/90584a5c4d5aecf329863c97d81820102442290c))
* Not working demo. ([d8b8995](https://github.com/Mati365/ckeditor5-rails/commit/d8b89950cebe0a2f48d8911fef50f4278efe2be6))

### Other Changes

* Update docs. ([cdcb4a0](https://github.com/Mati365/ckeditor5-rails/commit/cdcb4a017b54571dacb0df359c96961a8a06e848))

## [1.24.9] - 2025-01-17

### Features

* Better language normalization in presets. ([b850d81](https://github.com/Mati365/ckeditor5-rails/commit/b850d810505b7417268c95f5bbbd49657663e5ca))

## [1.24.8] - 2025-01-11

### Other Changes

* Other: Incorrect ruby version in CI ([d12a70d](https://github.com/Mati365/ckeditor5-rails/commit/d12a70dc892b62378f2c001b85cda8d437e2f7d5))

## [1.24.7] - 2025-01-11

### Bug Fixes

* Incorrect license in gemspec ([751b57c](https://github.com/Mati365/ckeditor5-rails/commit/751b57c5247763e0b2be4b93349a7b7f14c60838))

### Documentation

* Update license links in docs ([9eda4c6](https://github.com/Mati365/ckeditor5-rails/commit/9eda4c68ac5d08754cf344c102f45930878c1ed9))
* Fix links in docs ([d5c0416](https://github.com/Mati365/ckeditor5-rails/commit/d5c041619246140b3df5b084829694366e5ecf9e))

## [1.24.6] - 2024-12-22

### Features

* Smaller size of output web-component due to compression of plugin names ([8a0bad1](https://github.com/Mati365/ckeditor5-rails/commit/8a0bad10ef22368175be5b28aadac0dbf949765f))

## [1.24.5] - 2024-12-21

### Features

* Compress custom plugins by default. ([c319c0c](https://github.com/Mati365/ckeditor5-rails/commit/c319c0c7f58f996371a40215e149fcf49365df5d))

## [1.24.4] - 2024-12-21

### Bug Fixes

* Broken wproofreader / upload adapter plugins. ([f329228](https://github.com/Mati365/ckeditor5-rails/commit/f329228e30c9207fe1f3125f3891ba9e73f71d3d))

## [1.24.3] - 2024-12-21

### Bug Fixes

* Add `block_toolbar` and `balloon_toolbar` to default configuration proxy. ([0d3b552](https://github.com/Mati365/ckeditor5-rails/commit/0d3b55248f5729c80fd6d26a893860909c048a10))

## [1.24.2] - 2024-12-21

### Bug Fixes

* Add missing `once` attribute to `request-cjs-plugin` event. ([cb46578](https://github.com/Mati365/ckeditor5-rails/commit/cb465782f37935bea961dd2f8be7dbb15daa3552))

## [1.24.1] - 2024-12-20

### Bug Fixes

* Disable minification of inline plugins for context plugins. ([7071ca3](https://github.com/Mati365/ckeditor5-rails/commit/7071ca39d0757022d64fe1fa370a6ed81e976de5))

## [1.24.0] - 2024-12-20

### Features

* No longer inline inline plugins code in web-component props. ([e9a6764](https://github.com/Mati365/ckeditor5-rails/commit/e9a676433c4e56a3a8018a80e9d6788a39e87ea9))
* Improve CSP in demos. ([b9b5a4f](https://github.com/Mati365/ckeditor5-rails/commit/b9b5a4fd7d2c0ac68a82d421fee2df88c15d190d))

### Documentation

* Add section about CSP. ([2d3357b](https://github.com/Mati365/ckeditor5-rails/commit/2d3357b800f98779129fd7fc989ee6082e343c34))

### Other Changes

* Text: Fix failing tests after refactor of inline plugins handling. ([e8c2e82](https://github.com/Mati365/ckeditor5-rails/commit/e8c2e82477d19e399be350763be362cad1c6d8b5))

### Tests

* Test: Restore coverage ([57e1415](https://github.com/Mati365/ckeditor5-rails/commit/57e1415ef320e807bb0285adfb9f842c7825ca7c))

## [1.23.5] - 2024-12-20

### Features

* Add `nonce` support for script tags included using gem helpers. ([82fc9c1](https://github.com/Mati365/ckeditor5-rails/commit/82fc9c1baa87afb787b4cda8e949b07327941295))

## [1.23.4] - 2024-12-19

### Bug Fixes

* It's no longer possible to define unsafe inline plugin in controller preset helper. ([3aa7411](https://github.com/Mati365/ckeditor5-rails/commit/3aa7411ea011535baaefc79c341ae0ba12264ec8))

### Other Changes

* Update links in readme ([8e7b48e](https://github.com/Mati365/ckeditor5-rails/commit/8e7b48e0dc2f464ad241c2ce7dd8784403d6757d))
* Change ssh key ([ef3f944](https://github.com/Mati365/ckeditor5-rails/commit/ef3f944a5a765043a33b3ace326bfd0278dd67e8))

## [1.23.2] - 2024-12-17

### Features

* Update CKEditor to version 44.1.0 ([39ab2c4](https://github.com/Mati365/ckeditor5-rails/commit/39ab2c4e38b41302c3e933336f2130797a50495d))

### Other Changes

* Fix typo ([de94f3f](https://github.com/Mati365/ckeditor5-rails/commit/de94f3f7937f28bb49adc36cf7173d0ca6298277))
* fix nginx ([ae1056e](https://github.com/Mati365/ckeditor5-rails/commit/ae1056e96af1c370cdc25228315ee751688c09a0))
* Fix links ([d219894](https://github.com/Mati365/ckeditor5-rails/commit/d2198949da924e50bcb697fa3e758c4b93bf86dd))

## [1.23.1] - 2024-12-13

### Other Changes

* Fix lint ([bd1d003](https://github.com/Mati365/ckeditor5-rails/commit/bd1d00361d6326814a2f6ecee5a897031fcdca54))
* Add block balloon editor docs ([aedeefa](https://github.com/Mati365/ckeditor5-rails/commit/aedeefaa01aec616d2cac9e03b072ddc941ca5b9))
* Fix css ([7a637bf](https://github.com/Mati365/ckeditor5-rails/commit/7a637bf387e0153167c21356d61779bbec2adfb4))
* Add link ([a7f0f1d](https://github.com/Mati365/ckeditor5-rails/commit/a7f0f1db31e7b64226f5315baa5299899aecce63))
* Add doc ([8169912](https://github.com/Mati365/ckeditor5-rails/commit/8169912bfce2d7acd240ae31f7078a888362ec15))
* Better site ([e8a1c64](https://github.com/Mati365/ckeditor5-rails/commit/e8a1c6427f9c5b11593bc1a16713379882a2bc6d))
* Add images to demos ([ee451a3](https://github.com/Mati365/ckeditor5-rails/commit/ee451a3465fc77a06c90622ae6036a5b1f0f7f8e))
* Fix link ([a427bea](https://github.com/Mati365/ckeditor5-rails/commit/a427bea86a53d01b342f61337f477cdf2a03c2f5))
* Fix questions ([6c99c7b](https://github.com/Mati365/ckeditor5-rails/commit/6c99c7b332fd5538423d500b2e510a1e34e57f5b))
* Better docs ([3186fe0](https://github.com/Mati365/ckeditor5-rails/commit/3186fe01c590b0588676c5a8ba00edbd0a55f0b4))
* Adjust nginx ([094edb4](https://github.com/Mati365/ckeditor5-rails/commit/094edb418e95ce0e97e415f91c211fd0bd89ead0))
* Fix logs ([a0d4301](https://github.com/Mati365/ckeditor5-rails/commit/a0d43015ee450ddcd3973bd6d9d9b6e0e4a04f3d))
* Use puma ([a93cf57](https://github.com/Mati365/ckeditor5-rails/commit/a93cf576150645c5081fe4c24086d2210e6ecbfa))
* Fix CI ([2da63d5](https://github.com/Mati365/ckeditor5-rails/commit/2da63d5aaddd62f14359fb4d7ada8e6ecc46200b))
* Add precompile ([bc32901](https://github.com/Mati365/ckeditor5-rails/commit/bc329016338c9240814d5a7b3aa26af9e3bd26f1))
* Fix ([6c42816](https://github.com/Mati365/ckeditor5-rails/commit/6c428161dfdce6743b4969549a77c60f821623d0))
* Fix infra ([705742c](https://github.com/Mati365/ckeditor5-rails/commit/705742cf92b567f06799c63e01aa394ecd235270))
* Fix CI again ([1a1d294](https://github.com/Mati365/ckeditor5-rails/commit/1a1d294c072a062bf7757ec7d4d35b6d0c069b5a))
* Fix certbox ([a8981f4](https://github.com/Mati365/ckeditor5-rails/commit/a8981f4f6e61ff5243cbb80dbbda2c2cd507a140))
* Fix dependencies ([a01f8ca](https://github.com/Mati365/ckeditor5-rails/commit/a01f8caa5538a1158b8ca97e77e77937ebcc9a7c))
* Add demo infra ([465b8a1](https://github.com/Mati365/ckeditor5-rails/commit/465b8a1c88fa5d02f67744c6fda77891d271e9e7))
* Update README.md ([331cace](https://github.com/Mati365/ckeditor5-rails/commit/331cace906fb87c51746a8f890737699d74d89d7))

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
