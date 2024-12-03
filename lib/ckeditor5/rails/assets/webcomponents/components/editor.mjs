class CKEditorComponent extends HTMLElement {
  /**
   * List of attributes that trigger updates when changed.
   *
   * @static
   * @returns {string[]} Array of attribute names to observe
   */
  static get observedAttributes() {
    return ['config', 'plugins', 'translations', 'type'];
  }

  /**
   * List of input attributes that trigger updates when changed.
   *
   * @static
   * @returns {string[]} Array of input attribute names to observe
   */
  static get inputAttributes() {
    return ['name', 'required', 'value'];
  }

  /** @type {Promise<import('ckeditor5').Editor>|null} Promise to initialize editor instance */
  instancePromise = Promise.withResolvers();

  /** @type {import('ckeditor5').Watchdog|null} Editor watchdog */
  watchdog = null;

  /** @type {import('ckeditor5').Editor|null} Current editor instance */
  instance = null;

  /** @type {Record<string, HTMLElement>} Map of editable elements by name */
  editables = {};

  /** @type {String} Initial HTML passed to component */
  #initialHTML = '';

  /** @type {CKEditorContextComponent|null} */
  #context = null;

  /** @type {String} ID of editor within context */
  #contextEditorId = null;

  /** @type {Object} Description of ckeditor bundle */
  #bundle = null;

  /** @type {(event: CustomEvent) => void} Event handler for editor change */
  get oneditorchange() {
    return this.#getEventHandler('editorchange');
  }

  set oneditorchange(handler) {
    this.#setEventHandler('editorchange', handler);
  }

  /** @type {(event: CustomEvent) => void} Event handler for editor ready */
  get oneditorready() {
    return this.#getEventHandler('editorready');
  }

  set oneditorready(handler) {
    this.#setEventHandler('editorready', handler);
  }

  /** @type {(event: CustomEvent) => void} Event handler for editor error */
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
   * @param {string} name - Event name without 'on' prefix
   * @returns {Function|null} Event handler or null
   */
  #getEventHandler(name) {
    if (this.hasAttribute(`on${name}`)) {
      const handler = this.getAttribute(`on${name}`);

      if (!isSafeKey(handler)) {
        throw new Error(`Unsafe event handler attribute value: ${handler}`);
      }

      return window[handler] || new Function('event', handler);
    }
    return this[`#${name}Handler`];
  }

  /**
   * Sets event handler function
   *
   * @private
   * @param {string} name - Event name without 'on' prefix
   * @param {Function|string|null} handler - Event handler
   */
  #setEventHandler(name, handler) {
    if (typeof handler === 'string') {
      this.setAttribute(`on${name}`, handler);
    } else {
      this.removeAttribute(`on${name}`);
      this[`#${name}Handler`] = handler;
    }
  }

  /**
   * Lifecycle callback when element is connected to DOM
   * Initializes the editor when DOM is ready
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
    } catch (error) {
      console.error('Failed to initialize editor:', error);

      const event = new CustomEvent('editor-error', { detail: error });

      this.dispatchEvent(event);
      this.oneditorerror?.(event);
    }
  }

  /**
   * Handles attribute changes and reinitializes editor if needed
   * @protected
   * @param {string} name - Name of changed attribute
   * @param {string|null} oldValue - Previous attribute value
   * @param {string|null} newValue - New attribute value
   */
  async attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue !== null &&
        oldValue !== newValue &&
        CKEditorComponent.observedAttributes.includes(name) && this.isConnected) {
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
    } catch (error) {
      console.error('Failed to destroy editor:', error);
    }
  }

  /**
   * Runs a callback after the editor is ready. It waits for editor
   * initialization if needed.
   *
   * @param {(editor: import('ckeditor5').Editor) => void} callback - Callback to run
   * @returns {Promise<void>}
   */
  runAfterEditorReady(callback) {
    if (this.instance) {
      return Promise.resolve(callback(this.instance));
    }

    return this.instancePromise.promise.then(callback);
  }

  /**
   * Determines appropriate editor element tag based on editor type
   *
   * @private
   * @returns {string} HTML tag name to use
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
   *
   * @private
   * @returns {import('ckeditor5').ContextWatchdog|null}
   */
  get #contextWatchdog() {
    return this.#context?.instance;
  }

  /**
   * Destroys the editor instance and watchdog if available
   */
  async #destroy() {
    if (this.#contextEditorId) {
      await this.#contextWatchdog.remove(this.#contextEditorId);
    }

    await this.instance?.destroy();
    await this.watchdog?.destroy();
  }

  /**
   * Gets editor configuration with resolved element references
   *
   * @private
   * @returns {EditorConfig}
   */
  #getConfig() {
    const config = JSON.parse(this.getAttribute('config') || '{}');

    return resolveElementReferences(config);
  }

  /**
   * Creates a new CKEditor instance
   *
   * @private
   * @param {Record<string, HTMLElement>|CKEditorMultiRootEditablesTracker} editablesOrContent - Editable or content
   * @returns {Promise<{ editor: import('ckeditor5').Editor, watchdog: editor: import('ckeditor5').EditorWatchdog }>} Initialized editor instance
   * @throws {Error} When initialization fails
   */
  async #initializeEditor(editablesOrContent) {
    await Promise.all([
      this.#ensureStylesheetsInjected(),
      this.#ensureWindowScriptsInjected(),
    ]);

    const Editor = await this.#getEditorConstructor();
    const [plugins, translations] = await Promise.all([
      this.#getPlugins(),
      this.#getTranslations()
    ]);

    // Depending on the type of the editor the content supplied on the first
    // argument is different. For ClassicEditor it's a element or string, for MultiRootEditor
    // it's an object with editables, for DecoupledEditor it's string.
    let content = editablesOrContent;

    if (editablesOrContent instanceof CKEditorMultiRootEditablesTracker) {
      content = editablesOrContent.getAll();
    } else if (typeof editablesOrContent !== 'string') {
      content = editablesOrContent.main;
    }

    const config = {
      ...this.#getConfig(),
      ...translations.length && {
        translations
      },
      plugins,
    };

    console.warn('Initializing CKEditor with:', { config, watchdog: this.hasWatchdog(), context: this.#context });

    // Initialize watchdog if needed
    let watchdog = null;
    let instance = null;
    let contextId = null;

    if (this.#context) {
      contextId = uid();

      await this.#contextWatchdog.add( {
        creator: (_element, _config) => Editor.create(_element, _config),
        id: contextId,
        sourceElementOrData: content,
        type: 'editor',
        config,
      } );

      instance = this.#contextWatchdog.getItem(contextId);
    } else if (this.hasWatchdog()) {
      // Let's create use with plain watchdog.
      const { EditorWatchdog } = await import('ckeditor5');
      const watchdog = new EditorWatchdog(Editor);

      await watchdog.create(content, config);

      instance = watchdog.editor;
    } else {
      // Let's create the editor without watchdog.
      instance = await Editor.create(content, config);
    }

    console.warn('CKEditor initialized:', {
      instance,
      watchdog, config: instance.config._config,
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
    if(this.isMultiroot()) {
      this.editables = new CKEditorMultiRootEditablesTracker(this, this.#queryEditables());
    } else if (this.isDecoupled()) {
      this.editables = null;
    } else {
      this.editables = this.#queryEditables();
    }

    try {
      const { watchdog, instance, contextId } = await this.#initializeEditor(this.editables || this.#getConfig().initialData || '');

      this.watchdog = watchdog;
      this.instance = instance;
      this.#contextEditorId = contextId;

      this.#setupContentSync();
      this.#setupEditableHeight();
      this.#setupDataChangeListener();

      this.instancePromise.resolve(this.instance);

      // Broadcast editor ready event
      const event = new CustomEvent('editor-ready', { detail: this.instance });

      this.dispatchEvent(event);
      this.oneditorready?.(event);
    } catch (err) {
      this.instancePromise.reject(err);
      throw err;
    }
  }

  /**
   * Sets up data change listener that broadcasts content changes
   *
   * @private
   */
  #setupDataChangeListener() {
    const getRootContent = rootName => this.instance.getData({ rootName });
    const getAllRoots = () =>
      this.instance.model.document
        .getRootNames()
        .reduce((acc, rootName) => ({
          ...acc,
          [rootName]: getRootContent(rootName)
        }), {});

    this.instance?.model.document.on('change:data', () => {
      const event = new CustomEvent('editor-change', {
        detail: {
          editor: this.instance,
          data: getAllRoots(),
        },
        bubbles: true
      });

      this.dispatchEvent(event);
      this.oneditorchange?.(event);
    });
  }

  /**
   * Checks if current editor is classic type
   *
   * @returns {boolean}
   */
  isClassic() {
    return this.getAttribute('type') === 'ClassicEditor';
  }

  /**
   * Checks if current editor is multiroot type
   *
   * @returns {boolean}
   */
  isMultiroot() {
    return this.getAttribute('type') === 'MultiRootEditor';
  }

  /**
   * Checks if current editor is decoupled type
   *
   * @returns {boolean}
   */
  isDecoupled() {
    return this.getAttribute('type') === 'DecoupledEditor';
  }

  /**
   * Checks if current editor has watchdog enabled
   *
   * @returns {boolean}
   */
  hasWatchdog() {
    return this.getAttribute('watchdog') === 'true';
  }

  /**
   * Queries and validates editable elements
   *
   * @private
   * @returns {Record<string, HTMLElement>}
   * @throws {Error} When required editables are missing
   */
  #queryEditables() {
    if (this.isDecoupled()) {
      return {};
    }

    if (this.isMultiroot()) {
      const editables = [...this.querySelectorAll('ckeditor-editable-component')];

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
        textarea.setAttribute(attr, this.getAttribute(attr));
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
      textarea.value = this.instance.getData();
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
        border: 'none'
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
    if (!this.isClassic()) {
      return;
    }

    const { instance } = this;
    const height = Number.parseInt(this.getAttribute('editable-height'), 10);

    if (Number.isNaN(height)) {
      return;
    }

    instance.editing.view.change((writer) => {
      writer.setStyle('height', `${height}px`, instance.editing.view.document.getRoot());
    });
  }

  /**
   * Gets bundle JSON description from translations attribute
   */
  #getBundle() {
    return this.#bundle ||= JSON.parse(this.getAttribute('bundle'));
  }


  /**
   * Checks if all required stylesheets are injected. If not, inject.
   */
  async #ensureStylesheetsInjected() {
    await loadAsyncCSS(this.#getBundle().stylesheets || []);
  }

  /**
   * Checks if all required scripts are injected. If not, inject.
   */
  async #ensureWindowScriptsInjected() {
    const windowScripts = (this.#getBundle().scripts || []).filter(script => !!script.window_name);

    await loadAsyncImports(windowScripts);
  }

  /**
   * Loads translation modules
   *
   * @private
   * @returns {Promise<Array<any>>}
   */
  async #getTranslations() {
    const translations = this.#getBundle().scripts.filter(script => script.translation);

    return loadAsyncImports(translations);
  }

  /**
   * Loads plugin modules
   *
   * @private
   * @returns {Promise<Array<any>>}
   */
  async #getPlugins() {
    const raw = this.getAttribute('plugins');
    const items = raw ? JSON.parse(raw) : [];
    const mappedItems = items.map(item =>
      typeof item === 'string'
        ? { import_name: 'ckeditor5', import_as: item }
        : item
    );

    return loadAsyncImports(mappedItems);
  }

  /**
   * Gets editor constructor based on type attribute
   *
   * @private
   * @returns {Promise<typeof import('ckeditor5').Editor>}
   * @throws {Error} When editor type is invalid
   */
  async #getEditorConstructor() {
    const CKEditor = await import('ckeditor5');
    const editorType = this.getAttribute('type');

    if (!editorType || !Object.prototype.hasOwnProperty.call(CKEditor, editorType)) {
      throw new Error(`Invalid editor type: ${editorType}`);
    }

    return CKEditor[editorType];
  }
}

