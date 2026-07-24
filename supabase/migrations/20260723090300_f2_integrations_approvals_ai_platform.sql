-- Fase 2 / 03: trámites externos, referencias OneDrive, aprobaciones,
-- notificaciones, IA, auditoría y outbox.

begin;

create table public.external_procedures (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  provider text not null check (provider in ('apt', 'siri')),
  procedure_kind text not null check (btrim(procedure_kind) <> ''),
  external_reference text,
  contract_number text,
  plan_number text,
  property_number text,
  registry_folio text,
  registry_entry text,
  is_active boolean not null default true,
  monitoring_enabled boolean not null default false,
  deactivated_at timestamptz,
  deactivated_by uuid references public.app_users(id) on delete restrict,
  deactivation_reason text,
  last_successful_query_at timestamptz,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, work_id, id),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint external_procedures_deactivation_complete check (
    (is_active and deactivated_at is null and deactivated_by is null and deactivation_reason is null)
    or (
      not is_active
      and deactivated_at is not null
      and deactivated_by is not null
      and nullif(btrim(deactivation_reason), '') is not null
      and not monitoring_enabled
    )
  ),
  constraint external_procedures_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create unique index external_procedures_reference_uidx
  on public.external_procedures (provider, external_reference)
  where external_reference is not null;

create table public.external_status_events (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  external_procedure_id uuid not null,
  original_status_text text not null check (btrim(original_status_text) <> ''),
  normalized_status_code text not null check (
    normalized_status_code in (
      'unqueried',
      'not_found',
      'in_progress',
      'attention_required',
      'resolved_favorable',
      'resolved_unfavorable',
      'completed',
      'query_error',
      'unclassified'
    )
  ),
  source_observed_at timestamptz,
  recorded_at timestamptz not null default statement_timestamp(),
  recorded_by uuid references public.app_users(id) on delete restrict,
  source_fingerprint text not null check (btrim(source_fingerprint) <> ''),
  payload_metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(payload_metadata) = 'object'),
  correlation_id uuid not null default gen_random_uuid(),
  unique (external_procedure_id, source_fingerprint),
  foreign key (project_id, work_id, external_procedure_id)
    references public.external_procedures(project_id, work_id, id) on delete restrict
);

create table public.external_query_runs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  external_procedure_id uuid not null,
  provider text not null check (provider in ('apt', 'siri')),
  trigger_kind text not null check (trigger_kind in ('scheduled', 'manual', 'retry')),
  status text not null check (status in ('pending', 'running', 'succeeded', 'partial', 'failed', 'blocked')),
  idempotency_key text not null unique check (btrim(idempotency_key) <> ''),
  attempt_number integer not null default 1 check (attempt_number > 0),
  started_at timestamptz not null default statement_timestamp(),
  finished_at timestamptz,
  error_code text,
  error_summary text,
  result_metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(result_metadata) = 'object'),
  executed_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id, external_procedure_id)
    references public.external_procedures(project_id, work_id, id) on delete restrict,
  constraint external_query_run_time check (finished_at is null or finished_at >= started_at),
  constraint external_query_run_error check (
    status not in ('failed', 'blocked')
    or nullif(btrim(error_summary), '') is not null
  )
);

alter table public.managements
  add column external_procedure_id uuid,
  add constraint managements_external_procedure_fk
    foreign key (project_id, work_id, external_procedure_id)
    references public.external_procedures(project_id, work_id, id) on delete restrict;

create table public.drive_items (
  id uuid primary key default gen_random_uuid(),
  scope_kind text not null check (scope_kind in ('client', 'project_root', 'work')),
  client_id uuid references public.clients(id) on delete restrict,
  project_id uuid references public.projects(id) on delete restrict,
  work_id uuid,
  drive_id text not null check (btrim(drive_id) <> ''),
  drive_item_id text not null check (btrim(drive_item_id) <> ''),
  parent_drive_item_id text,
  item_kind text not null check (item_kind in ('file', 'folder')),
  name text not null check (btrim(name) <> ''),
  current_path text,
  mime_type text,
  size_bytes bigint check (size_bytes is null or size_bytes >= 0),
  etag text,
  document_type_code text,
  classification_code text,
  sensitivity_code text,
  is_protected boolean not null default false,
  external_deleted_at timestamptz,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  previous_path text,
  correlation_id uuid not null default gen_random_uuid(),
  unique (drive_id, drive_item_id),
  unique (project_id, work_id, id),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint drive_items_scope_complete check (
    (scope_kind = 'client' and client_id is not null and project_id is null and work_id is null)
    or (scope_kind = 'project_root' and client_id is null and project_id is not null and work_id is null)
    or (scope_kind = 'work' and client_id is null and project_id is not null and work_id is not null)
  ),
  constraint drive_items_file_metadata check (
    item_kind = 'file' or (mime_type is null and size_bytes is null)
  ),
  constraint drive_items_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null and previous_path is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
      and nullif(btrim(previous_path), '') is not null
    )
  )
);

