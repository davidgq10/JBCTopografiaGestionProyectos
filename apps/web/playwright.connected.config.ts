import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/connected',
  fullyParallel: false,
  retries: 0,
  timeout: 120_000,
  reporter: 'line',
  use: {
    baseURL: 'http://127.0.0.1:4173',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium-connected',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 1000 } },
    },
  ],
});
