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

customElements.define('ckeditor-ui-part-component', CKEditorUIPartComponent);
