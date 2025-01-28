// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.addEventListener('ckeditor:request-cjs-plugin:MyCustomWindowPlugin', () => {
  window.MyCustomWindowPlugin = (async () => {
    const { Plugin } = await import('ckeditor5');

    return class extends Plugin {
      static get pluginName() {
        return 'MyCustomWindowPlugin';
      }

      init() {
        console.log('MyCustomWindowPlugin initialized');
        window.__customWindowPlugin = true;
      }
    };
  })();
});
