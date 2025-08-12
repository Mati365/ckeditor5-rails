/**
 * Checks if stylesheet with given href already exists in document
 *
 * @param href - Stylesheet URL to check
 * @returns True if stylesheet already exists
 */
function stylesheetExists(href: string) {
  return Array
    .from(document.styleSheets)
    .some(sheet =>
      sheet.href === href || sheet.href === new URL(href, window.location.href).href,
    );
}

/**
 * Dynamically loads CSS files based on configuration
 *
 * @param stylesheets - Array of CSS file URLs to load
 * @returns Array of promises for each CSS file load
 * @throws When CSS file loading fails
 */
export function loadAsyncCSS(stylesheets: string[] = []) {
  const promises = stylesheets.map(href =>
    new Promise<void>((resolve, reject) => {
      if (stylesheetExists(href)) {
        resolve();
        return;
      }

      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = href;

      link.onerror = reject;
      link.onload = () => resolve();

      document.head.appendChild(link);
    }),
  );

  return Promise.all(promises);
}
