import path from 'node:path';

import antfu from '@antfu/eslint-config';

export default antfu({
  react: false,
  ignores: [
    'dist',
    'build',
    'lib',
    'infra',
    'sandbox',
    '**/*/dist',
    '**/*/build',
    '*.md',
    'node_modules',
  ],
  languageOptions: {
    parserOptions: {
      project: path.join(import.meta.dirname, 'tsconfig.json'),
    },
  },
  typescript: {
    overrides: {
      'ts/no-unsafe-function-type': 0,
      '@typescript-eslint/consistent-type-definitions': ['error', 'type'],
      '@typescript-eslint/no-floating-promises': 'error',
    },
  },
  stylistic: {
    semi: true,
    overrides: {
      'style/member-delimiter-style': [
        'error',
        {
          multiline: {
            delimiter: 'semi',
            requireLast: true,
          },
          singleline: {
            delimiter: 'semi',
            requireLast: true,
          },
          multilineDetection: 'brackets',
        },
      ],
    },
  },
})
  .override('antfu/imports/rules', {
    rules: {
      'unused-imports/no-unused-imports': 'error',
    },
  })
  .overrideRules({
    'dot-notation': 'off',
    'perfectionist/sort-imports': ['error', {
      groups: [
        'side-effect',
        'type',
        'builtin',
        'external',
        'internal-type',
        'internal',
        ['parent-type', 'sibling-type', 'index-type'],
        ['parent', 'sibling'],
        'index',
      ],
    }],
  });
