import { defineConfig, devices } from '@playwright/test';

const managedWebServer = {
  command: 'node node_modules/vite/bin/vite.js --mode test --host 127.0.0.1',
  url: 'http://127.0.0.1:4173',
  reuseExistingServer: false,
  timeout: 120_000,
};

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: false,
  retries: 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: 'http://127.0.0.1:4173',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium-1440',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 1000 } },
    },
    {
      name: 'chromium-1024',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1024, height: 900 } },
    },
    {
      name: 'chromium-768',
      use: { ...devices['Desktop Chrome'], viewport: { width: 768, height: 900 } },
    },
    { name: 'chromium-360', use: { ...devices['Pixel 5'], viewport: { width: 360, height: 800 } } },
  ],
  ...(process.env.PW_EXTERNAL_SERVER === '1' ? {} : { webServer: managedWebServer }),
});
