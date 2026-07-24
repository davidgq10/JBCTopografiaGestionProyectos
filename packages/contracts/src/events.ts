import { z } from 'zod';
import {
  AggregateVersionSchema,
  ContractVersionSchema,
  CorrelationIdSchema,
  ResourceScopeSchema,
  UtcInstantSchema,
  UuidSchema,
} from './common.js';
import {
  ExternalProcedureSourceSchema,
  NormalizedExternalStatusSchema,
  WorkTypeSchema,
} from './work.js';

export const EventNameSchema = z.enum([
  'apt.status_changed.v1',
  'siri.procedure_changed.v1',
  'onedrive.item_changed.v1',
  'task.overdue.v1',
  'approval.requested.v1',
  'approval.resolved.v1',
  'notification.requested.v1',
  'project.archived.v1',
  'work.type_changed.v1',
]);

export const EventEnvelopeBaseSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    eventId: UuidSchema,
    eventName: EventNameSchema,
    occurredAtUtc: UtcInstantSchema,
    correlationId: CorrelationIdSchema,
    causationId: UuidSchema.nullable(),
    producer: z.string().trim().min(1).max(80),
    aggregateType: z.string().trim().min(1).max(80),
    aggregateId: UuidSchema,
    aggregateVersion: AggregateVersionSchema,
    actorId: UuidSchema.nullable(),
  })
  .strict();

const ExternalProcedureChangedPayloadSchema = z
  .object({
    projectId: UuidSchema,
    workId: UuidSchema,
    procedureId: UuidSchema,
    source: ExternalProcedureSourceSchema,
    previousNormalizedStatus: NormalizedExternalStatusSchema.nullable(),
    normalizedStatus: NormalizedExternalStatusSchema,
    originalText: z.string().max(100_000),
    observedAtUtc: UtcInstantSchema,
  })
  .strict();

const WorkTypeChangedPayloadSchema = z
  .object({
    projectId: UuidSchema,
    workId: UuidSchema,
    previousType: WorkTypeSchema,
    newType: WorkTypeSchema,
    previousInternalStatus: z.string().trim().min(1).max(80),
    historicalExternalProceduresDeactivated: z.boolean(),
    approvalRequestId: UuidSchema,
    reason: z.string().trim().min(1).max(1000),
  })
  .strict();

const ProjectArchivedPayloadSchema = z
  .object({
    projectId: UuidSchema,
    workIds: z.array(UuidSchema).min(1),
    approvalRequestId: UuidSchema,
    reason: z.string().trim().min(1).max(1000),
  })
  .strict();

const OneDriveItemChangedPayloadSchema = z
  .object({
    projectId: UuidSchema,
    workId: UuidSchema,
    documentId: UuidSchema,
    driveId: z.string().trim().min(1).max(512),
    driveItemId: z.string().trim().min(1).max(512),
    changeType: z.enum([
      'created',
      'updated',
      'moved',
      'renamed',
      'archived',
      'restored',
      'externally_removed',
    ]),
    versionTag: z.string().trim().min(1).max(512),
    observedAtUtc: UtcInstantSchema,
  })
  .strict();

const TaskOverduePayloadSchema = z
  .object({
    projectId: UuidSchema,
    workId: UuidSchema,
    taskId: UuidSchema,
    dueAtUtc: UtcInstantSchema,
    detectedAtUtc: UtcInstantSchema,
    conditionKey: z.string().trim().min(1).max(160),
  })
  .strict();

const ApprovalRequestedPayloadSchema = z
  .object({
    scope: ResourceScopeSchema,
    approvalRequestId: UuidSchema,
    action: z.string().trim().min(1).max(120),
    targetEntityType: z.string().trim().min(1).max(80),
    targetEntityId: UuidSchema,
    targetEntityVersion: AggregateVersionSchema,
    requestedAtUtc: UtcInstantSchema,
  })
  .strict();

const ApprovalResolvedPayloadSchema = z
  .object({
    scope: ResourceScopeSchema,
    approvalRequestId: UuidSchema,
    decision: z.enum(['approved', 'rejected']),
    targetEntityType: z.string().trim().min(1).max(80),
    targetEntityId: UuidSchema,
    reviewedTargetVersion: AggregateVersionSchema,
    decidedAtUtc: UtcInstantSchema,
  })
  .strict();

const NotificationRequestedPayloadSchema = z
  .object({
    scope: ResourceScopeSchema,
    notificationRequestId: UuidSchema,
    category: z.string().trim().min(1).max(80),
    severity: z.enum(['informational', 'attention', 'high', 'critical']),
    recipientUserIds: z.array(UuidSchema).min(1),
    subjectId: UuidSchema,
    deduplicationKey: z.string().trim().min(1).max(200),
    availableAtUtc: UtcInstantSchema,
  })
  .strict();

export const DomainEventSchema = z.discriminatedUnion('eventName', [
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('apt.status_changed.v1'),
    payload: ExternalProcedureChangedPayloadSchema.extend({ source: z.literal('apt') }),
  }),
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('siri.procedure_changed.v1'),
    payload: ExternalProcedureChangedPayloadSchema.extend({ source: z.literal('siri') }),
  }),
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('project.archived.v1'),
    payload: ProjectArchivedPayloadSchema,
  }),
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('work.type_changed.v1'),
    payload: WorkTypeChangedPayloadSchema,
  }),
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('onedrive.item_changed.v1'),
    payload: OneDriveItemChangedPayloadSchema,
  }),
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('task.overdue.v1'),
    payload: TaskOverduePayloadSchema,
  }),
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('approval.requested.v1'),
    payload: ApprovalRequestedPayloadSchema,
  }),
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('approval.resolved.v1'),
    payload: ApprovalResolvedPayloadSchema,
  }),
  EventEnvelopeBaseSchema.extend({
    eventName: z.literal('notification.requested.v1'),
    payload: NotificationRequestedPayloadSchema,
  }),
]);

export type EventName = z.infer<typeof EventNameSchema>;
export type DomainEvent = z.infer<typeof DomainEventSchema>;
