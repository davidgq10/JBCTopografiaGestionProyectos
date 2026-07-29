import { spawn } from 'node:child_process';

import { chromium, devices, webkit } from '@playwright/test';

const port = 4175;
const baseUrl = `http://127.0.0.1:${port}`;
const server = spawn(
  process.execPath,
  [
    'node_modules/vite/bin/vite.js',
    '--mode',
    'test',
    '--host',
    '127.0.0.1',
    '--port',
    String(port),
  ],
  { cwd: process.cwd(), stdio: 'ignore', windowsHide: true },
);

const pause = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));

async function waitForServer() {
  const deadline = Date.now() + 60_000;
  while (Date.now() < deadline) {
    if (server.exitCode !== null)
      throw new Error('El servidor de accesibilidad terminó antes de iniciar.');
    try {
      if ((await fetch(baseUrl)).ok) return;
    } catch {
      // El servidor todavía está iniciando.
    }
    await pause(250);
  }
  throw new Error('El servidor de accesibilidad no respondió dentro de 60 segundos.');
}

async function runCase(label, browserType, contextOptions, launchOptions = {}) {
  const browser = await browserType.launch({ headless: true, ...launchOptions });
  try {
    const context = await browser.newContext(contextOptions);
    try {
      const page = await context.newPage();
      await page.goto(`${baseUrl}/`);
      await page.getByRole('button', { name: 'Entrar con Microsoft' }).click();
      await page.getByRole('link', { name: 'Cuenta' }).click();
      await page.getByRole('heading', { name: 'Apariencia' }).waitFor();

      const saveButton = page.getByRole('button', { name: 'Guardar apariencia' });
      await saveButton.focus();
      const focusBefore = await page.evaluate(() => globalThis.document.activeElement?.tagName);
      await page.keyboard.press('Shift+Tab');
      const focusBack = await page.evaluate(() => globalThis.document.activeElement?.tagName);
      await page.keyboard.press('Tab');
      const focusAfter = await page.evaluate(() => globalThis.document.activeElement?.tagName);
      const metrics = await page.evaluate(() => ({
        innerWidth: globalThis.window.innerWidth,
        scrollWidth: globalThis.document.documentElement.scrollWidth,
        clientWidth: globalThis.document.documentElement.clientWidth,
      }));

      if (!focusBefore || !focusBack || !focusAfter) {
        throw new Error(`${label}: el foco no permaneció en controles operables.`);
      }
      if (metrics.scrollWidth > metrics.clientWidth) {
        throw new Error(`${label}: se detectó overflow horizontal.`);
      }

      console.log(
        `${label} PASS | keyboard focus + no overflow | ` +
          `inner=${metrics.innerWidth} scroll=${metrics.scrollWidth} client=${metrics.clientWidth}`,
      );
    } finally {
      await context.close();
    }
  } finally {
    await browser.close();
  }
}

let exitCode = 1;
try {
  await waitForServer();
  await runCase(
    'EDGE-DESKTOP',
    chromium,
    { viewport: { width: 1024, height: 900 } },
    { channel: 'msedge' },
  );
  await runCase('WEBKIT-IPHONE-EMULATED', webkit, { ...devices['iPhone 13'] });
  console.log('A11Y-SUPPLEMENTAL PASS | Edge desktop + WebKit iPhone emulated');
  exitCode = 0;
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
} finally {
  server.kill();
}

process.exitCode = exitCode;