create table public.drive_operations (
  id uuid primary key default gen_random_uuid(),
  drive_item_id uuid not null references public.drive_items(id) on delete restrict,
  project_id uuid,
  work_id uuid,
  operation_kind text not null check (
    operation_kind in ('link', 'create_folder', 'upload', 'rename', 'move', 'archive', 'restore', 'trash_empty_folder', 'delta_observed')
  ),
  status text not null check (status in ('requested', 'approved', 'running', 'succeeded', 'failed', 'superseded')),
  idempotency_key text not null unique check (btrim(idempotency_key) <> ''),
  target_etag text,
  previous_path text,
  resulting_path text,
  reason text,
  requested_at timestamptz not null default statement_timestamp(),
  requested_by uuid references public.app_users(id) on delete restrict,
  completed_at timestamptz,
  result_metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(result_metadata) = 'object'),
  updated_at timestamptz not null default statement_timestamp(),
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint drive_operations_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  ),
  constraint drive_operations_time check (completed_at is null or completed_at >= requested_at),
  constraint drive_operations_reason_for_sensitive check (
    operation_kind not in ('archive', 'restore', 'trash_empty_folder')
    or nullif(btrim(reason), '') is not null
  )
);

create table public.drive_delta_cursors (
  id uuid primary key default gen_random_uuid(),
  drive_id text not null unique check (btrim(drive_id) <> ''),
  delta_cursor text not null check (btrim(delta_cursor) <> ''),
  last_successful_sync_at timestamptz not null,
  created_at timestamptz not null default statement_timestamp(),
  updated_at timestamptz not null default statement_timestamp(),
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid()
);

create table public.approval_targets (
  id uuid primary key default gen_random_uuid(),
  owner_module text not null check (owner_module ~ '^[a-z][a-z0-9_]*$'),
  target_kind text not null check (target_kind ~ '^[a-z][a-z0-9_]*$'),
  target_entity_id uuid not null,
  target_version bigint not null check (target_version > 0),
  scope_kind text not null check (scope_kind in ('organization', 'project', 'work')),
  project_id uuid references public.projects(id) on delete restrict,
  work_id uuid,
  target_snapshot jsonb not null check (jsonb_typeof(target_snapshot) = 'object'),
  snapshot_hash text not null check (btrim(snapshot_hash) <> ''),
  registered_at timestamptz not null default statement_timestamp(),
  registered_by uuid not null references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (owner_module, target_kind, target_entity_id, target_version),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint approval_targets_scope_complete check (
    (scope_kind = 'organization' and project_id is null and work_id is null)
    or (scope_kind = 'project' and project_id is not null and work_id is null)
    or (scope_kind = 'work' and project_id is not null and work_id is not null)
  )
);

create table public.approval_requests (
  id uuid primary key default gen_random_uuid(),
  approval_target_id uuid not null references public.approval_targets(id) on delete restrict,
  project_id uuid references public.projects(id) on delete restrict,
  work_id uuid,
  action_code text not null check (action_code ~ '^[a-z][a-z0-9_.]*$'),
  status text not null check (
    status in ('draft', 'pending', 'approved', 'rejected', 'expired', 'cancelled', 'executing', 'executed', 'failed', 'superseded')
  ),
  reason text,
  impact_summary text,
  requested_change jsonb not null check (jsonb_typeof(requested_change) = 'object'),
  requested_at timestamptz not null default statement_timestamp(),
  requested_by uuid not null references public.app_users(id) on delete restrict,
  due_at timestamptz,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint approval_requests_work_pair check (
    (project_id is null and work_id is null)
    or project_id is not null
  ),
  constraint approval_requests_reason_on_terminal check (
    status not in ('rejected', 'cancelled', 'failed', 'superseded')
    or nullif(btrim(reason), '') is not null
  )
);

alter table public.work_type_history
  add constraint work_type_history_approval_request_fk
  foreign key (approval_request_id)
  references public.approval_requests(id) on delete restrict;

create table public.approval_decisions (
  id uuid primary key default gen_random_uuid(),
  approval_request_id uuid not null references public.approval_requests(id) on delete restrict,
  project_id uuid,
  work_id uuid,
  decision text not null check (decision in ('approved', 'rejected')),
  comment text,
  decided_at timestamptz not null default statement_timestamp(),
  decided_by uuid not null references public.app_users(id) on delete restrict,
  target_version_reviewed bigint not null check (target_version_reviewed > 0),
  correlation_id uuid not null default gen_random_uuid(),
  unique (approval_request_id, decided_by),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint approval_decisions_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  )
);

