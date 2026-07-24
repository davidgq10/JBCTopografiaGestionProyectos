import type { AppearanceProfile, AppearanceProfilePort } from '@jbc/application';
import { normalizeAccentPreference } from '@jbc/domain';
import type { PostgrestError, SupabaseClient } from '@supabase/supabase-js';

import { AppGatewayError } from '../services.js';

interface AppUserRow {
  id: string;
  display_name: string;
  email: string;
  preferred_accent: string | null;
  preferred_theme: 'auto' | 'light' | 'dark';
  version: number;
  updated_at: string;
}

function mapProfile(row: AppUserRow): AppearanceProfile {
  return {
    id: row.id,
    displayName: row.display_name,
    email: row.email,
    preferredAccent: normalizeAccentPreference(row.preferred_accent),
    preferredTheme: row.preferred_theme,
    version: row.version,
    updatedAt: new Date(row.updated_at).toISOString(),
  };
}

function mapDatabaseError(error: PostgrestError): AppGatewayError {
  if (error.code === '23514' || error.code === '22P02') {
    return new AppGatewayError(
      'VALIDATION_ERROR',
      'El servidor rechazó el acento porque no cumple las reglas de accesibilidad.',
    );
  }
  if (error.code === '42501') {
    return new AppGatewayError('FORBIDDEN', 'No tiene permiso para modificar este perfil.');
  }
  return new AppGatewayError('INTERNAL_ERROR', 'No fue posible completar la operación.');
}

export class SupabaseAppearanceProfileAdapter implements AppearanceProfilePort {
  constructor(private readonly client: SupabaseClient) {}

  private async authSubject(): Promise<string> {
    const { data, error } = await this.client.auth.getUser();
    if (error || !data.user) {
      throw new AppGatewayError('UNAUTHENTICATED', 'La sesión ya no es válida.');
    }
    return data.user.id;
  }

  async loadOwnProfile(): Promise<AppearanceProfile> {
    const authSubject = await this.authSubject();
    const { data, error } = await this.client
      .from('app_users')
      .select('id,display_name,email,preferred_accent,preferred_theme,version,updated_at')
      .eq('auth_subject', authSubject)
      .maybeSingle<AppUserRow>();

    if (error) throw mapDatabaseError(error);
    if (!data) {
      throw new AppGatewayError(
        'FORBIDDEN',
        'Su cuenta de Microsoft no está autorizada o fue revocada en JBC Proyectos.',
      );
    }
    return mapProfile(data);
  }

  async updateOwnAppearance(input: {
    preferredAccent: AppearanceProfile['preferredAccent'];
    preferredTheme: AppearanceProfile['preferredTheme'];
    expectedVersion: number;
  }): Promise<AppearanceProfile> {
    const authSubject = await this.authSubject();
    const { data, error } = await this.client
      .from('app_users')
      .update({
        preferred_accent: input.preferredAccent,
        preferred_theme: input.preferredTheme,
      })
      .eq('auth_subject', authSubject)
      .eq('version', input.expectedVersion)
      .select('id,display_name,email,preferred_accent,preferred_theme,version,updated_at')
      .maybeSingle<AppUserRow>();

    if (error) throw mapDatabaseError(error);
    if (!data) {
      throw new AppGatewayError(
        'STALE_VERSION',
        'El perfil cambió en otra sesión. Recargue los datos antes de guardar.',
      );
    }
    return mapProfile(data);
  }
}
