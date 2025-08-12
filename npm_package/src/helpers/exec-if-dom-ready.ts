/**
 * Executes callback when DOM is ready.
 *
 * @param callback - Function to execute when DOM is ready.
 */
export function execIfDOMReady(callback: VoidFunction) {
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
