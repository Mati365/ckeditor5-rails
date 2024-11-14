/**
 * Custom web component for integrating CKEditor 5 into web applications.
 *
 * @class
 * @extends HTMLElement
 *
 * @property {import('ckeditor5').Editor|null} instance - The current CKEditor instance
 * @property {Record<string, HTMLElement>} editables - Object containing editable elements
 *
 * @fires editor-ready - Fired when editor is initialized with the editor instance as detail
 * @fires editor-error - Fired when initialization fails with the error as detail
 *
 * @example
 * // Basic usage with Classic Editor
 * <ckeditor-component type="ClassicEditor" config='{"toolbar": ["bold", "italic"]}'>
 * </ckeditor-component>
 *
 * // Multiroot editor with multiple editables
 * <ckeditor-component type="MultirootEditor">
 *   <ckeditor-editable-component name="title">Title content</ckeditor-editable-component>
 *   <ckeditor-editable-component name="content">Main content</ckeditor-editable-component>
 * </ckeditor-component>
 */
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

  /**
   * Lifecycle callback when element is connected to DOM
   * Initializes the editor when DOM is ready
   * @protected
   */
  connectedCallback() {
    this.#initialHTML = this.innerHTML;

    try {
      execIfDOMReady(() => this.#reinitializeEditor());
    } catch (error) {
      console.error('Failed to initialize editor:', error);
      this.dispatchEvent(new CustomEvent('editor-error', { detail: error }));
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
      await this.#reinitializeEditor();
    }
  }

  /**
   * Lifecycle callback when element is removed from DOM
   * Destroys the editor instance
   * @protected
   */
  async disconnectedCallback() {
    try {
      await this.instance?.destroy();
      await this.watchdog?.destroy();
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
   * Resolves element references in configuration object.
   * Looks for objects with { $element: "selector" } format and replaces them with actual elements.
   *
   * @private
   * @param {Object} obj - Configuration object to process
   * @returns {Object} Processed configuration object with resolved element references
   */
  #resolveElementReferences(obj) {
    if (!obj || typeof obj !== 'object') {
      return obj;
    }

    if (Array.isArray(obj)) {
      return obj.map(item => this.#resolveElementReferences(item));
    }

    const result = Object.create(null);

    for (const key of Object.getOwnPropertyNames(obj)) {
      if (!isSafeKey(key)) {
        console.warn(`Suspicious key "${key}" detected in config, skipping`);
        continue;
      }

      const value = obj[key];

      if (value && typeof value === 'object') {
        if (value.$element) {
          const selector = value.$element;

          if (typeof selector !== 'string') {
            console.warn(`Invalid selector type for "${key}", expected string`);
            continue;
          }

          const element = document.querySelector(selector);

          if (!element) {
            console.warn(`Element not found for selector: ${selector}`);
          }

          result[key] = element || null;
        } else {
          result[key] = this.#resolveElementReferences(value);
        }
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  /**
   * Gets editor configuration with resolved element references
   *
   * @private
   * @returns {EditorConfig}
   */
  #getConfig() {
    const config = JSON.parse(this.getAttribute('config') || '{}');

    return this.#resolveElementReferences(config);
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

    console.warn('Initializing CKEditor with:', { config, watchdog: this.hasWatchdog() });

    // Initialize watchdog if needed
    let watchdog = null;
    let instance = null;

    if (this.hasWatchdog()) {
      const { EditorWatchdog } = await import('ckeditor5');
      const watchdog = new EditorWatchdog(Editor);

      await watchdog.create(content, config);

      instance = watchdog.editor;
    } else {
      instance = await Editor.create(content, config);
    }

    this.dispatchEvent(new CustomEvent('editor-ready', { detail: instance }));

    return {
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
  async #reinitializeEditor() {
    if (this.instance) {
      this.instancePromise = Promise.withResolvers();

      await this.instance.destroy();
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
      const { watchdog, instance } = await this.#initializeEditor(this.editables || this.#getConfig().initialData || '');

      this.watchdog = watchdog;
      this.instance = instance;

      this.#setupContentSync();
      this.#setupEditableHeight();

      this.instancePromise.resolve(this.instance);
    } catch (err) {
      this.instancePromise.reject(err);
      throw err;
    }
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
   * Loads translation modules
   *
   * @private
   * @returns {Promise<Array<any>>}
   */
  async #getTranslations() {
    const raw = this.getAttribute('translations');
    return loadAsyncImports(raw ? JSON.parse(raw) : []);
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

/**
 * Tracks and manages editable roots for CKEditor MultiRoot editor.
 * Provides a proxy-based API for dynamically managing editable elements with automatic
 * attachment/detachment of editor roots.
 *
 * @class
 * @property {CKEditorComponent} #editorElement - Reference to parent editor component
 * @property {Record<string, HTMLElement>} #editables - Map of tracked editable elements
 */
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

/**
 * Custom HTML element representing an editable region for CKEditor.
 * Must be used as a child of ckeditor-component element.
 *
 * @customElement ckeditor-editable-component
 * @extends HTMLElement
 *
 * @property {string} name - The name of the editable region, accessed via getAttribute
 * @property {HTMLDivElement} editableElement - The div element containing editable content
 *
 * @fires connectedCallback - When the element is added to the DOM
 * @fires attributeChangedCallback - When element attributes change
 * @fires disconnectedCallback - When the element is removed from the DOM
 *
 * @throws {Error} Throws error if not used as child of ckeditor-component
 *
 * @example
 * <ckeditor-component>
 *   <ckeditor-editable-component name="main">
 *     Content goes here
 *   </ckeditor-editable-component>
 * </ckeditor-component>
 */
class CKEditorEditableComponent extends HTMLElement {
  /**
   * List of attributes that trigger updates when changed
   *
   * @static
   * @returns {string[]} Array of attribute names to observe
   */
  static get observedAttributes() {
    return ['name'];
  }

  /**
   * Gets the name of this editable region
   *
   * @returns {string} The name attribute value
   */
  get name() {
    // The default value is set mainly for decoupled editors where the name is not required.
    return this.getAttribute('name') || 'editable';
  }

  /**
   * Gets the actual editable DOM element
   * @returns {HTMLDivElement|null} The div element containing editable content
   */
  get editableElement() {
    return this.querySelector('div');
  }

  /**
   * Lifecycle callback when element is added to DOM
   * Sets up the editable element and registers it with the parent editor
   *
   * @throws {Error} If not used as child of ckeditor-component
   */
  connectedCallback() {
    execIfDOMReady(() => {
      const editorComponent = this.#queryEditorElement();

      if (!editorComponent ) {
        throw new Error('ckeditor-editable-component must be a child of ckeditor-component');
      }

      this.innerHTML = `<div>${this.innerHTML}</div>`;
      this.style.display = 'block';

      if (editorComponent.isDecoupled()) {
        editorComponent.runAfterEditorReady(editor => {
          this.appendChild(editor.ui.view[this.name].element);
        });
      } else {
        if (!this.name) {
          throw new Error('Editable component missing required "name" attribute');
        }

        editorComponent.editables[this.name] = this;
      }
    });
  }

  /**
   * Lifecycle callback for attribute changes
   * Handles name changes and propagates other attributes to editable element
   *
   * @param {string} name - Name of changed attribute
   * @param {string|null} oldValue - Previous value
   * @param {string|null} newValue - New value
   */
  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue === newValue) {
      return;
    }

    if (name === 'name') {
      if (!oldValue) {
        return;
      }

      const editorComponent = this.#queryEditorElement();

      if (editorComponent) {
        editorComponent.editables[newValue] = editorComponent.editables[oldValue];
        delete editorComponent.editables[oldValue];
      }
    } else {
      this.editableElement.setAttribute(name, newValue);
    }
  }

  /**
   * Lifecycle callback when element is removed
   * Un-registers this editable from the parent editor
   */
  disconnectedCallback() {
    const editorComponent = this.#queryEditorElement();

    if (editorComponent) {
      delete editorComponent.editables[this.name];
    }
  }

  /**
   * Finds the parent editor component
   *
   * @private
   * @returns {CKEditorComponent|null} Parent editor component or null if not found
   */
  #queryEditorElement() {
    return this.closest('ckeditor-component') || document.body.querySelector('ckeditor-component');
  }
}

/**
 * Custom HTML element that represents a CKEditor UI part component.
 * It helpers with management of toolbar and other elements.
 *
 * @extends HTMLElement
 * @customElement ckeditor-ui-part-component
 * @example
 * <ckeditor-ui-part-component></ckeditor-ui-part-component>
 */
class CKEditorUIPartComponent extends HTMLElement {
  /**
   * Lifecycle callback when element is added to DOM
   * Adds the toolbar to the editor UI
   */
  connectedCallback() {
    execIfDOMReady(async () => {
      const uiPart = this.getAttribute('name');
      const editor = await this.#queryEditorElement().instancePromise.promise;

      this.appendChild(editor.ui.view[uiPart].element);
    });
  }

  /**
   * Finds the parent editor component
   *
   * @private
   * @returns {CKEditorComponent|null} Parent editor component or null if not found
   */
  #queryEditorElement() {
    return this.closest('ckeditor-component') || document.body.querySelector('ckeditor-component');
  }
}

/**
 * Executes callback when DOM is ready
 *
 * @param {() => void} callback - Function to execute
 */
function execIfDOMReady(callback) {
  switch (document.readyState) {
    case 'loading':
      document.addEventListener('DOMContentLoaded', callback, { once: true });
      break;

    case 'interactive':
    case 'complete':
      setTimeout(callback, 0);
      break;

    default:
      console.warn('Unexpected document.readyState:', document.readyState);
      setTimeout(callback, 0);
  }
}

/**
 * Dynamically imports modules based on configuration
 *
 * @param {Array<ImportConfig>} imports - Array of import configurations
 * @returns {Promise<Array<any>>} Loaded modules
 */
function loadAsyncImports(imports = []) {
  const loadInlinePlugin = async ({ name, code }) => {
    const module = await import(`data:text/javascript,${encodeURIComponent(code)}`);

    if (!module.default) {
      throw new Error(`Inline plugin "${name}" must export a default class/function!`);
    }

    return module.default;
  };

  const loadExternalPlugin = async ({ import_name, import_as, window_name }) => {
    if (window_name) {
      if (!Object.prototype.hasOwnProperty.call(window, window_name)) {
        throw new Error(
          `Plugin window['${window_name}'] not found in global scope. ` +
          'Please ensure the plugin is loaded before CKEditor initialization.'
        );
      }

      return window[window_name];
    }

    const module = await import(import_name);
    const imported = module[import_as || 'default'];

    if (!imported) {
      throw new Error(`Plugin "${import_as}" not found in the ESM module "${import_name}"!`);
    }

    return imported;
  };

  return Promise.all(imports.map(item => {
    switch(item.type) {
      case 'inline':
        return loadInlinePlugin(item);

      case 'external':
      default:
        return loadExternalPlugin(item);
    }
  }));
}


/**
 * Checks if a key is safe to use in configuration objects to prevent prototype pollution.
 *
 * @param {string} key - Key name to check
 * @returns {boolean} True if key is safe to use.
 */
function isSafeKey(key) {
  return typeof key === 'string' &&
          key !== '__proto__' &&
          key !== 'constructor' &&
          key !== 'prototype';
}

customElements.define('ckeditor-component', CKEditorComponent);
customElements.define('ckeditor-editable-component', CKEditorEditableComponent);
customElements.define('ckeditor-ui-part-component', CKEditorUIPartComponent);
