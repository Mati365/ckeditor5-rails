class CKEditorComponent extends HTMLElement {
  instance = null;

  async connectedCallback() {
    this.style.display = 'block';
    this.innerHTML = `<textarea>Start editing...</textarea>`;
    this.instance = await this.#initializeEditor();
  }

  get textarea() {
    return this.querySelector('textarea');
  }

  async disconnectedCallback() {
    await this.instance?.destroy();
  }

  async #initializeEditor() {
    const Editor = await this.#getEditorConstructor();
    const instance = await Editor.create(
      this.textarea,
      {
        ...this.#getParsedConfig(),
        plugins: await this.#importPlugins(),
        translations: await this.#importTranslations(),
      }
    );

    this.dispatchEvent(new CustomEvent('editor-ready', { detail: instance }));

    return instance;
  }

  #getParsedConfig() {
    return JSON.parse(this.getAttribute('config'));
  }

  async #importTranslations() {
    const translations = JSON.parse(this.getAttribute('translations'));

    return this.#importAsyncImports(translations);
  }

  async #importPlugins() {
    const plugins = JSON.parse(this.getAttribute('plugins'));

    return this.#importAsyncImports(plugins);
  }

  async #importAsyncImports(imports) {
    const promises = imports.map(async (pkg) => {
      const { import_name, import_as, window_name } = pkg;

      // Window import
      if (window_name && Object.prototype.hasOwnProperty.call(window, window_name)) {
        return window[window_name];
      }

      // ESM import
      const result = await import(import_name);

      return import_as ? result[import_as] : result.default;
    });

    return Promise.all(promises);
  }

  async #getEditorConstructor() {
    const CKEditor = await import('ckeditor5');
    const editorType = this.getAttribute('type');

    if (typeof editorType !== 'string' ||
        !Object.prototype.hasOwnProperty.call(CKEditor, editorType)) {
      throw new Error('Invalid editor type');
    }

    return CKEditor[editorType];
  }
}

customElements.define('ckeditor-component', CKEditorComponent);
