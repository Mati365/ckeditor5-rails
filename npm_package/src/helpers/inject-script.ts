const SCRIPT_LOAD_PROMISES = new Map();

/**
 * Dynamically loads script files based on configuration.
 * Uses caching to avoid loading the same script multiple times.
 *
 * @param url - URL of the script to load
 */
export function injectScript(url: string) {
  if (SCRIPT_LOAD_PROMISES.has(url)) {
    return SCRIPT_LOAD_PROMISES.get(url);
  }

  const promise = new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = url;
    script.onload = resolve;
    script.onerror = reject;

    document.head.appendChild(script);
  });

  SCRIPT_LOAD_PROMISES.set(url, promise);
  return promise;
}
