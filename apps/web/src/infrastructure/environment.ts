import { z } from 'zod';

const EnvironmentSchema = z.enum(['local', 'development', 'test', 'production']);

export interface PublicEnvironment {
  appEnvironment: z.infer<typeof EnvironmentSchema>;
  appVersion: string;
  supabaseUrl?: string;
  supabasePublishableKey?: string;
  featureFlags: {
    oneDrive: boolean;
    aptSiri: boolean;
    push: boolean;
    ai: boolean;
  };
}

function readFlag(value: unknown): boolean {
  return value === 'true';
}

export function readPublicEnvironment(): PublicEnvironment {
  const appEnvironment = EnvironmentSchema.catch('local').parse(import.meta.env.VITE_APP_ENV);
  const supabaseUrl = z.url().safeParse(import.meta.env.VITE_SUPABASE_URL);
  const supabasePublishableKey = z
    .string()
    .trim()
    .min(20)
    .safeParse(import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY);

  return {
    appEnvironment,
    appVersion: __APP_VERSION__,
    featureFlags: {
      oneDrive: readFlag(import.meta.env.VITE_FEATURE_ONEDRIVE),
      aptSiri: readFlag(import.meta.env.VITE_FEATURE_APT_SIRI),
      push: readFlag(import.meta.env.VITE_FEATURE_PUSH),
      ai: readFlag(import.meta.env.VITE_FEATURE_AI),
    },
    ...(supabaseUrl.success ? { supabaseUrl: supabaseUrl.data } : {}),
    ...(supabasePublishableKey.success
      ? { supabasePublishableKey: supabasePublishableKey.data }
      : {}),
  };
}
