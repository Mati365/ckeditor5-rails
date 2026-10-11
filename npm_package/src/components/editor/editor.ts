import type { Editor } from 'ckeditor5';

import type { AsyncImportRawDescription } from '../../helpers';
import type { CKEditorContextComponent } from '../context';
import type { CKEditorEditableComponent } from '../editable';

import {
  createInstancePromise,
  execIfDOMReady,
  isSafeKey,
  loadAsyncCSS,
  loadAsyncImports,
  resolveConfigElementReferences,
} from '../../helpers';
import { CKEditorMultiRootEditablesTracker } from './multiroot-editables-tracker';

export class CKEditorComponent extends HTMLElement {
  instancePromise = createInstancePromise<Editor>();

  instance: Editor | null = null;

  editables: Record<string, HTMLElement> | null = Object.create(null);

  #initialHTML: string = '';

  #context: CKEditorContextComponent | null = null;

  /**
   * Incremented on every (re)initialization and on disconnect. An initialization that finishes
   * with a different value is stale and destroys the editor it created.
   */
  #generation = 0;

  /**
   * Unregisters the error callback of the current editor instance.
   */
  #offEditorError: VoidFunction | null = null;

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
      return resolveInlineEventHandler(this.getAttribute(`on${name}`)!);
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

    execIfDOMReady(async () => {
      if (this.#context) {
        try {
          await this.#context.instancePromise.promise;
        }
        catch (error) {
          this.#reportError('Failed to initialize editor:', error);
          return;
        }

        this.#context.registerEditor(this);
      }

      // Errors are reported by `reinitializeEditor()` itself.
      await this.reinitializeEditor().catch(() => {});
    });
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
      // Errors are reported by `reinitializeEditor()` itself.
      await this.reinitializeEditor().catch(() => {});
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

