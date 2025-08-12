import type { CKEditorComponent } from './editor';

import { execIfDOMReady } from '../helpers';

class CKEditorUIPartComponent extends HTMLElement {
  /**
   * Lifecycle callback when element is added to DOM.
   * Adds the toolbar to the editor UI.
   */
  connectedCallback() {
    execIfDOMReady(async () => {
      const uiPart = this.getAttribute('name')!;
      const editor = await this.#queryEditorElement()!.instancePromise.promise;

      this.appendChild((editor.ui.view as any)[uiPart].element);
    });
  }

  /**
   * Finds the parent editor component.
   */
  #queryEditorElement(): CKEditorComponent | null {
    return this.closest('ckeditor-component') || document.body.querySelector('ckeditor-component');
  }
}

customElements.define('ckeditor-ui-part-component', CKEditorUIPartComponent);
