import type { Editor, EditorWatchdog, Watchdog } from 'ckeditor5';

import type { AsyncImportRawDescription } from '../../helpers';
import type { CKEditorContextComponent } from '../context';
import type { CKEditorEditableComponent } from '../editable';

import {
  execIfDOMReady,
  isSafeKey,
  loadAsyncCSS,
  loadAsyncImports,
  resolveConfigElementReferences,
  uid,
} from '../../helpers';
import { CKEditorMultiRootEditablesTracker } from './multiroot-editables-tracker';

export class CKEditorComponent extends HTMLElement {
  instancePromise = Promise.withResolvers<Editor>();

  watchdog: Watchdog | null = null;

  instance: Editor | null = null;

  editables: Record<string, HTMLElement> | null = Object.create({});

  #initialHTML: string = '';

  #context: CKEditorContextComponent | null = null;

  #contextEditorId: string | null = null;

  #bundle: object | null = null;

  /**
   * List of attributes that trigger updates when changed.
   */
  static get observedAttributes() {
    return ['config', 'plugins', 'translations', 'type'];
  }

  /**
   * List of input attributes that trigger updates when changed.
   */
  static get inputAttributes() {
    return ['name', 'required', 'value'];
  }

  get oneditorchange() {
    return this.#getEventHandler('editorchange');
  }

  set oneditorchange(handler) {
    this.#setEventHandler('editorchange', handler);
  }

  get oneditorready() {
    return this.#getEventHandler('editorready');
  }

  set oneditorready(handler) {
    this.#setEventHandler('editorready', handler);
  }

  get oneditorerror() {
    return this.#getEventHandler('editorerror');
  }

  set oneditorerror(handler) {
    this.#setEventHandler('editorerror', handler);
  }