class CKEditorMultiRootEditablesTracker {
  #editorElement;
  #editables;

  /**
   * Creates new tracker instance wrapped in a Proxy for dynamic property access
   *
   * @param {CKEditorComponent} editorElement - Parent editor component reference
   * @param {Record<string, HTMLElement>} initialEditables - Initial editable elements
   * @returns {Proxy<CKEditorMultiRootEditablesTracker>} Proxy wrapping the tracker
   */
  constructor(editorElement, initialEditables = {}) {
    this.#editorElement = editorElement;
    this.#editables = initialEditables;

    return new Proxy(this, {
      /**
       * Handles property access, returns class methods or editable elements
       *
       * @param {CKEditorMultiRootEditablesTracker} target - The tracker instance
       * @param {string|symbol} name - Property name being accessed
       */
      get(target, name) {
        if (typeof target[name] === 'function') {
          return target[name].bind(target);
        }

        return target.#editables[name];
      },

      /**
       * Handles setting new editable elements, triggers root attachment
       *
       * @param {CKEditorMultiRootEditablesTracker} target - The tracker instance
       * @param {string} name - Name of the editable root
       * @param {HTMLElement} element - Element to attach as editable
       */
      set(target, name, element) {
        if (target.#editables[name] !== element) {
          target.attachRoot(name, element);
          target.#editables[name] = element;
        }
        return true;
      },

      /**
       * Handles removing editable elements, triggers root detachment
       *
       * @param {CKEditorMultiRootEditablesTracker} target - The tracker instance
       * @param {string} name - Name of the root to remove
       */
      deleteProperty(target, name) {
        target.detachRoot(name);
        delete target.#editables[name];
        return true;
      }
    });
  }

