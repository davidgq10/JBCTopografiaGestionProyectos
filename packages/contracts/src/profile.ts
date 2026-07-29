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
export const MobileNavigationItemSchema = z.enum([
  'agenda',
  'avisos',
  'cuenta',
  'proyectos',
  'tareas',
]);
export const MobileNavigationItemsSchema = z
  .array(MobileNavigationItemSchema)
  .length(3)
  .superRefine((items, context) => {
    if (new Set(items).size !== items.length) {
      context.addIssue({
        code: 'custom',
        message: 'Los accesos de la navegación móvil no pueden repetirse.',
      });
    }
  });

export const AppearanceProfileSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    id: UuidSchema,
    displayName: z.string().trim().min(1).max(200),
    email: z.email(),
    preferredAccent: AccentPreferenceSchema,
    preferredTheme: ThemePreferenceSchema,
    mobileNavItems: MobileNavigationItemsSchema,
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

export const UpdateOwnMobileNavigationCommandSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    mobileNavItems: MobileNavigationItemsSchema,
    expectedVersion: AggregateVersionSchema,
  })
  .strict();

export type AccentPreferenceContract = z.infer<typeof AccentPreferenceSchema>;
export type AppearanceProfileContract = z.infer<typeof AppearanceProfileSchema>;
export type UpdateOwnAppearanceCommand = z.infer<typeof UpdateOwnAppearanceCommandSchema>;
export type MobileNavigationItemContract = z.infer<typeof MobileNavigationItemSchema>;
export type MobileNavigationItemsContract = z.infer<typeof MobileNavigationItemsSchema>;
export type UpdateOwnMobileNavigationCommand = z.infer<
  typeof UpdateOwnMobileNavigationCommandSchema
>;
