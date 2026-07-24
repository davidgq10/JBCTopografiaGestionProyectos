import { expect, test } from '@playwright/test';

test('recarga el shell compilado sin red y bloquea el inicio de sesión', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'JBC Proyectos', exact: true })).toBeVisible();
  await page.waitForFunction(async () => {
    if (!('serviceWorker' in navigator)) return false;
    await navigator.serviceWorker.ready;
    return navigator.serviceWorker.controller !== null;
  });

  await page.context().setOffline(true);
  await page.reload({ waitUntil: 'domcontentloaded' });

  await expect(page.getByRole('heading', { name: 'JBC Proyectos', exact: true })).toBeVisible();
  await expect(page.getByRole('status', { name: 'Sin conexión' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Entrar con Microsoft' })).toBeDisabled();
});
