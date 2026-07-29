import type {
  AppearanceProfile,
  AppearanceProfilePort,
  MobileNavigationSelection,
} from '@jbc/application';
import { parseMobileNavigationSelection } from '@jbc/application';
import {
  AppearanceProfileSchema,
  UpdateOwnAppearanceCommandSchema,
  UpdateOwnMobileNavigationCommandSchema,
} from '@jbc/contracts';
import { normalizeAccentPreference } from '@jbc/domain';

import {
  AppGatewayError,
  type AppServices,
  type AuthenticatedSession,
  type SessionPort,
} from '../infrastructure/services.js';

const AUTH_SUBJECT = 'b1000000-0000-4000-8000-000000000003';

const connectedSession: AuthenticatedSession = {
  userId: AUTH_SUBJECT,
  email: 'maria.tecnica@example.test',
  displayName: 'María Técnica',
};

interface AppUserRow {
  id: string;
  display_name: string;
  email: string;
  preferred_accent: string | null;
  preferred_theme: 'auto' | 'light' | 'dark';
  mobile_nav_items: MobileNavigationSelection;
  version: number;
  updated_at: string;
}

class ConnectedSessionAdapter implements SessionPort {
  private current: AuthenticatedSession | null = null;
  private readonly listeners = new Set<(value: AuthenticatedSession | null) => void>();

  async getCurrentSession(): Promise<AuthenticatedSession | null> {
    return this.current;
  }

  subscribe(listener: (value: AuthenticatedSession | null) => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  async signInWithMicrosoft(): Promise<void> {
    this.current = connectedSession;
    this.listeners.forEach((listener) => listener(connectedSession));
  }

  async signOut(): Promise<void> {
    this.current = null;
    this.listeners.forEach((listener) => listener(null));
  }
}

function mapProfile(row: AppUserRow): AppearanceProfile {
  const profile = AppearanceProfileSchema.parse({
    contractVersion: 1,
    id: row.id,
    displayName: row.display_name,
    email: row.email,
    preferredAccent: normalizeAccentPreference(row.preferred_accent),
    preferredTheme: row.preferred_theme,
    mobileNavItems: row.mobile_nav_items,
    version: row.version,
    updatedAt: new Date(row.updated_at).toISOString(),
  });
  return {
    id: profile.id,
    displayName: profile.displayName,
    email: profile.email,
    preferredAccent: normalizeAccentPreference(profile.preferredAccent),
    preferredTheme: profile.preferredTheme,
    mobileNavItems: parseMobileNavigationSelection(profile.mobileNavItems),
    version: profile.version,
    updatedAt: profile.updatedAt,
  };
}

async function readRows(response: Response): Promise<AppUserRow[]> {
  if (!response.ok) {
    const payload = (await response.json().catch(() => ({}))) as { code?: string };
    if (payload.code === '42501') {
      throw new AppGatewayError('FORBIDDEN', 'No tiene permiso para modificar este perfil.');
    }
    if (payload.code === '23514' || payload.code === '22P02') {
      throw new AppGatewayError(
        'VALIDATION_ERROR',
        'El servidor rechazó la preferencia porque no cumple las reglas vigentes.',
      );
    }
    throw new AppGatewayError('INTERNAL_ERROR', 'No fue posible completar la operación.');
  }
  return (await response.json()) as AppUserRow[];
}

class ConnectedPostgrestProfileAdapter implements AppearanceProfilePort {
  async loadOwnProfile(): Promise<AppearanceProfile> {
    const query = new URLSearchParams({
      select:
        'id,display_name,email,preferred_accent,preferred_theme,mobile_nav_items,version,updated_at',
      auth_subject: `eq.${AUTH_SUBJECT}`,
    });
    const rows = await readRows(await fetch(`/rest/v1/app_users?${query.toString()}`));
    const profile = rows[0];
    if (!profile || rows.length !== 1) {
      throw new AppGatewayError(
        'FORBIDDEN',
        'Su cuenta de Microsoft no está autorizada o fue revocada en JBC Proyectos.',
      );
    }
    return mapProfile(profile);
  }

  async updateOwnAppearance(input: {
    preferredAccent: AppearanceProfile['preferredAccent'];
    preferredTheme: AppearanceProfile['preferredTheme'];
    expectedVersion: number;
  }): Promise<AppearanceProfile> {
    const command = UpdateOwnAppearanceCommandSchema.parse({
      contractVersion: 1,
      preferredAccent: input.preferredAccent,
      preferredTheme: input.preferredTheme,
      expectedVersion: input.expectedVersion,
    });
    const query = new URLSearchParams({
      select:
        'id,display_name,email,preferred_accent,preferred_theme,mobile_nav_items,version,updated_at',
      auth_subject: `eq.${AUTH_SUBJECT}`,
      version: `eq.${String(command.expectedVersion)}`,
    });
    const response = await fetch(`/rest/v1/app_users?${query.toString()}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', Prefer: 'return=representation' },
      body: JSON.stringify({
        preferred_accent: command.preferredAccent,
        preferred_theme: command.preferredTheme,
      }),
    });
    const rows = await readRows(response);
    const profile = rows[0];
    if (!profile || rows.length !== 1) {
      throw new AppGatewayError(
        'STALE_VERSION',
        'El perfil cambió en otra sesión. Recargue los datos antes de guardar.',
      );
    }
    return mapProfile(profile);
  }

  async updateOwnMobileNavigation(input: {
    mobileNavItems: MobileNavigationSelection;
    expectedVersion: number;
  }): Promise<AppearanceProfile> {
    const command = UpdateOwnMobileNavigationCommandSchema.parse({
      contractVersion: 1,
      mobileNavItems: input.mobileNavItems,
      expectedVersion: input.expectedVersion,
    });
    const query = new URLSearchParams({
      select:
        'id,display_name,email,preferred_accent,preferred_theme,mobile_nav_items,version,updated_at',
      auth_subject: `eq.${AUTH_SUBJECT}`,
      version: `eq.${String(command.expectedVersion)}`,
    });
    const response = await fetch(`/rest/v1/app_users?${query.toString()}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', Prefer: 'return=representation' },
      body: JSON.stringify({ mobile_nav_items: command.mobileNavItems }),
    });
    const rows = await readRows(response);
    const profile = rows[0];
    if (!profile || rows.length !== 1) {
      throw new AppGatewayError(
        'STALE_VERSION',
        'El perfil cambió en otra sesión. Recargue los datos antes de guardar.',
      );
    }
    return mapProfile(profile);
  }
}

export function createRuntimeServices(): AppServices {
  return {
    configured: true,
    environment: 'test',
    version: '0.1.0-connected-test',
    featureFlags: { oneDrive: false, aptSiri: false, push: false, ai: false },
    session: new ConnectedSessionAdapter(),
    profile: new ConnectedPostgrestProfileAdapter(),
  };
}
