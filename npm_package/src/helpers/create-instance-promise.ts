/**
 * Creates a deferred promise that does not report an unhandled rejection
 * when it's rejected while nobody is waiting for it.
 */
export function createInstancePromise<T>(): PromiseWithResolvers<T> {
  const deferred = Promise.withResolvers<T>();

  deferred.promise.catch(() => {});

  return deferred;
}
