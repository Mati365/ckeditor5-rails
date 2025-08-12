import type { MultiRootEditor } from 'ckeditor5';

import type { CKEditorComponent } from './editor';

export class CKEditorMultiRootEditablesTracker {
  #editorElement: CKEditorComponent;
  #editables: Record<string, HTMLElement>;

  /**
   * Creates new tracker instance wrapped in a Proxy for dynamic property access
   *
   * @param editorElement - Parent editor component reference
   * @param initialEditables - Initial editable elements
   * @returns Proxy wrapping the tracker
   */
  constructor(
    editorElement: CKEditorComponent,
    initialEditables: Record<string, HTMLElement> = {},
  ) {
    this.#editorElement = editorElement;
    this.#editables = initialEditables;

    return new Proxy(this, {
      /**
       * Handles property access, returns class methods or editable elements
       *
       * @param target - The tracker instance
       * @param name - Property name being accessed
       */
      get(target: CKEditorMultiRootEditablesTracker, name: string) {
        if (typeof (target as any)[name] === 'function') {
          return (target as any)[name].bind(target);
        }

        return target.#editables[name];
      },

      /**
       * Handles setting new editable elements, triggers root attachment
       *
       * @param target - The tracker instance
       * @param name - Name of the editable root
       * @param element - Element to attach as editable
       */
      set(target: CKEditorMultiRootEditablesTracker, name: string, element: HTMLElement) {
        if (target.#editables[name] !== element) {
          void target.attachRoot(name, element);
          target.#editables[name] = element;
        }
        return true;
      },

      /**
       * Handles removing editable elements, triggers root detachment
       *
       * @param target - The tracker instance
       * @param name - Name of the root to remove
       */
      deleteProperty(target: CKEditorMultiRootEditablesTracker, name: string) {
        void target.detachRoot(name);
        delete target.#editables[name];

        return true;
      },
    });
  }

  /**
   * Attaches a new editable root to the editor.
   * Creates new editor root and binds UI elements.
   *
   * @param name - Name of the editable root
   * @param element - DOM element to use as editable
   * @returns Resolves when root is attached
   */
  async attachRoot(name: string, element: HTMLElement) {
    await this.detachRoot(name);

    return this.#editorElement.runAfterEditorReady<MultiRootEditor>((editor) => {
      const { ui, editing, model } = editor;

      editor.addRoot(name, {
        isUndoable: false,
        data: element.innerHTML,
      });

      const root = model.document.getRoot(name);

      if (ui.getEditableElement(name)) {
        editor.detachEditable(root!);
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
   * @param name - Name of root to detach
   * @returns Resolves when root is detached
   */
  async detachRoot(name: string) {
    return this.#editorElement.runAfterEditorReady<MultiRootEditor>((editor) => {
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
   * @returns Map of all editable elements
   */
  getAll() {
    return this.#editables;
  }
}
