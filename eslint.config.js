export default [
  { ignores: ['node_modules/**', 'storage/**'] },
  {
    files: ['src/**/*.js'],
    languageOptions: { ecmaVersion: 'latest', sourceType: 'module', globals: { process: 'readonly', console: 'readonly', Buffer: 'readonly' } },
    rules: {
      'no-undef': 'error',
      'no-unreachable': 'error',
      'no-duplicate-imports': 'error',
    },
  },
];
