/**
 * Checks if a key is safe to use in configuration objects to prevent prototype pollution
 *
 * @param key - Key name to check
 * @returns True if key is safe to use
 */
export function isSafeKey(key: string) {
  return (
    typeof key === 'string'
    && key !== '__proto__'
    && key !== 'constructor'
    && key !== 'prototype'
  );
}
