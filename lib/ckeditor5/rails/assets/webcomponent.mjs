class CKEditorComponent extends HTMLElement {
  static get observedAttributes() {
    return ['config', 'plugins', 'translations', 'type'];
  }

  #instance = null;

  async connectedCallback() {
    try {
      await this.#reinitializeEditor();
    } catch (error) {
      console.error('Failed to initialize editor:', error);
      this.dispatchEvent(new CustomEvent('editor-error', { detail: error }));
    }
  }

  async attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue !== null &&
        oldValue !== newValue &&
        CKEditorComponent.observedAttributes.includes(name) && this.isConnected) {
      await this.#reinitializeEditor();
    }
  }

  get editorElement() {
    return this.querySelector(this.#editorElementTag);
  }

  get #editorElementTag() {
    switch (this.getAttribute('type')) {
      case 'ClassicEditor':
        return 'textarea';

      default:
        return 'div';
    }
  }

  async disconnectedCallback() {
    try {
      await this.#instance?.destroy();
    } catch (error) {
      console.error('Failed to destroy editor:', error);
    }
  }

  async #initializeEditor() {
    const Editor = await this.#getEditorConstructor();
    const [plugins, translations] = await Promise.all([
      this.#getPlugins(),
      this.#getTranslations()
    ]);

    const instance = await Editor.create(this.editorElement, {
      ...this.#getConfig(),
      plugins,
      translations
    });

    this.dispatchEvent(new CustomEvent('editor-ready', { detail: instance }));
    return instance;
  }

  async #reinitializeEditor() {
    await this.#instance?.destroy();
    this.#instance = null;

    this.style.display = 'block';

    this.innerHTML = `<${this.#editorElementTag}></${this.#editorElementTag}>`;
    this.#instance = await this.#initializeEditor();
  }

  #getConfig() {
    return JSON.parse(this.getAttribute('config') || '{}');
  }

  async #getTranslations() {
    const raw = this.getAttribute('translations');
    return loadAsyncImports(raw ? JSON.parse(raw) : []);
  }

  async #getPlugins() {
    const raw = this.getAttribute('plugins');
    return loadAsyncImports(raw ? JSON.parse(raw) : []);
  }

  async #getEditorConstructor() {
    const CKEditor = await import('ckeditor5');
    const editorType = this.getAttribute('type');

    if (!editorType || !Object.prototype.hasOwnProperty.call(CKEditor, editorType)) {
      throw new Error(`Invalid editor type: ${editorType}`);
    }

    return CKEditor[editorType];
  }
}

function loadAsyncImports(imports = []) {
  return Promise.all(imports.map(async ({ import_name, import_as, window_name }) => {
    if (window_name && Object.prototype.hasOwnProperty.call(window, window_name)) {
      return window[window_name];
    }

    const module = await import(import_name);
    return import_as ? module[import_as] : module.default;
  }));
}

customElements.define('ckeditor-component', CKEditorComponent);
