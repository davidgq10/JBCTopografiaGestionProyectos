import { z } from 'zod';
import {
  AggregateVersionSchema,
  ContractVersionSchema,
  CorrelationIdSchema,
  IdempotencyKeySchema,
  ResourceScopeSchema,
  UtcInstantSchema,
  UuidSchema,
} from './common.js';

export const ApprovalStatusSchema = z.enum([
  'draft',
  'pending',
  'approved',
  'rejected',
  'expired',
  'cancelled',
  'executing',
  'executed',
  'failed',
  'superseded',
]);

export const ApprovalTargetSchema = z
  .object({
    scope: ResourceScopeSchema,
    entityType: z.string().trim().min(1).max(80),
    entityId: UuidSchema,
    entityVersion: AggregateVersionSchema,
  })
  .strict();

export const RequestApprovalCommandSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    scope: ResourceScopeSchema,
    idempotencyKey: IdempotencyKeySchema,
    correlationId: CorrelationIdSchema,
    action: z.string().trim().min(1).max(120),
    reason: z.string().trim().min(1).max(1000),
    impactSummary: z.string().trim().min(1).max(4000),
    target: ApprovalTargetSchema,
  })
  .strict()
  .superRefine((value, context) => {
    if (JSON.stringify(value.scope) !== JSON.stringify(value.target.scope)) {
      context.addIssue({
        code: 'custom',
        path: ['target'],
        message: 'El objetivo debe pertenecer al mismo alcance de la operación',
      });
    }
  });

export const ApprovalRequestSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    approvalRequestId: UuidSchema,
    scope: ResourceScopeSchema,
    status: ApprovalStatusSchema,
    action: z.string().trim().min(1).max(120),
    reason: z.string().trim().min(1).max(1000),
    target: ApprovalTargetSchema,
    requestedByActorId: UuidSchema,
    requestedAtUtc: UtcInstantSchema,
    decidedByActorId: UuidSchema.nullable(),
    decidedAtUtc: UtcInstantSchema.nullable(),
    correlationId: CorrelationIdSchema,
  })
  .strict();

export const ResolveApprovalCommandSchema = z
  .object({
    contractVersion: ContractVersionSchema,
    scope: ResourceScopeSchema,
    approvalRequestId: UuidSchema,
    idempotencyKey: IdempotencyKeySchema,
    correlationId: CorrelationIdSchema,
    expectedTargetVersion: AggregateVersionSchema,
    decision: z.enum(['approve', 'reject']),
    comment: z.string().trim().min(1).max(2000),
  })
  .strict();

export type ApprovalTarget = z.infer<typeof ApprovalTargetSchema>;
export type ApprovalRequest = z.infer<typeof ApprovalRequestSchema>;
export type RequestApprovalCommand = z.infer<typeof RequestApprovalCommandSchema>;
export type ResolveApprovalCommand = z.infer<typeof ResolveApprovalCommandSchema>;
