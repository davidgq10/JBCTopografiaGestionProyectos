import AxeBuilder from '@axe-core/playwright';
import { expect, test } from '@playwright/test';
import type { Page } from '@playwright/test';

async function openAccount(page: Page) {
  const mobile = (page.viewportSize()?.width ?? 0) < 768;
  const selector = mobile ? 'a.mobileNavItem' : 'a.desktopNavLink';
  await page.locator(selector).filter({ hasText: 'Cuenta' }).click();
}

test('inicia sesión, lee el perfil y guarda el acento', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'JBC Proyectos' })).toBeVisible();
  await page.getByRole('button', { name: 'Entrar con Microsoft' }).click();
  await expect(page.getByRole('heading', { name: /Hola, María Técnica/ })).toBeVisible();

  await openAccount(page);
  await expect(page.getByRole('heading', { name: 'Apariencia' })).toBeVisible();
  await page.getByText('Oscuro', { exact: true }).click();
  await page.getByRole('button', { name: 'Azul' }).click();
  await page.getByRole('button', { name: 'Guardar apariencia' }).click();
  await expect(page.getByText(/quedó guardada/i)).toBeVisible();

  const accessibility = await new AxeBuilder({ page }).analyze();
  expect(
    accessibility.violations.filter((item) => ['critical', 'serious'].includes(item.impact ?? '')),
  ).toEqual([]);
});

test('mantiene el flujo sin desbordamiento en el viewport configurado', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Entrar con Microsoft' }).click();
  await openAccount(page);
  await expect(page.getByRole('heading', { name: 'Apariencia' })).toBeVisible();
  const hasOverflow = await page.evaluate(
    () => document.documentElement.scrollWidth > window.innerWidth,
  );
  expect(hasOverflow).toBe(false);
  await expect(page.getByRole('button', { name: 'Guardar apariencia' })).toBeVisible();
});

test('abre un shell seguro sin datos ni mutaciones al quedar offline', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Entrar con Microsoft' }).click();
  await expect(page.getByRole('heading', { name: /Hola, María Técnica/ })).toBeVisible();

  await page.evaluate(() => {
    Object.defineProperty(navigator, 'onLine', { configurable: true, value: false });
    window.dispatchEvent(new Event('offline'));
  });

  await expect(page.getByRole('heading', { name: 'Sin conexión', exact: true })).toBeVisible();
  await expect(page.getByText(/no se muestran datos guardados/i)).toBeVisible();
  await expect(page.getByRole('button', { name: 'Guardar apariencia' })).toHaveCount(0);
});
