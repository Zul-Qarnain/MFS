import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['dist/**', 'prisma/**', 'tests/**', 'src/index.ts'],
    },
    testTimeout: 10_000,
    setupFiles: ['./tests/setup.ts'],
  },
});
