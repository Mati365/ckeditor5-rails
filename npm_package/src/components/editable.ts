import type { CKEditorComponent } from './editor';

import { execIfDOMReady } from '../helpers/exec-if-dom-ready';

export class CKEditorEditableComponent extends HTMLElement {
  /**
   * Gets the name of this editable region
   */
  get name() {
    return this.getAttribute('name') || 'editable';
  }

  /**
   * Gets the actual editable DOM element.
   */
  get editableElement() {
    return this.querySelector('div')!;
  }

  /**
   * Root model element.
   */
  get modelElement() {
    return this.getAttribute('inline') === 'true' ? '$inlineRoot' : undefined;
  }

  /**
   * Initial editable data.
   */
  get initialData() {
    return this.hasAttribute('initial-data') ? this.getAttribute('initial-data')! : undefined;
  }

  /**
   * Lifecycle callback when element is added to DOM
   * Sets up the editable element and registers it with the parent editor
   */
  connectedCallback() {
    execIfDOMReady(() => {
      const editorComponent = this.#queryEditorElement();

      if (!editorComponent) {
        throw new Error('ckeditor-editable-component must be a child of ckeditor-component');
      }

      this.innerHTML = `<div>${this.innerHTML}</div>`;
      this.style.display = 'block';

      if (editorComponent.isDecoupled()) {
        editorComponent.runAfterEditorReady((editor) => {
          this.appendChild((editor.ui.view as any)[this.name].element);
        });
      }
      else if (editorComponent.editables) {
        if (!this.name) {
          throw new Error('Editable component missing required "name" attribute');
        }

        editorComponent.editables[this.name] = this;
      }
    });
  }

  /**
   * Lifecycle callback when element is removed
   * Un-registers this editable from the parent editor
   */
  disconnectedCallback() {
    const editorComponent = this.#queryEditorElement();

    if (editorComponent?.editables) {
      delete editorComponent.editables[this.name];
    }
  }

  /**
   * Finds the parent editor component
   */
  #queryEditorElement(): CKEditorComponent | null {
    return this.closest('ckeditor-component') || document.body.querySelector('ckeditor-component');
  }
}

customElements.define('ckeditor-editable-component', CKEditorEditableComponent);
