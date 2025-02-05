# frozen_string_literal: true

require_relative '../editor/props_inline_plugin'

module CKEditor5::Rails::Plugins
  class SimpleUploadAdapter < CKEditor5::Rails::Editor::PropsInlinePlugin
    PLUGIN_CODE = <<~JS
      const { Plugin, FileRepository } = await import( 'ckeditor5' );

      return class SimpleUploadAdapter extends Plugin {
        static get requires() {
          return [FileRepository];
        }

        static get pluginName() {
          return 'SimpleUploadAdapter';
        }

        init() {
          const fileRepository = this.editor.plugins.get(FileRepository);
          const config = this.editor.config.get('simpleUpload');

          if (!config || !config.uploadUrl) {
            console.warn('Upload URL is not configured');
            return;
          }

          fileRepository.createUploadAdapter = (loader) => ({
            async upload() {
              try {
                const file = await loader.file;
                const formData = new FormData();
                formData.append('upload', file);

                return new Promise((resolve, reject) => {
                  const xhr = new XMLHttpRequest();

                  xhr.open('POST', config.uploadUrl, true);
                  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

                  // Add CSRF token from meta tag
                  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

                  if (csrfToken) {
                    xhr.setRequestHeader('X-CSRF-Token', csrfToken);
                  }

                  xhr.upload.onprogress = (evt) => {
                    if (evt.lengthComputable) {
                      loader.uploadTotal = evt.total;
                      loader.uploaded = evt.loaded;
                    }
                  };

                  xhr.onload = () => {
                    if (xhr.status >= 200 && xhr.status < 300) {
                      const data = JSON.parse(xhr.response);
                      resolve({ default: data.url });
                    } else {
                      reject(`Upload failed: ${xhr.statusText}`);
                    }
                  };

                  xhr.onerror = () => reject('Upload failed');
                  xhr.onabort = () => reject('Upload aborted');

                  xhr.send(formData);
                  this._xhr = xhr;
                });
              } catch (error) {
                throw error;
              }
            },

            abort() {
              if (this._xhr) {
                this._xhr.abort();
              }
            }
          });
        }
      }
    JS

    def initialize
      super(:SimpleUploadAdapter, PLUGIN_CODE)
      compress!
    end
  end
end
