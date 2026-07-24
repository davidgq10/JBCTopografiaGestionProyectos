import type { AppearanceProfile, AppearanceProfilePort } from '@jbc/application';

import type { AppServices, AuthenticatedSession, SessionPort } from '../infrastructure/services.js';

const session: AuthenticatedSession = {
  userId: 'b1000000-0000-4000-8000-000000000003',
  email: 'maria.tecnica@example.test',
  displayName: 'María Técnica',
};

class TestSessionAdapter implements SessionPort {
  private current: AuthenticatedSession | null = null;
  private listeners = new Set<(value: AuthenticatedSession | null) => void>();

  async getCurrentSession(): Promise<AuthenticatedSession | null> {
    return this.current;
  }

  subscribe(listener: (value: AuthenticatedSession | null) => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  async signInWithMicrosoft(): Promise<void> {
    this.current = session;
    this.listeners.forEach((listener) => listener(session));
  }

  async signOut(): Promise<void> {
    this.current = null;
    this.listeners.forEach((listener) => listener(null));
  }
}

class TestProfileAdapter implements AppearanceProfilePort {
  private profile: AppearanceProfile = {
    id: 'a1000000-0000-4000-8000-000000000003',
    displayName: 'María Técnica',
    email: 'maria.tecnica@example.test',
    preferredAccent: 'teal',
    preferredTheme: 'auto',
    version: 1,
    updatedAt: '2026-07-24T00:00:00.000Z',
  };

  async loadOwnProfile(): Promise<AppearanceProfile> {
    return { ...this.profile };
  }

  async updateOwnAppearance(input: {
    preferredAccent: AppearanceProfile['preferredAccent'];
    preferredTheme: AppearanceProfile['preferredTheme'];
    expectedVersion: number;
  }): Promise<AppearanceProfile> {
    if (input.expectedVersion !== this.profile.version) {
      throw new Error('El perfil cambió en otra sesión.');
    }
    this.profile = {
      ...this.profile,
      preferredAccent: input.preferredAccent,
      preferredTheme: input.preferredTheme,
      version: this.profile.version + 1,
      updatedAt: new Date().toISOString(),
    };
    return { ...this.profile };
  }
}

export function createRuntimeServices(): AppServices {
  return {
    configured: true,
    environment: 'test',
    version: '0.1.0-test',
    featureFlags: { oneDrive: false, aptSiri: false, push: false, ai: false },
    session: new TestSessionAdapter(),
    profile: new TestProfileAdapter(),
  };
}
