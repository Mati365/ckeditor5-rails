/**
 * Executes callback when DOM is ready
 *
 * @param {() => void} callback - Function to execute when DOM is ready
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
 * @param {Array<Object>} imports - Array of import configurations
 * @param {Object} imports[].name - Name of inline plugin (for inline type)
 * @param {Object} imports[].code - Source code of inline plugin (for inline type)
 * @param {Object} imports[].import_name - Module path to import (for external type)
 * @param {Object} imports[].import_as - Name to import as (for external type)
 * @param {Object} imports[].window_name - Global window object name (for external type)
 * @param {('inline'|'external')} imports[].type - Type of import
 * @returns {Promise<Array<any>>} Array of loaded modules
 * @throws {Error} When plugin loading fails
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
 * Checks if a key is safe to use in configuration objects to prevent prototype pollution
 *
 * @param {string} key - Key name to check
 * @returns {boolean} True if key is safe to use
 */
function isSafeKey(key) {
  return typeof key === 'string' &&
          key !== '__proto__' &&
          key !== 'constructor' &&
          key !== 'prototype';
}

/**
 * Resolves element references in configuration object.
 * Looks for objects with { $element: "selector" } format and replaces them with actual DOM elements.
 *
 * @param {Object} obj - Configuration object to process
 * @returns {Object} Processed configuration object with resolved element references
 * @throws {Error} When element reference is invalid
 */
function resolveElementReferences(obj) {
  if (!obj || typeof obj !== 'object') {
    return obj;
  }

  if (Array.isArray(obj)) {
    return obj.map(item => resolveElementReferences(item));
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
        result[key] = resolveElementReferences(value);
      }
    } else {
      result[key] = value;
    }
  }

  return result;
}

/**
 * Generates a unique identifier string
 *
 * @returns {string} Random string that can be used as unique identifier
 */
function uid() {
  return Math.random().toString(36).substring(2);
}
