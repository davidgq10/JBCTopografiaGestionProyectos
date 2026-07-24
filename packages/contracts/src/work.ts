import { z } from 'zod';
import {
  AggregateVersionSchema,
  ContractVersionSchema,
  CorrelationIdSchema,
  IdempotencyKeySchema,
  UtcInstantSchema,
  UuidSchema,
  WorkContextSchema,
} from './common.js';

export const WorkTypeSchema = z.enum([
  'delimitacion',
  'curvas_nivel',
  'avaluo',
  'croquis',
  'plano_catastro',
]);

/** Código opaco definido por la versión de configuración del tipo de Trabajo. */
export const InternalWorkStatusSchema = z
  .string()
  .trim()
  .regex(/^[a-z][a-z0-9_]{0,79}$/);

export const ExternalProcedureSourceSchema = z.enum(['apt', 'siri']);
export const NormalizedExternalStatusSchema = z.enum([
  'unqueried',
  'not_found',
  'in_progress',
  'attention_required',
  'resolved_favorable',
  'resolved_unfavorable',
  'completed',
  'query_error',
  'unclassified',
]);

export const WorkSummarySchema = z
  .object({
    contractVersion: ContractVersionSchema,
    projectId: UuidSchema,
    workId: UuidSchema,
    clientId: UuidSchema,
    projectCode: z.string().trim().min(1).max(64),
    name: z.string().trim().min(1).max(240),
    type: WorkTypeSchema,
    internalStatus: InternalWorkStatusSchema,
    version: AggregateVersionSchema,
    createdAtUtc: UtcInstantSchema,
    updatedAtUtc: UtcInstantSchema,
    archivedAtUtc: UtcInstantSchema.nullable(),
    archiveReason: z.string().trim().min(1).max(1000).nullable(),
  })
  .strict()
  .superRefine((value, context) => {
    if ((value.archivedAtUtc === null) !== (value.archiveReason === null)) {
      context.addIssue({
        code: 'custom',
        path: ['archiveReason'],
        message: 'La fecha y el motivo de archivo deben existir juntos',
      });
    }
  });

export const ChangeWorkTypeCommandSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    projectId: UuidSchema,
    workId: UuidSchema,
    idempotencyKey: IdempotencyKeySchema,
    correlationId: CorrelationIdSchema,
    expectedVersion: AggregateVersionSchema,
    newType: WorkTypeSchema,
    reason: z.string().trim().min(1).max(1000),
    comparisonSummary: z.string().trim().min(1).max(4000),
  })
  .strict();

export const ChangeWorkTypeAcceptedSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    projectId: UuidSchema,
    workId: UuidSchema,
    approvalRequestId: UuidSchema,
    status: z.literal('pending_approval'),
    correlationId: CorrelationIdSchema,
  })
  .strict();

/** Fotografía interna inmutable registrada al solicitar aprobación. */
export const WorkTypeChangeTargetSnapshotSchema = z
  .object({
    workTypeId: UuidSchema,
    configurationVersionId: UuidSchema,
    internalStateId: UuidSchema,
  })
  .strict();

/** Mutación exacta que el backend resuelve y somete a aprobación. */
export const WorkTypeChangeApprovalPayloadSchema = z
  .object({
    newType: WorkTypeSchema,
    newConfigurationVersionId: UuidSchema,
    newInternalStateId: UuidSchema,
  })
  .strict();

export const WorkTypeChangeComparisonSchema = z
  .object({
    previous: WorkTypeChangeTargetSnapshotSchema,
    requested: WorkTypeChangeApprovalPayloadSchema,
    summary: z.string().trim().min(1).max(4000),
  })
  .strict();

export const ExternalProcedureSnapshotSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    projectId: UuidSchema,
    workId: UuidSchema,
    procedureId: UuidSchema,
    source: ExternalProcedureSourceSchema,
    originalText: z.string().max(100_000),
    normalizedStatus: NormalizedExternalStatusSchema,
    observedAtUtc: UtcInstantSchema,
    lastSuccessfulQueryAtUtc: UtcInstantSchema.nullable(),
    active: z.boolean(),
  })
  .strict()
  .superRefine((value, context) => {
    if (value.active && value.source && value.normalizedStatus && !value.workId) {
      context.addIssue({ code: 'custom', message: 'El trámite activo requiere Trabajo' });
    }
  });

export const DocumentReferenceSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    projectId: UuidSchema,
    workId: UuidSchema,
    documentId: UuidSchema,
    driveId: z.string().trim().min(1).max(512),
    driveItemId: z.string().trim().min(1).max(512),
    name: z.string().trim().min(1).max(500),
    mediaType: z.string().trim().min(1).max(255).nullable(),
    sizeBytes: z.number().int().nonnegative().nullable(),
    versionTag: z.string().trim().min(1).max(512),
    archivedAtUtc: UtcInstantSchema.nullable(),
    previousPath: z.string().trim().min(1).max(4000).nullable(),
  })
  .strict();

export const WorkContextResponseSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    context: WorkContextSchema,
    work: WorkSummarySchema,
    externalProcedures: z.array(ExternalProcedureSnapshotSchema),
    documents: z.array(DocumentReferenceSchema),
    correlationId: CorrelationIdSchema,
  })
  .strict();

export type WorkType = z.infer<typeof WorkTypeSchema>;
export type WorkSummary = z.infer<typeof WorkSummarySchema>;
export type ChangeWorkTypeCommand = z.infer<typeof ChangeWorkTypeCommandSchema>;
export type WorkTypeChangeTargetSnapshot = z.infer<typeof WorkTypeChangeTargetSnapshotSchema>;
export type WorkTypeChangeApprovalPayload = z.infer<typeof WorkTypeChangeApprovalPayloadSchema>;
export type WorkTypeChangeComparison = z.infer<typeof WorkTypeChangeComparisonSchema>;
export type ExternalProcedureSnapshot = z.infer<typeof ExternalProcedureSnapshotSchema>;
export type DocumentReference = z.infer<typeof DocumentReferenceSchema>;
