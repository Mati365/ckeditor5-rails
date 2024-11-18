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

customElements.define('ckeditor-editable-component', CKEditorEditableComponent);
