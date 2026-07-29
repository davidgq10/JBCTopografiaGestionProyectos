import type { AppearanceProfile, AppearanceProfilePort } from '@jbc/application';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';

import { AppProviders } from '../app/app-providers.js';
import type { AppServices, SessionPort } from '../infrastructure/services.js';
import { SettingsPage } from './settings-page.js';

const initialProfile: AppearanceProfile = {
  id: 'a1000000-0000-4000-8000-000000000003',
  displayName: 'María Técnica',
  email: 'maria@example.test',
  preferredAccent: 'teal',
  preferredTheme: 'auto',
  mobileNavItems: ['agenda', 'avisos', 'cuenta'],
  version: 1,
  updatedAt: '2026-07-24T00:00:00.000Z',
};

function createServices() {
  const updateOwnMobileNavigation = vi.fn(async ({ mobileNavItems }) => ({
    ...initialProfile,
    mobileNavItems,
    version: 2,
  }));
  const profile: AppearanceProfilePort = {
    loadOwnProfile: vi.fn(async () => initialProfile),
    updateOwnAppearance: vi.fn(async () => initialProfile),
    updateOwnMobileNavigation,
  };
  const session: SessionPort = {
    getCurrentSession: vi.fn(async () => ({
      userId: 'b1000000-0000-4000-8000-000000000003',
      displayName: 'María Técnica',
      email: 'maria@example.test',
    })),
    subscribe: vi.fn(() => () => undefined),
    signInWithMicrosoft: vi.fn(async () => undefined),
    signOut: vi.fn(async () => undefined),
  };
  const services: AppServices = {
    configured: true,
    environment: 'test',
    version: '0.1.0-test',
    featureFlags: { oneDrive: false, aptSiri: false, push: false, ai: false },
    session,
    profile,
  };
  return { services, updateOwnMobileNavigation };
}

describe('SettingsPage', () => {
  it('permite ordenar tres accesos sin mover Inicio ni Más', async () => {
    const user = userEvent.setup();
    const { services, updateOwnMobileNavigation } = createServices();
    HTMLElement.prototype.scrollIntoView = vi.fn();
    render(
      <AppProviders services={services}>
        <MemoryRouter>
          <SettingsPage />
        </MemoryRouter>
      </AppProviders>,
    );

    expect(await screen.findByRole('heading', { name: 'Panel móvil' })).toBeInTheDocument();
    expect(screen.getByText('Inicio')).toBeInTheDocument();
    expect(screen.getByText('Más')).toBeInTheDocument();

    const firstSlot = screen.getByRole('textbox', { name: 'Acceso 1' });
    await user.click(firstSlot);
    await user.keyboard('{ArrowDown}{Enter}');
    await user.click(screen.getByRole('button', { name: 'Guardar panel móvil' }));

    await waitFor(() =>
      expect(updateOwnMobileNavigation).toHaveBeenCalledWith({
        mobileNavItems: ['proyectos', 'avisos', 'cuenta'],
        expectedVersion: 1,
      }),
    );
  });
});
