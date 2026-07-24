import { z } from 'zod';

import {
  AggregateVersionSchema,
  ContractVersionSchema,
  UtcInstantSchema,
  UuidSchema,
} from './common.js';

export const AccentPresetSchema = z.enum(['teal', 'azul', 'indigo', 'violeta', 'rosa', 'naranja']);
export const CustomAccentSchema = z.string().regex(/^#[0-9A-F]{6}$/);
export const AccentPreferenceSchema = z.union([AccentPresetSchema, CustomAccentSchema]);
export const ThemePreferenceSchema = z.enum(['auto', 'light', 'dark']);

export const AppearanceProfileSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    id: UuidSchema,
    displayName: z.string().trim().min(1).max(200),
    email: z.email(),
    preferredAccent: AccentPreferenceSchema,
    preferredTheme: ThemePreferenceSchema,
    version: AggregateVersionSchema,
    updatedAt: UtcInstantSchema,
  })
  .strict();

export const UpdateOwnAppearanceCommandSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    preferredAccent: AccentPreferenceSchema,
    preferredTheme: ThemePreferenceSchema,
    expectedVersion: AggregateVersionSchema,
  })
  .strict();

export type AccentPreferenceContract = z.infer<typeof AccentPreferenceSchema>;
export type AppearanceProfileContract = z.infer<typeof AppearanceProfileSchema>;
export type UpdateOwnAppearanceCommand = z.infer<typeof UpdateOwnAppearanceCommandSchema>;
