import { describe, expect, it, vi } from 'vitest';

import type { AppearanceProfile, AppearanceProfilePort } from './appearance-profile.js';
import {
  InvalidProfileVersionError,
  loadOwnAppearanceProfile,
  updateOwnAppearance,
} from './appearance-profile.js';

const profile: AppearanceProfile = {
  id: 'a1000000-0000-4000-8000-000000000003',
  displayName: 'Técnica de prueba',
  email: 'tecnica@example.test',
  preferredAccent: 'teal',
  preferredTheme: 'auto',
  version: 1,
  updatedAt: '2026-07-24T00:00:00.000Z',
};

function createPort(): AppearanceProfilePort {
  return {
    loadOwnProfile: vi.fn().mockResolvedValue(profile),
    updateOwnAppearance: vi
      .fn()
      .mockImplementation(async ({ preferredAccent, preferredTheme }) => ({
        ...profile,
        preferredAccent,
        preferredTheme,
        version: 2,
      })),
  };
}

describe('casos de uso de apariencia', () => {
  it('lee y valida el perfil autorizado', async () => {
    await expect(loadOwnAppearanceProfile(createPort())).resolves.toEqual(profile);
  });

  it('normaliza antes de escribir mediante el puerto', async () => {
    const port = createPort();
    const updated = await updateOwnAppearance(port, {
      preferredAccent: '#0f766e',
      preferredTheme: 'dark',
      expectedVersion: 1,
    });
    expect(updated.preferredAccent).toBe('#0F766E');
    expect(updated.preferredTheme).toBe('dark');
    expect(port.updateOwnAppearance).toHaveBeenCalledWith({
      preferredAccent: '#0F766E',
      preferredTheme: 'dark',
      expectedVersion: 1,
    });
  });

  it('rechaza una versión inválida sin tocar el adaptador', async () => {
    const port = createPort();
    await expect(
      updateOwnAppearance(port, {
        preferredAccent: 'azul',
        preferredTheme: 'auto',
        expectedVersion: 0,
      }),
    ).rejects.toBeInstanceOf(InvalidProfileVersionError);
    expect(port.updateOwnAppearance).not.toHaveBeenCalled();
  });

  it('rechaza un acento inválido sin tocar el adaptador', async () => {
    const port = createPort();
    await expect(
      updateOwnAppearance(port, {
        preferredAccent: '#FFFFFF',
        preferredTheme: 'auto',
        expectedVersion: 1,
      }),
    ).rejects.toThrow('contraste mínimo');
    expect(port.updateOwnAppearance).not.toHaveBeenCalled();
  });

  it('rechaza un tema fuera del contrato sin tocar el adaptador', async () => {
    const port = createPort();
    await expect(
      updateOwnAppearance(port, {
        preferredAccent: 'teal',
        preferredTheme: 'sepia',
        expectedVersion: 1,
      }),
    ).rejects.toThrow('Sistema, Claro u Oscuro');
    expect(port.updateOwnAppearance).not.toHaveBeenCalled();
  });
});