create table public.approval_executions (
  id uuid primary key default gen_random_uuid(),
  approval_request_id uuid not null unique references public.approval_requests(id) on delete restrict,
  project_id uuid,
  work_id uuid,
  execution_key text not null unique check (btrim(execution_key) <> ''),
  status text not null check (status in ('pending', 'running', 'succeeded', 'failed')),
  attempt_count integer not null default 0 check (attempt_count >= 0),
  started_at timestamptz,
  finished_at timestamptz,
  result_metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(result_metadata) = 'object'),
  error_summary text,
  updated_at timestamptz not null default statement_timestamp(),
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint approval_execution_time check (
    finished_at is null or (started_at is not null and finished_at >= started_at)
  ),
  constraint approval_execution_error check (
    status <> 'failed' or nullif(btrim(error_summary), '') is not null
  ),
  constraint approval_execution_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  )
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.app_users(id) on delete restrict,
  project_id uuid,
  work_id uuid,
  category text not null check (
    category in ('apt', 'siri', 'task', 'schedule', 'onedrive', 'integration', 'approval', 'ai', 'system')
  ),
  severity text not null check (severity in ('info', 'attention', 'high', 'critical')),
  title text not null check (btrim(title) <> ''),
  body text not null check (btrim(body) <> ''),
  deep_link text,
  deduplication_key text not null check (btrim(deduplication_key) <> ''),
  available_at timestamptz not null default statement_timestamp(),
  created_at timestamptz not null default statement_timestamp(),
  read_at timestamptz,
  archived_at timestamptz,
  updated_at timestamptz not null default statement_timestamp(),
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  unique (user_id, deduplication_key),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint notifications_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  )
);

create table public.notification_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.app_users(id) on delete restrict,
  category text not null check (
    category in ('apt', 'siri', 'task', 'schedule', 'onedrive', 'integration', 'approval', 'ai', 'system')
  ),
  in_app_enabled boolean not null default true,
  push_enabled boolean not null default false,
  quiet_hours_start time not null default time '20:00:00',
  quiet_hours_end time not null default time '07:00:00',
  timezone_name text not null default 'America/Costa_Rica',
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  unique (user_id, category),
  constraint notification_preferences_timezone check (timezone_name = 'America/Costa_Rica')
);

create table public.push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.app_users(id) on delete restrict,
  user_device_id uuid not null references public.user_devices(id) on delete restrict,
  endpoint_hash text not null unique check (btrim(endpoint_hash) <> ''),
  subscription_reference text not null check (btrim(subscription_reference) <> ''),
  status text not null default 'active' check (status in ('active', 'revoked', 'failed')),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  revoked_at timestamptz,
  revocation_reason text,
  correlation_id uuid not null default gen_random_uuid(),
  constraint push_subscription_revocation_complete check (
    (status = 'active' and revoked_at is null and revocation_reason is null)
    or (
      status in ('revoked', 'failed')
      and revoked_at is not null
      and nullif(btrim(revocation_reason), '') is not null
    )
  )
);

create table public.ai_prompt_versions (
  id uuid primary key default gen_random_uuid(),
  prompt_code text not null check (prompt_code ~ '^[a-z][a-z0-9_.]*$'),
  version_number integer not null check (version_number > 0),
  schema_version text not null check (btrim(schema_version) <> ''),
  prompt_template text not null check (btrim(prompt_template) <> ''),
  model_route text not null check (btrim(model_route) <> ''),
  status text not null check (status in ('draft', 'active', 'superseded', 'archived')),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  published_at timestamptz,
  published_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (prompt_code, version_number)
);

create table public.ai_runs (
  id uuid primary key default gen_random_uuid(),
  prompt_version_id uuid not null references public.ai_prompt_versions(id) on delete restrict,
  requested_by uuid not null references public.app_users(id) on delete restrict,
  project_id uuid,
  work_id uuid,
  purpose_code text not null check (purpose_code ~ '^[a-z][a-z0-9_.]*$'),
  status text not null check (status in ('pending', 'running', 'succeeded', 'failed', 'blocked')),
  model_id text,
  cutoff_at timestamptz not null,
  started_at timestamptz not null default statement_timestamp(),
  finished_at timestamptz,
  input_metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(input_metadata) = 'object'),
  output_structured jsonb,
  error_summary text,
  updated_at timestamptz not null default statement_timestamp(),
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint ai_runs_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  ),
  constraint ai_runs_time check (finished_at is null or finished_at >= started_at),
  constraint ai_runs_error check (
    status not in ('failed', 'blocked') or nullif(btrim(error_summary), '') is not null
  )
);

