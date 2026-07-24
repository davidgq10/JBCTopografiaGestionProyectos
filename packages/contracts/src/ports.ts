import type { ActorContext, ResourceScope, UtcInstant, WorkContext } from './common.js';
import type { ApprovalRequest, RequestApprovalCommand } from './approval.js';
import type { DomainEvent } from './events.js';
import type { DocumentReference, ExternalProcedureSnapshot, WorkSummary } from './work.js';

export interface ClockPort {
  nowUtc(): UtcInstant;
}

export interface IdGeneratorPort {
  nextUuid(): string;
}

export interface AuthorizationPort {
  assertAllowed(input: {
    actor: ActorContext;
    context: ResourceScope;
    action: string;
    targetId?: string;
  }): Promise<void>;
}

export interface WorkRepositoryPort {
  findAuthorized(input: { actor: ActorContext; context: WorkContext }): Promise<WorkSummary | null>;
  save(input: {
    actor: ActorContext;
    work: WorkSummary;
    expectedVersion: number;
  }): Promise<WorkSummary>;
}

export interface UnitOfWorkPort {
  execute<T>(operation: (transaction: TransactionContext) => Promise<T>): Promise<T>;
}

export interface TransactionContext {
  appendEvent(event: DomainEvent): Promise<void>;
  appendAudit(record: AuditAppendRecord): Promise<void>;
}

export interface AuditAppendRecord {
  auditId: string;
  context: ResourceScope;
  actorId: string | null;
  action: string;
  entityType: string;
  entityId: string;
  occurredAtUtc: UtcInstant;
  correlationId: string;
  result: 'accepted' | 'rejected' | 'failed';
  reason: string | null;
}

export interface IdempotencyPort {
  begin(input: {
    key: string;
    operation: string;
    context: ResourceScope;
    requestFingerprint: string;
  }): Promise<'acquired' | 'replay' | 'conflict'>;
  complete(input: { key: string; responseFingerprint: string }): Promise<void>;
}

export interface ApprovalPort {
  request(input: {
    actor: ActorContext;
    command: RequestApprovalCommand;
  }): Promise<ApprovalRequest>;
}

/** Puerto de almacenamiento documental. El dominio solo recibe metadatos. */
export interface DocumentMetadataPort {
  find(input: {
    actor: ActorContext;
    context: WorkContext;
    documentId: string;
  }): Promise<DocumentReference | null>;
}

/**
 * Solo consulta. No existe submit/update/write para APT o SIRI en el contrato.
 */
export interface ExternalProcedureReadPort {
  query(input: {
    actor: ActorContext;
    context: WorkContext;
    source: 'apt' | 'siri';
    procedureId: string;
  }): Promise<ExternalProcedureSnapshot>;
}

export interface AiProposalPort<TInput, TProposal> {
  propose(input: {
    actor: ActorContext;
    context: ResourceScope;
    value: TInput;
    cutoffAtUtc: UtcInstant;
  }): Promise<{
    proposal: TProposal;
    evidenceIds: readonly string[];
    confidence: number;
    cutoffAtUtc: UtcInstant;
  }>;
}
