import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    setupFiles: ['./tests/setupEnv.ts'],
    testTimeout: 20000,
    hookTimeout: 30000,
  },
});