  /**
   * Attaches a new editable root to the editor.
   * Creates new editor root and binds UI elements.
   *
   * @param {string} name - Name of the editable root
   * @param {HTMLElement} element - DOM element to use as editable
   * @returns {Promise<void>} Resolves when root is attached
   */
  async attachRoot(name, element) {
    await this.detachRoot(name);

    return this.#editorElement.runAfterEditorReady((editor) => {
      const { ui, editing, model } = editor;

      editor.addRoot(name, {
        isUndoable: false,
        data: element.innerHTML
      });

      const root = model.document.getRoot(name);

      if (ui.getEditableElement(name)) {
        editor.detachEditable(root);
      }

      const editable = ui.view.createEditable(name, element);
      ui.addEditable(editable);
      editing.view.forceRender();
    });
  }

  /**
   * Detaches an editable root from the editor.
   * Removes editor root and cleans up UI bindings.
   *
   * @param {string} name - Name of root to detach
   * @returns {Promise<void>} Resolves when root is detached
   */
  async detachRoot(name) {
    return this.#editorElement.runAfterEditorReady(editor => {
      const root = editor.model.document.getRoot(name);

      if (root) {
        editor.detachEditable(root);
        editor.detachRoot(name, true);
      }
    });
  }

  /**
   * Gets all currently tracked editable elements
   *
   * @returns {Record<string, HTMLElement>} Map of all editable elements
   */
  getAll() {
    return this.#editables;
  }
}

customElements.define('ckeditor-component', CKEditorComponent);
