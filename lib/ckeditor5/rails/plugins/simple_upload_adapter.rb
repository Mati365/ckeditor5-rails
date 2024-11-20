# frozen_string_literal: true

module CKEditor5::Rails::Plugins
  class SimpleUploadAdapter < CKEditor5::Rails::Editor::PropsInlinePlugin
    PLUGIN_CODE = <<~JAVASCRIPT
      import { Plugin, FileRepository } from 'ckeditor5';

      export default class SimpleUploadAdapter extends Plugin {
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
    JAVASCRIPT

    def initialize
      super(:SimpleUpload, PLUGIN_CODE)
    end
  end
end
