/**
 * Resolves element references in configuration object.
 * Looks for objects with { $element: "selector" } format and replaces them with actual DOM elements.
 *
 * @param obj - Configuration object to process
 * @returns Processed configuration object with resolved element references
 */
export function resolveConfigElementReferences<T>(obj: T): T {
  if (!obj || typeof obj !== 'object') {
    return obj;
  }

  if (Array.isArray(obj)) {
    return obj.map(item => resolveConfigElementReferences(item)) as T;
  }

  const anyObj = obj as any;

  if (anyObj.$element && typeof anyObj.$element === 'string') {
    const element = document.querySelector(anyObj.$element);

    if (!element) {
      console.warn(`Element not found for selector: ${anyObj.$element}`);
    }

    return (element || null) as T;
  }

  const result = Object.create(null);

  for (const [key, value] of Object.entries(obj)) {
    result[key] = resolveConfigElementReferences(value);
  }

  return result as T;
}
