import { z } from 'zod';

export const ContractVersionSchema = z.literal(1);
export const UuidSchema = z.uuid();
export const UtcInstantSchema = z.iso
  .datetime({ offset: false, precision: 3 })
  .refine((value) => value.endsWith('Z'), 'La fecha debe estar expresada en UTC con sufijo Z');
export const CorrelationIdSchema = UuidSchema;
export const IdempotencyKeySchema = z.string().trim().min(8).max(128);
export const AggregateVersionSchema = z.number().int().positive();

export const ActorRoleSchema = z.enum(['administrator', 'coordinator', 'technician', 'read_only']);

/**
 * Contexto calculado y firmado por el servidor. La presencia de roles o alcances
 * no concede permisos: el adaptador de autorización debe evaluarlos conforme a
 * la política aprobada en DEC-0103; el JWT nunca declara autoridad de aplicación.
 */
export const ActorContextSchema = z
  .object({
    actorId: UuidSchema,
    roles: z.array(ActorRoleSchema).min(1),
    tenantId: z.string().trim().min(1).max(128),
    authenticatedAtUtc: UtcInstantSchema,
    authorizationPolicyVersion: z.string().trim().min(1).max(64),
  })
  .strict();

export const WorkContextSchema = z
  .object({
    projectId: UuidSchema,
    workId: UuidSchema,
  })
  .strict();

/**
 * Alcance de un recurso sin estados parcialmente definidos. Se usa en puertos
 * transversales (autorización, aprobación, auditoría, idempotencia e IA).
 */
export const ResourceScopeSchema = z.discriminatedUnion('scopeKind', [
  z.object({ scopeKind: z.literal('organization') }).strict(),
  z.object({ scopeKind: z.literal('project'), projectId: UuidSchema }).strict(),
  z
    .object({
      scopeKind: z.literal('work'),
      projectId: UuidSchema,
      workId: UuidSchema,
    })
    .strict(),
]);

export const FieldViolationSchema = z
  .object({
    path: z.string().trim().min(1).max(256),
    message: z.string().trim().min(1).max(500),
  })
  .strict();

export const ErrorCodeSchema = z.enum([
  'VALIDATION_ERROR',
  'UNAUTHENTICATED',
  'FORBIDDEN',
  'NOT_FOUND',
  'CONFLICT',
  'STALE_VERSION',
  'IDEMPOTENCY_CONFLICT',
  'APPROVAL_REQUIRED',
  'EXTERNAL_DEPENDENCY_UNAVAILABLE',
  'INTERNAL_ERROR',
]);

export const ApiErrorSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    code: ErrorCodeSchema,
    message: z.string().trim().min(1).max(500),
    correlationId: CorrelationIdSchema,
    violations: z.array(FieldViolationSchema).max(50).optional(),
    retryable: z.boolean().default(false),
  })
  .strict();

export type ContractVersion = z.infer<typeof ContractVersionSchema>;
export type UtcInstant = z.infer<typeof UtcInstantSchema>;
export type ActorContext = z.infer<typeof ActorContextSchema>;
export type WorkContext = z.infer<typeof WorkContextSchema>;
export type ResourceScope = z.infer<typeof ResourceScopeSchema>;
export type ApiError = z.infer<typeof ApiErrorSchema>;
