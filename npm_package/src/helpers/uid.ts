/**
 * Generates a unique identifier string
 *
 * @returns Random string that can be used as unique identifier
 */
export function uid() {
  return Math.random().toString(36).substring(2);
}
