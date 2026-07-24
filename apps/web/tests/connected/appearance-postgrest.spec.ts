import { expect, test } from '@playwright/test';

test('recorre UI, PostgREST, RLS y escritura auditada', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Entrar con Microsoft' }).click();
  await expect(page.getByRole('heading', { name: /Hola, María Técnica/ })).toBeVisible();

  const visibleIds = await page.evaluate(async () => {
    const response = await fetch('/rest/v1/app_users?select=id');
    if (!response.ok) throw new Error(`PostgREST respondió ${String(response.status)}`);
    return (await response.json()) as { id: string }[];
  });
  expect(visibleIds).toEqual([{ id: 'a1000000-0000-4000-8000-000000000003' }]);

  await page.locator('a.desktopNavLink').filter({ hasText: 'Cuenta' }).click();
  await expect(page.getByRole('heading', { name: 'Apariencia' })).toBeVisible();
  await page.getByText('Oscuro', { exact: true }).click();
  await page.getByRole('button', { name: 'Azul' }).click();
  await page.getByRole('button', { name: 'Guardar apariencia' }).click();
  await expect(page.getByText(/quedó guardada/i)).toBeVisible();
});
