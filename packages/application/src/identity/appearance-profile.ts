import { buildAccentPalette, type AccentPreference } from '@jbc/domain';

import {
  parseMobileNavigationSelection,
  type MobileNavigationItem,
  type MobileNavigationSelection,
} from './mobile-navigation.js';

export type ThemePreference = 'auto' | 'light' | 'dark';

export interface AppearanceProfile {
  id: string;
  displayName: string;
  email: string;
  preferredAccent: AccentPreference;
  preferredTheme: ThemePreference;
  mobileNavItems: MobileNavigationSelection;
  version: number;
  updatedAt: string;
}

export interface AppearanceProfilePort {
  loadOwnProfile(): Promise<AppearanceProfile>;
  updateOwnAppearance(input: {
    preferredAccent: AccentPreference;
    preferredTheme: ThemePreference;
    expectedVersion: number;
  }): Promise<AppearanceProfile>;
  updateOwnMobileNavigation(input: {
    mobileNavItems: MobileNavigationSelection;
    expectedVersion: number;
  }): Promise<AppearanceProfile>;
}

export class InvalidProfileVersionError extends Error {
  readonly code = 'INVALID_PROFILE_VERSION';

  constructor() {
    super('La versión del perfil debe ser un entero positivo.');
    this.name = 'InvalidProfileVersionError';
  }
}

export async function loadOwnAppearanceProfile(
  profilePort: AppearanceProfilePort,
): Promise<AppearanceProfile> {
  const profile = await profilePort.loadOwnProfile();
  return validateAppearanceProfile(profile);
}

function validateAppearanceProfile(profile: AppearanceProfile): AppearanceProfile {
  buildAccentPalette(profile.preferredAccent);
  parseMobileNavigationSelection(profile.mobileNavItems);
  return profile;
}

export async function updateOwnAppearance(
  profilePort: AppearanceProfilePort,
  input: { preferredAccent: string; preferredTheme: string; expectedVersion: number },
): Promise<AppearanceProfile> {
  if (!Number.isInteger(input.expectedVersion) || input.expectedVersion < 1) {
    throw new InvalidProfileVersionError();
  }

  const palette = buildAccentPalette(input.preferredAccent);
  if (!['auto', 'light', 'dark'].includes(input.preferredTheme)) {
    throw new Error('El tema debe ser Sistema, Claro u Oscuro.');
  }
  const profile = await profilePort.updateOwnAppearance({
    preferredAccent: palette.preference,
    preferredTheme: input.preferredTheme as ThemePreference,
    expectedVersion: input.expectedVersion,
  });
  return validateAppearanceProfile(profile);
}

export async function updateOwnMobileNavigation(
  profilePort: AppearanceProfilePort,
  input: { mobileNavItems: readonly string[]; expectedVersion: number },
): Promise<AppearanceProfile> {
  if (!Number.isInteger(input.expectedVersion) || input.expectedVersion < 1) {
    throw new InvalidProfileVersionError();
  }

  const profile = await profilePort.updateOwnMobileNavigation({
    mobileNavItems: parseMobileNavigationSelection(input.mobileNavItems),
    expectedVersion: input.expectedVersion,
  });
  return validateAppearanceProfile(profile);
}

export type { MobileNavigationItem, MobileNavigationSelection };
