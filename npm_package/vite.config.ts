import { resolve } from 'node:path';

import { defineConfig } from 'vite';
import dts from 'vite-plugin-dts';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [
    dts({
      insertTypesEntry: true,
    }),
    tsconfigPaths(),
  ],
  build: {
    sourcemap: true,
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'CKEditor5Rails',
      formats: ['es', 'cjs'],
      fileName: format => `index.${format === 'es' ? 'mjs' : 'cjs'}`,
    },
    rollupOptions: {
      external: isExternalModule,
      output: {
        globals: {
          'ckeditor5': 'CKEditor5',
          'ckeditor5-premium-features': 'CKEditor5PremiumFeatures',
        },
      },
    },
  },
});

function isExternalModule(id: string): boolean {
  return [
    'ckeditor5',
    'ckeditor5-premium-features',
  ].includes(id)
  || /^ckeditor5\/translations\/.+\.js$/.test(id)
  || /^ckeditor5-premium-features\/translations\/.+\.js$/.test(id);
}
