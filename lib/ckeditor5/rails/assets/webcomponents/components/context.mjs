class CKEditorContextComponent extends HTMLElement {
  static get observedAttributes() {
    return ['plugins', 'config'];
  }

  /** @type {import('ckeditor5').Context|null} */
  instance = null;

  /** @type {Promise<import('ckeditor5').Context>} */
  instancePromise = Promise.withResolvers();

  /** @type {Set<CKEditorComponent>} */
  #connectedEditors = new Set();

  async connectedCallback() {
    try {
      execIfDOMReady(() => this.#initializeContext());
    } catch (error) {
      console.error('Failed to initialize context:', error);
      this.dispatchEvent(new CustomEvent('context-error', { detail: error }));
    }
  }

  async attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue !== null && oldValue !== newValue) {
      await this.#initializeContext();
    }
  }

  async disconnectedCallback() {
    if (this.instance) {
      await this.instance.destroy();
      this.instance = null;
    }
  }

  /**
   * Register editor component with this context
   *
   * @param {CKEditorComponent} editor
   */
  registerEditor(editor) {
    this.#connectedEditors.add(editor);
  }

  /**
   * Unregister editor component from this context
   *
   * @param {CKEditorComponent} editor
   */
  unregisterEditor(editor) {
    this.#connectedEditors.delete(editor);
  }

  /**
   * Initialize CKEditor context with shared configuration
   *
   * @private
   */
  async #initializeContext() {
    if (this.instance) {
      this.instancePromise = Promise.withResolvers();

      await this.instance.destroy();

      this.instance = null;
    }

    // Broadcast context initialization event
    window.dispatchEvent(
      new CustomEvent('ckeditor:context:attach:before', { detail: { element: this } })
    );

    const { Context, ContextWatchdog } = await import('ckeditor5');
    const plugins = await this.#getPlugins();
    const config = this.#getConfig();

    // Broadcast context mounting event with configuration
    window.dispatchEvent(
      new CustomEvent('ckeditor:context:attach', { detail: { config, element: this } })
    );

    this.instance = new ContextWatchdog(Context, {
      crashNumberLimit: 10
    });

    await this.instance.create({
      ...config,
      plugins
    });

    this.instance.on('itemError', (...args) => {
      console.error('Context item error:', ...args);
    });

    this.instancePromise.resolve(this.instance);
    this.dispatchEvent(new CustomEvent('context-ready', { detail: this.instance }));

    // Reinitialize connected editors.
    await Promise.all(
      [...this.#connectedEditors].map(editor => editor.reinitializeEditor())
    );
  }

  async #getPlugins() {
    const raw = this.getAttribute('plugins');

    return loadAsyncImports(raw ? JSON.parse(raw) : []);
  }

  /**
   * Gets context configuration with resolved element references.
   *
   * @private
   */
  #getConfig() {
    const config = JSON.parse(this.getAttribute('config') || '{}');

    return resolveElementReferences(config);
  }
}

customElements.define('ckeditor-context-component', CKEditorContextComponent);
