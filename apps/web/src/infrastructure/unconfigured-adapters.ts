import type { AppearanceProfile, AppearanceProfilePort } from '@jbc/application';

import { AppGatewayError, type SessionPort } from './services.js';

const message =
  'Configure la URL y la clave publicable de Supabase para usar el entorno local o de desarrollo.';

export class UnconfiguredSessionAdapter implements SessionPort {
  getCurrentSession(): Promise<null> {
    return Promise.resolve(null);
  }

  subscribe(): () => void {
    return () => undefined;
  }

  signInWithMicrosoft(): Promise<void> {
    return Promise.reject(new AppGatewayError('CONFIGURATION_ERROR', message));
  }

  async signOut(): Promise<void> {
    return Promise.resolve();
  }
}

export class UnconfiguredProfileAdapter implements AppearanceProfilePort {
  loadOwnProfile(): Promise<AppearanceProfile> {
    return Promise.reject(new AppGatewayError('CONFIGURATION_ERROR', message));
  }

  updateOwnAppearance(): Promise<AppearanceProfile> {
    return Promise.reject(new AppGatewayError('CONFIGURATION_ERROR', message));
  }
}