    // Makes an initialization in progress destroy the editor it creates.
    this.#generation++;

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
    return getEditorElementTag(this.getAttribute('type'));
  }

  /**
   * Destroys the current editor instance, if any.
   */
  async #destroy() {
    const instance = this.#detachInstance();

    // The context destroys its editors when it's destroyed (or reinitialized), so the editor
    // may be already destroyed here.
    if (instance && instance.state !== 'destroyed') {
      await instance.destroy();
    }
  }

  /**
   * Detaches the current editor instance from the component without destroying it.
   *
   * @returns The detached instance or `null` if there was none.
   */
  #detachInstance(): Editor | null {
    const { instance } = this;

    if (!instance) {
      return null;
    }

    this.#offEditorError?.();
    this.#offEditorError = null;

    this.instance = null;
    this.instancePromise = createInstancePromise<Editor>();

    return instance;
  }

  /**
   * Logs the error and dispatches the `editor-error` event.
   */
  #reportError(message: string, error: unknown) {
    console.error(message, error);

    const event = new CustomEvent('editor-error', { detail: error });

    this.dispatchEvent(event);
    this.oneditorerror?.(event);
  }

  /**
   * Gets editor configuration with resolved element references
   */
  #getConfig() {
    return parseEditorConfig(this.getAttribute('config'));
  }

  /**
   * Creates a new CKEditor instance
   */
  async #initializeEditor(editablesOrContent: Record<string, HTMLElement | string> | CKEditorMultiRootEditablesTracker | string | HTMLElement): Promise<Editor> {
    // Always take the current context instance. It may have been reinitialized in the meantime.
    const context = this.#context ? await this.#context.instancePromise.promise : null;

    await Promise.all([
      this.#ensureStylesheetsInjected(),
      this.#ensureWindowScriptsInjected(),
    ]);

    const { isMultiroot, content } = resolveEditorContent(editablesOrContent);
    const beforeInitEventDetails = buildBeforeInitEventDetails(content, isMultiroot);

    window.dispatchEvent(
      new CustomEvent('ckeditor:attach:before', { detail: beforeInitEventDetails }),
    );

    const Editor = await this.#getEditorConstructor();
    const [plugins, translations] = await Promise.all([
      this.#getPlugins(),
      this.#getTranslations(),
    ]);

    const config: Record<string, any> = {
      ...this.#getConfig(),
      ...translations.length && {
        translations,
      },
      plugins,
    };

    applyContentToConfig(config, content, isMultiroot, this.isClassic());

    window.dispatchEvent(
      new CustomEvent('ckeditor:attach', { detail: { config, ...beforeInitEventDetails } }),
    );

    return Editor.create(
      context
        ? { ...config, context }
        : config,
    );
  }

  /**
   * Re-initializes the editor by destroying existing instance and creating new one
   *
   * @private
   * @returns {Promise<void>}
   */
  async reinitializeEditor() {
    const generation = ++this.#generation;

    try {
      await this.#destroy();

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

      const [instance, { onEditorError }] = await Promise.all([
        this.#initializeEditor(this.editables || this.#getConfig().root?.initialData || ''),
        import('ckeditor5'),
      ]);

      // The element was disconnected or the editor was reinitialized again in the meantime.
      if (generation !== this.#generation) {
        if (instance.state !== 'destroyed') {
          await instance.destroy();
        }

        return;
      }

      this.instance = instance;

      // Nothing restarts the editor after a crash anymore and its state may be inconsistent,
      // so lock it in read-only mode to avoid submitting broken data with the form.
      // Errors of the context are handled by the context component.
      this.#offEditorError = onEditorError(({ error, source }) => {
        if (source !== instance) {
          return;
        }

        instance.enableReadOnlyMode('error-handling');
        this.#reportError('Editor failed:', error);
      });

      // The editor may be destroyed externally (by the context or manually using `.destroy()`).
      instance.once('destroy', () => {
        if (this.instance === instance) {
          this.#detachInstance();
        }
      });

      this.#setupContentSync();
      this.#setupEditableHeight();
      this.#setupDataChangeListener();

      this.instancePromise.resolve(instance);

      // Broadcast editor ready event
      const event = new CustomEvent('editor-ready', { detail: instance });

      this.dispatchEvent(event);
      this.oneditorready?.(event);
    }
    catch (error) {
      // A newer initialization (or disconnect) owns the state now.
      if (generation !== this.#generation) {
        return;
      }

      // Reject callers waiting in `runAfterEditorReady()` and let the next initialization start with a fresh promise.
      this.instancePromise.reject(error);
      this.instancePromise = createInstancePromise<Editor>();

      this.#reportError('Failed to initialize editor:', error);

      throw error;
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
   * Queries and validates editable elements
   */
  #queryEditables() {
    if (this.isDecoupled()) {
      return {};
    }

    if (this.isMultiroot()) {
      const editables = [...this.querySelectorAll('ckeditor-editable-component')] as CKEditorEditableComponent[];

      return buildEditablesMap(editables);
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

    copyAttributes(this, textarea, CKEditorComponent.inputAttributes);
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

      hideTextareaVisually(textarea);
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

    const height = parseEditableHeight(this.getAttribute('editable-height'));

    if (height === null) {
      return;
    }

    applyEditableHeight(this.instance!, height);
  }

  /**
   * Gets bundle JSON description from translations attribute
   */
  #getBundle(): BundleDescription {
    return (this.#bundle ||= parseBundleDescription(this.getAttribute('bundle'))) as BundleDescription;
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
    return loadAsyncImports(parsePluginDescriptors(this.getAttribute('plugins')));
  }

  /**
   * Gets editor constructor based on type attribute
   */
  async #getEditorConstructor() {
    const CKEditor = await import('ckeditor5');

    return resolveEditorConstructor(CKEditor, this.getAttribute('type'));
  }
}

/**
 * Resolves the DOM tag used for the main editable element based on the editor type.
 */
function getEditorElementTag(type: string | null): 'textarea' | 'div' {
  switch (type) {
    case 'ClassicEditor':
      return 'textarea';

    default:
      return 'div';
  }
}

/**
 * Parses the `config` attribute JSON and resolves any `$element` references within it.
 */
function parseEditorConfig(raw: string | null) {
  const config = JSON.parse(raw || '{}');

  return resolveConfigElementReferences(config);
}

/**
 * Resolves the `editablesOrContent` argument passed to `#initializeEditor` into a
 * normalized `{ isMultiroot, content }` shape.
 */
function resolveEditorContent(
  editablesOrContent: Record<string, HTMLElement | string> | CKEditorMultiRootEditablesTracker | string | HTMLElement,
) {
  const isMultiroot = editablesOrContent instanceof CKEditorMultiRootEditablesTracker;

  let content: any = editablesOrContent;

  if (isMultiroot) {
    content = (editablesOrContent as CKEditorMultiRootEditablesTracker).getAll();
  }
  else if (typeof editablesOrContent !== 'string') {
    content = (editablesOrContent as any)['main'];
  }

  return { isMultiroot, content };
}

/**
 * Builds the payload broadcasted with the `ckeditor:attach:before` / `ckeditor:attach` events.
 */
