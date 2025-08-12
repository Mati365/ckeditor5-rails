import type { ContextWatchdog } from 'ckeditor5';

import { execIfDOMReady, loadAsyncImports, resolveConfigElementReferences } from 'src/helpers';

import type { CKEditorComponent } from './editor';

export class CKEditorContextComponent extends HTMLElement {
  instance: ContextWatchdog | null = null;

  instancePromise = Promise.withResolvers<ContextWatchdog>();

  #connectedEditors = new Set<CKEditorComponent>();

  static get observedAttributes() {
    return ['plugins', 'config'];
  }

  async connectedCallback() {
    try {
      execIfDOMReady(() => this.#initializeContext());
    }
    catch (error) {
      console.error('Failed to initialize context:', error);
      this.dispatchEvent(new CustomEvent('context-error', { detail: error }));
    }
  }

  async attributeChangedCallback(_: unknown, oldValue: string | null, newValue: string | null) {
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
   * @param editor - Editor component to register.
   */
  registerEditor(editor: CKEditorComponent) {
    this.#connectedEditors.add(editor);
  }

  /**
   * Unregister editor component from this context
   *
   * @param editor - Editor component to unregister
   */
  unregisterEditor(editor: CKEditorComponent) {
    this.#connectedEditors.delete(editor);
  }

  /**
   * Initialize CKEditor context with shared configuration
   *
   * @private
   */
  async #initializeContext() {
    if (this.instance) {
      this.instancePromise = Promise.withResolvers<ContextWatchdog>();

      await this.instance.destroy();

      this.instance = null;
    }

    // Broadcast context initialization event
    window.dispatchEvent(
      new CustomEvent('ckeditor:context:attach:before', { detail: { element: this } }),
    );

    const { Context, ContextWatchdog } = await import('ckeditor5');
    const plugins = await this.#getPlugins();
    const config = this.#getConfig();

    // Broadcast context mounting event with configuration
    window.dispatchEvent(
      new CustomEvent('ckeditor:context:attach', { detail: { config, element: this } }),
    );

    this.instance = new ContextWatchdog(Context, {
      crashNumberLimit: 10,
    });

    await this.instance.create({
      ...config,
      plugins,
    });

    this.instance.on('itemError', (...args) => {
      console.error('Context item error:', ...args);
    });

    this.instancePromise.resolve(this.instance);
    this.dispatchEvent(new CustomEvent('context-ready', { detail: this.instance }));

    // Reinitialize connected editors.
    await Promise.all(
      [...this.#connectedEditors].map(editor => editor.reinitializeEditor()),
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

    return resolveConfigElementReferences(config);
  }
}

customElements.define('ckeditor-context-component', CKEditorContextComponent);
