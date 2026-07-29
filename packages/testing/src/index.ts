import type {
  AppearanceProfile,
  AppearanceProfilePort,
  MobileNavigationSelection,
} from '@jbc/application';

export const TEST_APPEARANCE_PROFILE: AppearanceProfile = {
  id: 'a1000000-0000-4000-8000-000000000003',
  displayName: 'María Técnica',
  email: 'maria.tecnica@example.test',
  preferredAccent: 'teal',
  preferredTheme: 'auto',
  mobileNavItems: ['agenda', 'avisos', 'cuenta'],
  version: 1,
  updatedAt: '2026-07-24T00:00:00.000Z',
};

export class InMemoryAppearanceProfileAdapter implements AppearanceProfilePort {
  #profile = { ...TEST_APPEARANCE_PROFILE };

  async loadOwnProfile(): Promise<AppearanceProfile> {
    return { ...this.#profile };
  }

  async updateOwnAppearance(input: {
    preferredAccent: AppearanceProfile['preferredAccent'];
    preferredTheme: AppearanceProfile['preferredTheme'];
    expectedVersion: number;
  }): Promise<AppearanceProfile> {
    if (input.expectedVersion !== this.#profile.version) {
      throw Object.assign(new Error('El perfil cambió en otra sesión.'), { code: 'STALE_VERSION' });
    }
    this.#profile = {
      ...this.#profile,
      preferredAccent: input.preferredAccent,
      preferredTheme: input.preferredTheme,
      version: this.#profile.version + 1,
      updatedAt: new Date().toISOString(),
    };
    return { ...this.#profile };
  }

  async updateOwnMobileNavigation(input: {
    mobileNavItems: MobileNavigationSelection;
    expectedVersion: number;
  }): Promise<AppearanceProfile> {
    if (input.expectedVersion !== this.#profile.version) {
      throw Object.assign(new Error('El perfil cambió en otra sesión.'), {
        code: 'STALE_VERSION',
      });
    }
    this.#profile = {
      ...this.#profile,
      mobileNavItems: input.mobileNavItems,
      version: this.#profile.version + 1,
      updatedAt: new Date().toISOString(),
    };
    return { ...this.#profile };
  }
}
