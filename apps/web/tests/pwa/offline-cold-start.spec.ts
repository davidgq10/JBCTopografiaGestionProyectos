import { expect, test } from '@playwright/test';

test('recarga el shell compilado sin red y bloquea el inicio de sesión', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'JBC Proyectos', exact: true })).toBeVisible();
  await page.evaluate(async () => {
    if (!('serviceWorker' in navigator)) throw new Error('El navegador no expone Service Worker.');
    await navigator.serviceWorker.register('/sw.js');
  });
  // El primer registro instala el worker pero no controla esa misma carga; una
  // recarga online hace determinista el control antes de simular la pérdida de red.
  await page.reload({ waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => navigator.serviceWorker.controller !== null);

  await page.context().setOffline(true);
  await page.reload({ waitUntil: 'domcontentloaded' });

  await expect(page.getByRole('heading', { name: 'JBC Proyectos', exact: true })).toBeVisible();
  await expect(page.getByRole('status', { name: 'Sin conexión' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Entrar con Microsoft' })).toBeDisabled();
});
