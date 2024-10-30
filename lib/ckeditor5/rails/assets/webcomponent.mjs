/**
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
   * List of attributes that trigger updates when changed
   * @static
   * @returns {string[]} Array of attribute names to observe
   */
  static get observedAttributes() {
    return ['config', 'plugins', 'translations', 'type'];
  }

  /** @type {Promise<import('ckeditor5').Editor>|null} Promise to initialize editor instance */
  instancePromise = Promise.withResolvers();

  /** @type {import('ckeditor5').Editor|null} Current editor instance */
  instance = null;

  /** @type {Record<string, HTMLElement>} Map of editable elements by name */
  editables = {};

  /**
   * Lifecycle callback when element is connected to DOM
   * Initializes the editor when DOM is ready
   * @protected
   */
  connectedCallback() {
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
    } catch (error) {
      console.error('Failed to destroy editor:', error);
    }
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
   * Initializes a new CKEditor instance
   * @private
   * @returns {Promise<import('ckeditor5').Editor>} Initialized editor instance
   * @throws {Error} When initialization fails
   */
  async #initializeEditor() {
    const Editor = await this.#getEditorConstructor();
    const [plugins, translations] = await Promise.all([
      this.#getPlugins(),
      this.#getTranslations()
    ]);

    const instance = await Editor.create(
      this.#isMultiroot() ? this.editables : this.editables.main,
      {
        ...this.#getConfig(),
        plugins,
        translations
      }
    );

    this.dispatchEvent(new CustomEvent('editor-ready', { detail: instance }));
    return instance;
  }

  /**
   * Re-initializes the editor by destroying existing instance and creating new one
   *
   * @private
   * @returns {Promise<void>}
   */
  async #reinitializeEditor() {
    await this.instance?.destroy();

    this.instance = null;
    this.style.display = 'block';

    if (!this.#isMultiroot()) {
      this.innerHTML = `<${this.#editorElementTag}></${this.#editorElementTag}>`;
    }

    this.editables = this.#queryEditables();

    try {
      this.instance = await this.#initializeEditor();
      this.instancePromise.resolve(this.instance);
    } catch (err) {
      this.instancePromise.reject(err);
      throw err;
    } finally {
      this.instancePromise = Promise.withResolvers();
    }
  }

  /**
   * Checks if current editor is multiroot type
   *
   * @private
   * @returns {boolean}
   */
  #isMultiroot() {
    return this.getAttribute('type') === 'MultiRootEditor';
  }

  /**
   * Parses editor configuration from config attribute
   *
   * @private
   * @returns {EditorConfig}
   */
  #getConfig() {
    return JSON.parse(this.getAttribute('config') || '{}');
  }

  /**
   * Queries and validates editable elements
   *
   * @private
   * @returns {Record<string, HTMLElement>}
   * @throws {Error} When required editables are missing
   */
  #queryEditables() {
    if (this.#isMultiroot()) {
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
    return this.getAttribute('name');
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
    const editorComponent = this.#queryEditorElement();

    if (!editorComponent ) {
      throw new Error('ckeditor-editable-component must be a child of ckeditor-component');
    }

    this.innerHTML = `<div>${this.innerHTML}</div>`;
    this.style.display = 'block';

    editorComponent.editables[this.name] = this;
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
    return this.closest('ckeditor-component');
  }
}

/**
 * Custom HTML element that represents a CKEditor toolbar component.
 * Manages the toolbar placement and integration with the main editor component.
 *
 * @extends HTMLElement
 * @customElement ckeditor-toolbar
 * @example
 * <ckeditor-toolbar></ckeditor-toolbar>
 */
class CKEditorToolbarComponent extends HTMLElement {
  /**
   * Lifecycle callback when element is added to DOM
   * Adds the toolbar to the editor UI
   */
  async connectedCallback() {
    const editor = await this.#queryEditorElement().instancePromise.promise;

    this.appendChild(editor.ui.view.toolbar.element);
  }

  /**
   * Finds the parent editor component
   *
   * @private
   * @returns {CKEditorComponent|null} Parent editor component or null if not found
   */
  #queryEditorElement() {
    return this.closest('ckeditor-component');
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
  return Promise.all(
    imports.map(async ({ import_name, import_as, window_name }) => {
      if (window_name && Object.prototype.hasOwnProperty.call(window, window_name)) {
        return window[window_name];
      }

      const module = await import(import_name);
      return import_as ? module[import_as] : module.default;
    })
  );
}

customElements.define('ckeditor-component', CKEditorComponent);
customElements.define('ckeditor-editable-component', CKEditorEditableComponent);
customElements.define('ckeditor-toolbar-component', CKEditorToolbarComponent);