  /**
   * Gets event handler function from attribute or property
   *
   * @private
   * @param name - Event name without 'on' prefix
   * @returns Event handler or null
   */
  #getEventHandler(name: string): Function | null {
    if (this.hasAttribute(`on${name}`)) {
      const handler = this.getAttribute(`on${name}`)!;

      if (!isSafeKey(handler)) {
        throw new Error(`Unsafe event handler attribute value: ${handler}`);
      }

      // eslint-disable-next-line no-new-func
      return (window as any)[handler] || new Function('event', handler);
    }
    return (this as any)[`#${name}Handler`];
  }

  /**
   * Sets event handler function
   *
   * @private
   * @param name - Event name without 'on' prefix
   * @param handler - Event handler
   */
  #setEventHandler(name: string, handler: Function | null) {
    if (typeof handler === 'string') {
      this.setAttribute(`on${name}`, handler);
    }
    else {
      this.removeAttribute(`on${name}`);
      (this as any)[`#${name}Handler`] = handler;
    }
  }

  /**
   * Lifecycle callback when element is connected to DOM
   * Initializes the editor when DOM is ready
   *
   * @protected
   */
  connectedCallback() {
    this.#context = this.closest('ckeditor-context-component');
    this.#initialHTML = this.innerHTML;

    try {
      execIfDOMReady(async () => {
        if (this.#context) {
          await this.#context.instancePromise.promise;
          this.#context.registerEditor(this);
        }

        await this.reinitializeEditor();
      });
    }
    catch (error) {
      console.error('Failed to initialize editor:', error);

      const event = new CustomEvent('editor-error', { detail: error });

      this.dispatchEvent(event);
      this.oneditorerror?.(event);
    }
  }

  /**
   * Handles attribute changes and reinitializes editor if needed
   *
   * @protected
   * @param  name - Name of changed attribute
   * @param oldValue - Previous attribute value
   * @param newValue - New attribute value
   */
  async attributeChangedCallback(name: string, oldValue: string | null, newValue: string | null) {
    if (oldValue !== null
      && oldValue !== newValue
      && CKEditorComponent.observedAttributes.includes(name) && this.isConnected) {
      await this.reinitializeEditor();
    }
  }

  /**
   * Lifecycle callback when element is removed from DOM
   * Destroys the editor instance
   * @protected
   */
  async disconnectedCallback() {
    if (this.#context) {
      this.#context.unregisterEditor(this);
    }

    try {
      await this.#destroy();
    }
    catch (error) {
      console.error('Failed to destroy editor:', error);
    }
  }

  /**
   * Runs a callback after the editor is ready. It waits for editor
   * initialization if needed.
   *
   * @param callback - Callback to run
   */
  runAfterEditorReady<E extends Editor>(callback: (editor: E) => void): Promise<void> {
    if (this.instance) {
      return Promise.resolve(callback(this.instance as unknown as E));
    }

    return this.instancePromise.promise.then(callback as unknown as any);
  }

  /**
   * Determines appropriate editor element tag based on editor type
   */
  get #editorElementTag() {
    switch (this.getAttribute('type')) {
      case 'ClassicEditor':
        return 'textarea';

      default:
        return 'div';
    }
  }

  /**
   * Gets the CKEditor context instance if available.
   */
  get #contextWatchdog() {
    return this.#context?.instance;
  }

  /**
   * Destroys the editor instance and watchdog if available
   */
  async #destroy() {
    if (this.#contextEditorId) {
      await this.#contextWatchdog!.remove(this.#contextEditorId);
    }

    await this.instance?.destroy();
    this.watchdog?.destroy();
  }

  /**
   * Gets editor configuration with resolved element references
   */
  #getConfig() {
    const config = JSON.parse(this.getAttribute('config') || '{}');

    return resolveConfigElementReferences(config);
  }

  /**
   * Creates a new CKEditor instance
   */
  async #initializeEditor(editablesOrContent: Record<string, HTMLElement | string> | CKEditorMultiRootEditablesTracker | string | HTMLElement) {
    await Promise.all([
      this.#ensureStylesheetsInjected(),
      this.#ensureWindowScriptsInjected(),
    ]);

    // Depending on the type of the editor the content supplied on the first
    // argument is different. For ClassicEditor it's a element or string, for MultiRootEditor
    // it's an object with editables, for DecoupledEditor it's string.
    let content: any = editablesOrContent;

    if (editablesOrContent instanceof CKEditorMultiRootEditablesTracker) {
      content = editablesOrContent.getAll();
    }
    else if (typeof editablesOrContent !== 'string') {
      content = (editablesOrContent as any)['main'];
    }

    // Broadcast editor initialization event. It's good time to load add inline window plugins.
    const beforeInitEventDetails = {
      ...content instanceof HTMLElement && { element: content },
      ...typeof content === 'string' && { data: content },
      ...content instanceof Object && { editables: content },
    };

    window.dispatchEvent(
      new CustomEvent('ckeditor:attach:before', { detail: beforeInitEventDetails }),
    );

    // Start fetching constructor.
    const Editor = await this.#getEditorConstructor();
    const [plugins, translations] = await Promise.all([
      this.#getPlugins(),
      this.#getTranslations(),
    ]);

    const config = {
      ...this.#getConfig(),
      ...translations.length && {
        translations,
      },
      plugins,
    };

    // Broadcast editor mounting event. It's good time to map configuration.
    window.dispatchEvent(
      new CustomEvent('ckeditor:attach', { detail: { config, ...beforeInitEventDetails } }),
    );

    console.warn('Initializing CKEditor with:', { config, watchdog: this.hasWatchdog(), context: this.#context });

    // Initialize watchdog if needed
    let watchdog: EditorWatchdog | null = null;
    let instance: Editor | null = null;
    let contextId: string | null = null;

    if (this.#context) {
      contextId = uid();

      await this.#contextWatchdog!.add({
        creator: (_element, _config) => Editor.create(_element, _config),
        id: contextId,
        sourceElementOrData: content,
        type: 'editor',
        config,
      });

      instance = this.#contextWatchdog!.getItem(contextId) as Editor;
    }
    else if (this.hasWatchdog()) {
      // Let's create use with plain watchdog.
      const { EditorWatchdog } = await import('ckeditor5');
      watchdog = new EditorWatchdog(Editor);

      await watchdog.create(content, config);

      instance = watchdog.editor;
    }
    else {
      // Let's create the editor without watchdog.
      instance = await Editor.create(content, config);
    }

    console.warn('CKEditor initialized:', {
      instance,
      watchdog,
      config: (instance!.config as any)._config,
    });

    return {
      contextId,
      instance,
      watchdog,
    };
  }

  /**
   * Re-initializes the editor by destroying existing instance and creating new one
   *
   * @private
   * @returns {Promise<void>}
   */
  async reinitializeEditor() {
    if (this.instance) {
      this.instancePromise = Promise.withResolvers();

      await this.#destroy();

      this.instance = null;
    }

    this.style.display = 'block';

    if (!this.isMultiroot() && !this.isDecoupled()) {
      this.innerHTML = `<${this.#editorElementTag}>${this.#initialHTML}</${this.#editorElementTag}>`;
      this.#assignInputAttributes();
    }

    // Let's track changes in editables if it's a multiroot editor.
    if (this.isMultiroot()) {
      this.editables = new CKEditorMultiRootEditablesTracker(this, this.#queryEditables()) as unknown as Record<string, HTMLElement>;
    }
    else if (this.isDecoupled()) {
      this.editables = null;
    }
    else {
      this.editables = this.#queryEditables();
    }

    try {
      const { watchdog, instance, contextId } = await this.#initializeEditor(this.editables || this.#getConfig().initialData || '');

      this.watchdog = watchdog;
      this.instance = instance!;
      this.#contextEditorId = contextId;

      this.#setupContentSync();
      this.#setupEditableHeight();
      this.#setupDataChangeListener();

      this.instancePromise.resolve(this.instance!);

      // Broadcast editor ready event
      const event = new CustomEvent('editor-ready', { detail: this.instance });

      this.dispatchEvent(event);
      this.oneditorready?.(event);
    }
    catch (err) {
      this.instancePromise.reject(err);
      throw err;
    }
  }

  /**
   * Sets up data change listener that broadcasts content changes
   */
  #setupDataChangeListener() {
    const getRootContent = (rootName: string) => this.instance!.getData({ rootName });
    const getAllRoots = () =>
      this.instance?.model.document
        .getRootNames()
        .reduce((acc, rootName) => ({
          ...acc,
          [rootName]: getRootContent(rootName),
        }), {});

    this.instance?.model.document.on('change:data', () => {
      const event = new CustomEvent('editor-change', {
        detail: {
          editor: this.instance,
          data: getAllRoots(),
        },
        bubbles: true,
      });

      this.dispatchEvent(event);
      this.oneditorchange?.(event);
    });
  }

  /**
   * Checks if current editor is classic type
   */
  isClassic() {
    return this.getAttribute('type') === 'ClassicEditor';
  }

  /**
   * Checks if current editor is balloon type
   */
  isBallon() {
    return this.getAttribute('type') === 'BalloonEditor';
  }

  /**
   * Checks if current editor is multiroot type
   */
  isMultiroot() {
    return this.getAttribute('type') === 'MultiRootEditor';
  }

  /**
   * Checks if current editor is decoupled type
   */
  isDecoupled() {
    return this.getAttribute('type') === 'DecoupledEditor';
  }

  /**
   * Checks if current editor has watchdog enabled
   */
  hasWatchdog() {
    return this.getAttribute('watchdog') === 'true';
  }

  /**
   * Queries and validates editable elements
   */
  #queryEditables() {
    if (this.isDecoupled()) {
      return {};
    }

    if (this.isMultiroot()) {
      const editables = [...this.querySelectorAll('ckeditor-editable-component')] as CKEditorEditableComponent[];

      return editables.reduce((acc, element) => {
        if (!element.name) {
          throw new Error('Editable component missing required "name" attribute');
        }
        acc[element.name] = element;
        return acc;
      }, Object.create(null));
    }

    const mainEditable = this.querySelector(this.#editorElementTag);

    if (!mainEditable) {
      throw new Error(`No ${this.#editorElementTag} element found`);
    }

    return { main: mainEditable };
  }

  /**
   * Copies input-related attributes from component to the main editable element
   *
   * @private
   */
  #assignInputAttributes() {
    const textarea = this.querySelector('textarea');

    if (!textarea) {
      return;
    }

    for (const attr of CKEditorComponent.inputAttributes) {
      if (this.hasAttribute(attr)) {
        textarea.setAttribute(attr, this.getAttribute(attr)!);
      }
    }
  }

  /**
   * Sets up content sync between editor and textarea element.
   *
   * @private
   */
  #setupContentSync() {
    if (!this.instance) {
      return;
    }

    const textarea = this.querySelector('textarea');

    if (!textarea) {
      return;
    }

    // Initial sync
    const syncInput = () => {
      this.style.position = 'relative';

      textarea.innerHTML = '';
      textarea.value = this.instance!.getData();
      textarea.tabIndex = -1;

      Object.assign(textarea.style, {
        display: 'flex',
        position: 'absolute',
        bottom: '0',
        left: '50%',
        width: '1px',
        height: '1px',
        opacity: '0',
        pointerEvents: 'none',
        margin: '0',
        padding: '0',
        border: 'none',
      });
    };

    syncInput();

    // Listen for changes
    this.instance.model.document.on('change:data', () => {
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      textarea.dispatchEvent(new Event('change', { bubbles: true }));

      syncInput();
    });
  }

  /**
   * Sets up editable height for ClassicEditor
   *
   * @private
   */
  #setupEditableHeight() {
    if (!this.isClassic() && !this.isBallon()) {
      return;
    }

    const { instance } = this;
    const height = Number.parseInt(this.getAttribute('editable-height')!, 10);

    if (Number.isNaN(height)) {
      return;
    }

    instance!.editing.view.change((writer) => {
      writer.setStyle('height', `${height}px`, instance!.editing.view.document.getRoot()!);
    });
  }

  /**
   * Gets bundle JSON description from translations attribute
   */
  #getBundle(): BundleDescription {
    return this.#bundle ||= JSON.parse(this.getAttribute('bundle')!);
  }

  /**
   * Checks if all required stylesheets are injected. If not, inject.
   */
  async #ensureStylesheetsInjected() {
    await loadAsyncCSS(this.#getBundle()?.stylesheets || []);
  }

  /**
   * Checks if all required scripts are injected. If not, inject.
   */
  async #ensureWindowScriptsInjected() {
    const windowScripts = (this.#getBundle()?.scripts || []).filter(script => !!script.window_name);

    await loadAsyncImports(windowScripts);
  }

  /**
   * Loads translation modules
   */
  async #getTranslations() {
    const translations = this.#getBundle()?.scripts.filter(script => script.translation);

    return loadAsyncImports(translations);
  }

  /**
   * Loads plugin modules
   */
  async #getPlugins() {
    const raw = this.getAttribute('plugins');
    const items = raw ? JSON.parse(raw) : [];
    const mappedItems = items.map((item: any) =>
      typeof item === 'string'
        ? { import_name: 'ckeditor5', import_as: item }
        : item,
    );

    return loadAsyncImports(mappedItems);
  }

  /**
   * Gets editor constructor based on type attribute
   */
  async #getEditorConstructor() {
    const CKEditor = await import('ckeditor5');
    const editorType = this.getAttribute('type');

    if (!editorType || !Object.prototype.hasOwnProperty.call(CKEditor, editorType)) {
      throw new Error(`Invalid editor type: ${editorType}`);
    }

    return (CKEditor as any)[editorType] as EditorConstructor;
  }
}

type EditorConstructor = {
  create: (...args: any[]) => Promise<Editor>;
};

type BundleDescription = {
  stylesheets: string[];
  scripts: Array<AsyncImportRawDescription & {
    translation?: boolean;
  }>;
};

customElements.define('ckeditor-component', CKEditorComponent);
