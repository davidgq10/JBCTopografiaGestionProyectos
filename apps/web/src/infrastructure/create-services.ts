import { createClient } from '@supabase/supabase-js';

import { readPublicEnvironment } from './environment.js';
import type { AppServices } from './services.js';
import { SupabaseAppearanceProfileAdapter } from './supabase/profile-adapter.js';
import { SupabaseSessionAdapter } from './supabase/session-adapter.js';
import { UnconfiguredProfileAdapter, UnconfiguredSessionAdapter } from './unconfigured-adapters.js';

export function createRuntimeServices(): AppServices {
  const environment = readPublicEnvironment();
  if (!environment.supabaseUrl || !environment.supabasePublishableKey) {
    return {
      configured: false,
      configurationMessage:
        'Supabase no está configurado. Copie .env.example a .env.local y use únicamente la clave publicable.',
      environment: environment.appEnvironment,
      version: environment.appVersion,
      featureFlags: environment.featureFlags,
      session: new UnconfiguredSessionAdapter(),
      profile: new UnconfiguredProfileAdapter(),
    };
  }

  const client = createClient(environment.supabaseUrl, environment.supabasePublishableKey, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
    },
  });

  return {
    configured: true,
    environment: environment.appEnvironment,
    version: environment.appVersion,
    featureFlags: environment.featureFlags,
    session: new SupabaseSessionAdapter(client),
    profile: new SupabaseAppearanceProfileAdapter(client),
  };
}
