import type { AppearanceProfile, AppearanceProfilePort } from '@jbc/application';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { render } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';

import { AppProviders } from '../app/app-providers.js';
import type { AppServices, SessionPort } from '../infrastructure/services.js';
import { AppearancePage } from './appearance-page.js';

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
  const updateOwnAppearance = vi.fn(async ({ preferredAccent, preferredTheme }) => ({
    ...initialProfile,
    preferredAccent,
    preferredTheme,
    version: 2,
  }));
  const profile: AppearanceProfilePort = {
    loadOwnProfile: vi.fn(async () => initialProfile),
    updateOwnAppearance,
    updateOwnMobileNavigation: vi.fn(async ({ mobileNavItems }) => ({
      ...initialProfile,
      mobileNavItems,
      version: 2,
    })),
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
  return { services, updateOwnAppearance };
}

describe('AppearancePage', () => {
  it('lee el perfil y guarda un acento válido con la versión esperada', async () => {
    const user = userEvent.setup();
    const { services, updateOwnAppearance } = createServices();
    render(
      <AppProviders services={services}>
        <MemoryRouter>
          <AppearancePage />
        </MemoryRouter>
      </AppProviders>,
    );

    expect(await screen.findByRole('heading', { name: 'Apariencia' })).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Azul' }));
    await user.click(screen.getByText('Oscuro'));
    await user.click(screen.getByRole('button', { name: 'Guardar apariencia' }));

    await waitFor(() =>
      expect(updateOwnAppearance).toHaveBeenCalledWith({
        preferredAccent: 'azul',
        preferredTheme: 'dark',
        expectedVersion: 1,
      }),
    );
    expect(await screen.findByText(/quedó guardada/i)).toBeInTheDocument();
  });

  it('muestra la validación de un personalizado con contraste insuficiente', async () => {
    const user = userEvent.setup();
    const { services } = createServices();
    render(
      <AppProviders services={services}>
        <MemoryRouter>
          <AppearancePage />
        </MemoryRouter>
      </AppProviders>,
    );

    const input = await screen.findByLabelText('Color personalizado');
    await user.clear(input);
    await user.type(input, '#FFFFFF');
    expect(await screen.findByText(/contraste mínimo/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Guardar apariencia' })).toBeDisabled();
  });
});
