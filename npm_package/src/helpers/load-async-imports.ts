import { injectScript } from './inject-script';
import { loadAsyncCSS } from './load-async-css';

/**
 * Dynamically imports modules based on configuration
 *
 * @param imports - Array of import configurations
 * @param imports[].name - Name of inline plugin (for inline type)
 * @param imports[].code - Source code of inline plugin (for inline type)
 * @param imports[].import_name - Module path to import (for external type)
 * @param imports[].import_as - Name to import as (for external type)
 * @param imports[].window_name - Global window object name (for external type)
 * @param imports[].type - Type of import
 * @returns Array of loaded modules
 * @throws When plugin loading fails
 */
export function loadAsyncImports(imports: Array<AsyncImportRawDescription | string> = []) {
  const loadExternalPlugin = async ({ url, import_name, import_as, window_name, stylesheets }: AsyncImportRawDescription) => {
    if (stylesheets?.length) {
      await loadAsyncCSS(stylesheets);
    }

    if (window_name) {
      function isScriptPresent() {
        return Object.prototype.hasOwnProperty.call(window, window_name!);
      }

      if (url && !isScriptPresent()) {
        await injectScript(url);
      }

      if (!isScriptPresent()) {
        window.dispatchEvent(
          new CustomEvent(`ckeditor:request-cjs-plugin:${window_name}`),
        );
      }

      if (!isScriptPresent()) {
        throw new Error(
          `Plugin window['${window_name}'] not found in global scope. `
          + 'Please ensure the plugin is loaded before CKEditor initialization.',
        );
      }

      return (window as any)[window_name!];
    }

    const module = await import(import_name!);
    const imported = module[import_as || 'default'];

    if (!imported) {
      throw new Error(
        `Plugin "${import_as || 'default'}" not found in the ESM module `
        + `"${import_name}"! Available imports: ${Object.keys(module).join(', ')}! `
        + 'Consider changing "import_as" value.',
      );
    }

    return imported;
  };

  function uncompressImport(pkg: any) {
    if (typeof pkg === 'string') {
      return loadExternalPlugin({ import_name: 'ckeditor5', import_as: pkg });
    }

    return loadExternalPlugin(pkg);
  }

  return Promise.all(imports.map(uncompressImport));
}

/**
 * Type definition for plugin raw descriptor
 */
export type AsyncImportRawDescription = {
  url?: string;
  import_name?: string;
  import_as?: string;
  window_name?: string;
  stylesheets?: string[];
};