function buildBeforeInitEventDetails(content: any, isMultiroot: boolean) {
  return {
    ...content instanceof HTMLElement && { element: content },
    ...typeof content === 'string' && { data: content },
    ...isMultiroot && { editables: content },
  };
}

/**
 * Applies the resolved editor content to the editor configuration, using the
 * non-deprecated `attachTo` / `root` / `roots` options instead of the legacy
 * `Editor.create( sourceElementOrData, config )` signature.
 */
function applyContentToConfig(
  config: Record<string, any>,
  content: any,
  isMultiroot: boolean,
  isClassic: boolean,
) {
  if (isMultiroot) {
    config['roots'] = buildRootsConfig(content as Record<string, CKEditorEditableComponent>);
  }
  else if (isClassic && content instanceof HTMLElement) {
    config['attachTo'] = content;
  }
  else if (content instanceof HTMLElement) {
    config['root'] = { ...config['root'], element: content };
  }
  else if (typeof content === 'string') {
    config['root'] = { ...config['root'], initialData: content };
  }
}

/**
 * Builds the `roots` configuration object used to initialize a `MultiRootEditor`.
 */
function buildRootsConfig(editables: Record<string, CKEditorEditableComponent>) {
  return Object.fromEntries(
    Object.entries(editables).map(([name, element]) => {
      const modelElement = (element as any).modelElement as string | undefined;
      const initialData = (element as any).initialData as string | undefined;

      return [
        name,
        {
          element,
          initialData: initialData ?? element.innerHTML,
          ...modelElement && { modelElement },
        },
      ];
    }),
  );
}

/**
 * Builds a `{ [name]: element }` map out of a list of editable components, validating
 * that each one has a `name` attribute set.
 */
function buildEditablesMap(elements: CKEditorEditableComponent[]): Record<string, CKEditorEditableComponent> {
  return elements.reduce((acc, element) => {
    if (!element.name) {
      throw new Error('Editable component missing required "name" attribute');
    }

    acc[element.name] = element;

    return acc;
  }, Object.create(null));
}

/**
 * Copies the given attributes from the source element to the target element, when present.
 */
function copyAttributes(source: Element, target: Element, attrNames: readonly string[]) {
  for (const attr of attrNames) {
    if (source.hasAttribute(attr)) {
      target.setAttribute(attr, source.getAttribute(attr)!);
    }
  }
}

/**
 * Hides a `<textarea>` element visually while keeping it accessible to form submissions.
 */
function hideTextareaVisually(textarea: HTMLTextAreaElement) {
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
}

/**
 * Parses the `editable-height` attribute into a pixel value, or `null` when absent/invalid.
 */
function parseEditableHeight(raw: string | null): number | null {
  if (raw === null) {
    return null;
  }

  const height = Number.parseInt(raw, 10);

  return Number.isNaN(height) ? null : height;
}

/**
 * Applies a fixed editing view height to the given editor instance.
 */
function applyEditableHeight(instance: Editor, height: number) {
  instance.editing.view.change((writer) => {
    writer.setStyle('height', `${height}px`, instance.editing.view.document.getRoot()!);
  });
}

/**
 * Parses the `bundle` attribute JSON into a `BundleDescription`.
 */
function parseBundleDescription(raw: string | null): BundleDescription {
  return JSON.parse(raw!);
}

/**
 * Parses the `plugins` attribute JSON into async import descriptors.
 */
function parsePluginDescriptors(raw: string | null) {
  const items = raw ? JSON.parse(raw) : [];

  return items.map((item: any) =>
    typeof item === 'string'
      ? { import_name: 'ckeditor5', import_as: item }
      : item,
  );
}

/**
 * Resolves the CKEditor 5 editor constructor matching the `type` attribute.
 */
function resolveEditorConstructor(ckeditorModule: object, editorType: string | null): EditorConstructor {
  if (!editorType || !Object.prototype.hasOwnProperty.call(ckeditorModule, editorType)) {
    throw new Error(`Invalid editor type: ${editorType}`);
  }

  return (ckeditorModule as any)[editorType] as EditorConstructor;
}

/**
 * Resolves an inline event handler attribute value (e.g. `oneditorready="doSomething(event)"`)
 * into a callable function, looking it up on `window` first.
 */
function resolveInlineEventHandler(handlerAttr: string): Function {
  if (!isSafeKey(handlerAttr)) {
    throw new Error(`Unsafe event handler attribute value: ${handlerAttr}`);
  }

  // eslint-disable-next-line no-new-func
  return (window as any)[handlerAttr] || new Function('event', handlerAttr);
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
