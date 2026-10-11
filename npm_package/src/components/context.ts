import type { Context } from 'ckeditor5';

import type { CKEditorComponent } from './editor';

import { execIfDOMReady, loadAsyncImports, resolveConfigElementReferences } from '../helpers';

export class CKEditorContextComponent extends HTMLElement {
  instance: Context | null = null;

  instancePromise = createInstancePromise<Context>();

  #connectedEditors = new Set<CKEditorComponent>();

  /**
   * Incremented on every (re)initialization and on disconnect. An initialization that finishes
   * with a different value is stale and destroys the context it created.
   */
  #generation = 0;

  /**
   * Unregisters the error callback of the current context instance.
   */
  #offEditorError: VoidFunction | null = null;

  static get observedAttributes() {
    return ['plugins', 'config'];
  }

  connectedCallback() {
    execIfDOMReady(() => this.#initializeContextSafely());
  }

  async attributeChangedCallback(_: unknown, oldValue: string | null, newValue: string | null) {
    if (oldValue !== null && oldValue !== newValue) {
      await this.#initializeContextSafely();
    }
  }

  async disconnectedCallback() {
    // Makes an initialization in progress destroy the context it creates.
    this.#generation++;

    try {
      await this.#destroyContext();
    }
    catch (error) {
      console.error('Failed to destroy context:', error);
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
   * Initializes the context and reports failures instead of leaking rejections
   * (lifecycle callbacks are not awaited by the browser).
   */
  async #initializeContextSafely() {
    const generation = ++this.#generation;

    try {
      await this.#initializeContext(generation);
    }
    catch (error) {
      // A newer initialization (or disconnect) owns the state now.
      if (generation !== this.#generation) {
        return;
      }

      // Reject editors waiting for this context (they would hang forever otherwise),
      // and let the next initialization start with a fresh promise.
      this.instancePromise.reject(error);
      this.instancePromise = createInstancePromise<Context>();

      this.#reportError('Failed to initialize context:', error);
    }
  }

  /**
   * Initialize CKEditor context with shared configuration
   *
   * @private
   * @param generation - Value of `#generation` assigned to this initialization.
   */
  async #initializeContext(generation: number) {
    // Destroying the context destroys all its editors too. They're recreated at the end.
    await this.#destroyContext();

    // Broadcast context initialization event
    window.dispatchEvent(
      new CustomEvent('ckeditor:context:attach:before', { detail: { element: this } }),
    );

    const { Context, onEditorError } = await import('ckeditor5');
    const plugins = await this.#getPlugins();
    const config = this.#getConfig();

    // Broadcast context mounting event with configuration
    window.dispatchEvent(
      new CustomEvent('ckeditor:context:attach', { detail: { config, element: this } }),
    );

    const instance = await Context.create({
      ...config,
      plugins,
    });

    // The element was disconnected or the context was reinitialized again in the meantime.
    if (generation !== this.#generation) {
      await instance.destroy();
      return;
    }

    this.instance = instance;

    // Nothing restarts the context after a crash anymore. Its state may be inconsistent, so lock
    // its editors in read-only mode. Errors attributed to editors are handled by editor components.
    this.#offEditorError = onEditorError(({ error, source }) => {
      if (source !== instance) {
        return;
      }

      for (const editor of instance.editors) {
        editor.enableReadOnlyMode('error-handling');
      }

      this.#reportError('Context failed:', error);
    });

    this.instancePromise.resolve(instance);
    this.dispatchEvent(new CustomEvent('context-ready', { detail: instance }));

    // Reinitialize connected editors. Their errors are reported by the editor components themselves.
    await Promise.all(
      [...this.#connectedEditors].map(editor => editor.reinitializeEditor().catch(() => {})),
    );
  }

  /**
   * Destroys the current context instance (and all editors created in it).
   */
  async #destroyContext() {
    const { instance } = this;

    if (!instance) {
      return;
    }

    this.#offEditorError?.();
    this.#offEditorError = null;

    this.instance = null;
    this.instancePromise = createInstancePromise<Context>();

    await instance.destroy();
  }

  /**
   * Logs the error and dispatches the `context-error` event.
   */
  #reportError(message: string, error: unknown) {
    console.error(message, error);
    this.dispatchEvent(new CustomEvent('context-error', { detail: error }));
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

/**
 * Creates a deferred promise that does not report an unhandled rejection
 * when it's rejected while nobody is waiting for it.
 */
function createInstancePromise<T>(): PromiseWithResolvers<T> {
  const deferred = Promise.withResolvers<T>();

  deferred.promise.catch(() => {});

  return deferred;
}

customElements.define('ckeditor-context-component', CKEditorContextComponent);