create table public.ai_evidence (
  id uuid primary key default gen_random_uuid(),
  ai_run_id uuid not null references public.ai_runs(id) on delete restrict,
  project_id uuid,
  work_id uuid,
  source_module text not null check (source_module ~ '^[a-z][a-z0-9_]*$'),
  source_entity_id uuid not null,
  source_version bigint not null check (source_version > 0),
  excerpt_or_fact text not null check (btrim(excerpt_or_fact) <> ''),
  observed_at timestamptz not null,
  created_at timestamptz not null default statement_timestamp(),
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint ai_evidence_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  )
);

create table public.ai_proposals (
  id uuid primary key default gen_random_uuid(),
  ai_run_id uuid not null references public.ai_runs(id) on delete restrict,
  project_id uuid,
  work_id uuid,
  proposal_kind text not null check (proposal_kind ~ '^[a-z][a-z0-9_.]*$'),
  proposal_payload jsonb not null check (jsonb_typeof(proposal_payload) = 'object'),
  confidence numeric(5, 4) not null check (confidence between 0 and 1),
  cutoff_at timestamptz not null,
  status text not null default 'proposed'
    check (status in ('proposed', 'accepted', 'rejected', 'superseded', 'expired')),
  decided_at timestamptz,
  decided_by uuid references public.app_users(id) on delete restrict,
  decision_reason text,
  created_at timestamptz not null default statement_timestamp(),
  updated_at timestamptz not null default statement_timestamp(),
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint ai_proposals_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  ),
  constraint ai_proposal_decision_complete check (
    (status = 'proposed' and decided_at is null and decided_by is null and decision_reason is null)
    or (
      status in ('accepted', 'rejected', 'superseded', 'expired')
      and decided_at is not null
      and decided_by is not null
      and nullif(btrim(decision_reason), '') is not null
    )
  )
);

create table public.audit_events (
  id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz not null default statement_timestamp(),
  actor_user_id uuid references public.app_users(id) on delete restrict,
  actor_process text,
  actor_role_code text,
  module_code text not null check (module_code ~ '^[a-z][a-z0-9_]*$'),
  entity_kind text not null check (entity_kind ~ '^[a-z][a-z0-9_]*$'),
  entity_id uuid,
  project_id uuid,
  work_id uuid,
  action_code text not null check (action_code ~ '^[a-z][a-z0-9_.]*$'),
  result_code text not null check (btrim(result_code) <> ''),
  reason text,
  old_values jsonb,
  new_values jsonb,
  ip_address inet,
  correlation_id uuid not null,
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint audit_actor_present check (
    actor_user_id is not null or nullif(btrim(actor_process), '') is not null
  ),
  constraint audit_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  )
);

create table public.outbox_events (
  id uuid primary key default gen_random_uuid(),
  event_name text not null check (event_name ~ '^[a-z][a-z0-9_.]*$'),
  event_version integer not null check (event_version > 0),
  aggregate_kind text not null check (aggregate_kind ~ '^[a-z][a-z0-9_]*$'),
  aggregate_id uuid not null,
  aggregate_version bigint not null check (aggregate_version > 0),
  project_id uuid,
  work_id uuid,
  payload jsonb not null check (jsonb_typeof(payload) = 'object'),
  idempotency_key text not null unique check (btrim(idempotency_key) <> ''),
  occurred_at timestamptz not null default statement_timestamp(),
  available_at timestamptz not null default statement_timestamp(),
  status text not null default 'pending'
    check (status in ('pending', 'publishing', 'published', 'failed', 'dead_letter')),
  attempt_count integer not null default 0 check (attempt_count >= 0),
  locked_at timestamptz,
  published_at timestamptz,
  last_error text,
  updated_at timestamptz not null default statement_timestamp(),
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null,
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint outbox_work_pair check (
    (project_id is null and work_id is null)
    or (project_id is not null and work_id is not null)
  ),
  constraint outbox_published_complete check (
    status <> 'published' or published_at is not null
  )
);

create table public.idempotent_consumptions (
  id uuid primary key default gen_random_uuid(),
  consumer_name text not null check (consumer_name ~ '^[a-z][a-z0-9_.-]*$'),
  idempotency_key text not null check (btrim(idempotency_key) <> ''),
  event_id uuid references public.outbox_events(id) on delete restrict,
  consumed_at timestamptz not null default statement_timestamp(),
  result_hash text,
  correlation_id uuid not null,
  unique (consumer_name, idempotency_key)
);

commit;
