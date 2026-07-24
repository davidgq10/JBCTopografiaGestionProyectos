-- Fase 2 / 04: invariantes, concurrencia, historia append-only e índices.

begin;

create or replace function app_private.touch_row_versioned_row()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at := statement_timestamp();
  new.row_version := old.row_version + 1;
  return new;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'app_users', 'roles', 'permissions', 'user_roles', 'role_permissions',
    'specialties', 'user_specialties', 'user_devices', 'catalogs',
    'catalog_values', 'work_types', 'work_state_definitions', 'resources',
    'clients', 'client_contacts', 'client_addresses', 'projects', 'works',
    'project_memberships', 'work_memberships', 'project_participants',
    'properties', 'work_properties', 'work_property_values', 'managements',
    'management_wait_periods', 'tasks', 'task_checklists',
    'task_checklist_items', 'task_dependencies', 'schedule_blocks',
    'external_procedures', 'external_query_runs', 'drive_items',
    'drive_operations', 'drive_delta_cursors', 'approval_requests',
    'approval_executions', 'notifications', 'notification_preferences',
    'push_subscriptions', 'ai_runs', 'ai_proposals', 'outbox_events'
  ]
  loop
    execute format(
      'create trigger %I before update on public.%I for each row execute function app_private.touch_versioned_row()',
      'trg_' || table_name || '_touch_version',
      table_name
    );
  end loop;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array['catalog_versions', 'work_type_config_versions']
  loop
    execute format(
      'create trigger %I before update on public.%I for each row execute function app_private.touch_row_versioned_row()',
      'trg_' || table_name || '_touch_row_version',
      table_name
    );
  end loop;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'work_type_history', 'management_notes', 'external_status_events',
    'approval_targets', 'approval_decisions', 'ai_evidence', 'audit_events',
    'idempotent_consumptions'
  ]
  loop
    execute format(
      'create trigger %I before update or delete on public.%I for each row execute function app_private.reject_update_or_delete()',
      'trg_' || table_name || '_append_only',
      table_name
    );
  end loop;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'app_users', 'roles', 'permissions', 'specialties', 'user_devices',
    'catalogs', 'catalog_versions', 'catalog_values', 'work_types',
    'work_type_config_versions', 'work_state_definitions', 'resources',
    'clients', 'client_contacts', 'client_addresses', 'projects', 'works',
    'project_memberships', 'work_memberships', 'project_participants',
    'properties', 'work_properties', 'work_property_values', 'managements',
    'management_wait_periods', 'tasks', 'task_checklists',
    'task_checklist_items', 'task_dependencies', 'schedule_blocks',
    'external_procedures', 'external_query_runs', 'drive_items',
    'drive_operations', 'drive_delta_cursors', 'approval_requests',
    'approval_executions', 'notifications', 'notification_preferences',
    'push_subscriptions', 'ai_prompt_versions', 'ai_runs', 'ai_proposals',
    'outbox_events'
  ]
  loop
    execute format(
      'create trigger %I before delete on public.%I for each row execute function app_private.reject_delete()',
      'trg_' || table_name || '_no_delete',
      table_name
    );
  end loop;
end;
$$;

create or replace function app_private.assert_project_has_work()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  checked_project_id uuid;
begin
  if tg_table_name = 'projects' then
    checked_project_id := coalesce(new.id, old.id);
  else
    checked_project_id := old.project_id;
  end if;

  if exists (select 1 from public.projects p where p.id = checked_project_id)
     and not exists (select 1 from public.works w where w.project_id = checked_project_id) then
    raise exception using
      errcode = '23514',
      message = format('El Proyecto/Contratación %s debe conservar al menos un Trabajo', checked_project_id);
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create constraint trigger trg_projects_require_work
after insert or update on public.projects
deferrable initially deferred
for each row execute function app_private.assert_project_has_work();

create constraint trigger trg_works_preserve_project_work
after update or delete on public.works
deferrable initially deferred
for each row execute function app_private.assert_project_has_work();

create or replace function app_private.validate_external_procedure_work_type()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  apt_allowed boolean;
  siri_allowed boolean;
begin
  if not new.is_active and not new.monitoring_enabled then
    return new;
  end if;

  select wt.supports_apt, wt.supports_siri
    into apt_allowed, siri_allowed
  from public.works w
  join public.work_types wt on wt.id = w.work_type_id
  where w.project_id = new.project_id and w.id = new.work_id;

  if new.provider = 'apt' and not coalesce(apt_allowed, false) then
    raise exception using errcode = '23514',
      message = 'APT activo solo se permite en Trabajo Plano de catastro';
  end if;

  if new.provider = 'siri' and not coalesce(siri_allowed, false) then
    raise exception using errcode = '23514',
      message = 'SIRI activo solo se permite en Trabajo Plano de catastro';
  end if;

  return new;
end;
$$;

create trigger trg_external_procedures_validate_work_type
before insert or update of project_id, work_id, provider, is_active, monitoring_enabled
on public.external_procedures
for each row execute function app_private.validate_external_procedure_work_type();

create or replace function app_private.capture_work_type_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  actor_id uuid;
  approval_id uuid;
  change_correlation_id uuid;
  comparison_payload jsonb;
  apt_allowed boolean;
  siri_allowed boolean;
  approval_is_valid boolean;
begin
  if new.work_type_id is not distinct from old.work_type_id then
    return new;
  end if;

  actor_id := nullif(current_setting('app.actor_id', true), '')::uuid;
  approval_id := nullif(current_setting('app.approval_request_id', true), '')::uuid;
  change_correlation_id := nullif(current_setting('app.correlation_id', true), '')::uuid;
  comparison_payload := nullif(current_setting('app.change_comparison', true), '')::jsonb;

  if actor_id is null or approval_id is null or change_correlation_id is null
     or comparison_payload is null then
    raise exception using errcode = '23514',
      message = 'Cambiar el tipo de Trabajo requiere actor, aprobación, correlación y comparativo';
  end if;

  select exists (
    select 1
    from public.approval_requests ar
    join public.approval_targets at on at.id = ar.approval_target_id
    where ar.id = approval_id
      and ar.status in ('approved', 'executing')
      and at.target_kind = 'work_type_change'
      and at.target_entity_id = old.id
      and at.target_version = old.version
      and at.project_id = old.project_id
      and at.work_id = old.id
  ) into approval_is_valid;

  if not approval_is_valid then
    raise exception using errcode = '23514',
      message = 'La aprobación no corresponde a la versión vigente del Trabajo';
  end if;

  insert into public.work_type_history (
    project_id,
    work_id,
    previous_work_type_id,
    new_work_type_id,
    previous_configuration_version_id,
    new_configuration_version_id,
    previous_internal_state_id,
    new_internal_state_id,
    previous_work_version,
    comparison,
    approval_request_id,
    changed_by,
    correlation_id
  )
  values (
    old.project_id,
    old.id,
    old.work_type_id,
    new.work_type_id,
    old.configuration_version_id,
    new.configuration_version_id,
    old.internal_state_id,
    new.internal_state_id,
    old.version,
    comparison_payload,
    approval_id,
    actor_id,
    change_correlation_id
  );

  select supports_apt, supports_siri
    into apt_allowed, siri_allowed
  from public.work_types
  where id = new.work_type_id;

  update public.external_procedures
  set
    is_active = false,
    monitoring_enabled = false,
    deactivated_at = statement_timestamp(),
    deactivated_by = actor_id,
    deactivation_reason = 'work_type_changed',
    updated_by = actor_id,
    correlation_id = change_correlation_id
  where project_id = old.project_id
    and work_id = old.id
    and is_active
    and (
      (provider = 'apt' and not apt_allowed)
      or (provider = 'siri' and not siri_allowed)
    );

  new.updated_by := actor_id;
  new.correlation_id := change_correlation_id;
  return new;
end;
$$;

create trigger trg_works_10_capture_type_change
before update of work_type_id, configuration_version_id, internal_state_id
on public.works
for each row execute function app_private.capture_work_type_change();

create or replace function app_private.reject_task_parent_cycle()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  cycle_found boolean;
begin
  if new.parent_task_id is null then
    return new;
  end if;

  with recursive ancestors(id, parent_task_id) as (
    select t.id, t.parent_task_id
    from public.tasks t
    where t.project_id = new.project_id
      and t.work_id = new.work_id
      and t.id = new.parent_task_id
    union all
    select t.id, t.parent_task_id
    from public.tasks t
    join ancestors a on a.parent_task_id = t.id
    where t.project_id = new.project_id and t.work_id = new.work_id
  )
  select exists (select 1 from ancestors where id = new.id) into cycle_found;

  if cycle_found then
    raise exception using errcode = '23514',
      message = 'La jerarquía de tareas no puede contener ciclos';
  end if;
  return new;
end;
$$;

create trigger trg_tasks_reject_parent_cycle
before insert or update of parent_task_id, project_id, work_id
on public.tasks
for each row execute function app_private.reject_task_parent_cycle();

create or replace function app_private.reject_task_dependency_cycle()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  cycle_found boolean;
begin
  with recursive reachable(task_id) as (
    select new.successor_task_id
    union
    select td.successor_task_id
    from public.task_dependencies td
    join reachable r on td.predecessor_task_id = r.task_id
    where td.project_id = new.project_id
      and td.work_id = new.work_id
      and td.archived_at is null
      and td.id <> new.id
  )
  select exists (
    select 1 from reachable where task_id = new.predecessor_task_id
  ) into cycle_found;

  if cycle_found then
    raise exception using errcode = '23514',
      message = 'Las dependencias de tareas no pueden contener ciclos';
  end if;
  return new;
end;
$$;

create trigger trg_task_dependencies_reject_cycle
before insert or update of predecessor_task_id, successor_task_id, project_id, work_id, archived_at
on public.task_dependencies
for each row
when (new.archived_at is null)
execute function app_private.reject_task_dependency_cycle();

create or replace function app_private.validate_approval_scope()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  parent_project_id uuid;
  parent_work_id uuid;
begin
  if tg_table_name = 'approval_requests' then
    select project_id, work_id
      into parent_project_id, parent_work_id
    from public.approval_targets
    where id = new.approval_target_id;
  else
    select project_id, work_id
      into parent_project_id, parent_work_id
    from public.approval_requests
    where id = new.approval_request_id;
  end if;

  if new.project_id is distinct from parent_project_id
     or new.work_id is distinct from parent_work_id then
    raise exception using errcode = '23514',
      message = 'El alcance project_id/work_id de la aprobación debe coincidir con su padre';
  end if;
  return new;
end;
$$;

create trigger trg_approval_requests_validate_scope
before insert or update of approval_target_id, project_id, work_id
on public.approval_requests
for each row execute function app_private.validate_approval_scope();

create trigger trg_approval_decisions_validate_scope
before insert on public.approval_decisions
for each row execute function app_private.validate_approval_scope();

create trigger trg_approval_executions_validate_scope
before insert or update of approval_request_id, project_id, work_id
on public.approval_executions
for each row execute function app_private.validate_approval_scope();

create or replace function app_private.validate_ai_scope()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  run_project_id uuid;
  run_work_id uuid;
begin
  select project_id, work_id
    into run_project_id, run_work_id
  from public.ai_runs
  where id = new.ai_run_id;

  if new.project_id is distinct from run_project_id
     or new.work_id is distinct from run_work_id then
    raise exception using errcode = '23514',
      message = 'El alcance project_id/work_id del artefacto IA debe coincidir con la ejecución';
  end if;
  return new;
end;
$$;

create trigger trg_ai_evidence_validate_scope
before insert on public.ai_evidence
for each row execute function app_private.validate_ai_scope();

create trigger trg_ai_proposals_validate_scope
before insert or update of ai_run_id, project_id, work_id
on public.ai_proposals
for each row execute function app_private.validate_ai_scope();

create or replace function app_private.validate_drive_operation_scope()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  item_project_id uuid;
  item_work_id uuid;
begin
  select project_id, work_id
    into item_project_id, item_work_id
  from public.drive_items
  where id = new.drive_item_id;

  if item_work_id is not null and (
    new.project_id is distinct from item_project_id
    or new.work_id is distinct from item_work_id
  ) then
    raise exception using errcode = '23514',
      message = 'La operación OneDrive de Trabajo debe conservar el mismo project_id/work_id';
  end if;

  if item_work_id is null and (new.project_id is not null or new.work_id is not null) then
    raise exception using errcode = '23514',
      message = 'Una operación OneDrive no operativa no puede inventar alcance de Trabajo';
  end if;
  return new;
end;
$$;

create trigger trg_drive_operations_validate_scope
before insert or update of drive_item_id, project_id, work_id
on public.drive_operations
for each row execute function app_private.validate_drive_operation_scope();

create index projects_client_idx on public.projects (client_id, archived_at);
create index projects_status_idx on public.projects (contract_status_code, updated_at desc);
create index works_project_idx on public.works (project_id, archived_at, updated_at desc);
create index works_type_state_idx on public.works (work_type_id, internal_state_id);
create index works_responsible_idx on public.works (responsible_user_id, archived_at);
create index project_memberships_user_idx on public.project_memberships (user_id, project_id, ended_at);
create index work_memberships_user_idx on public.work_memberships (user_id, project_id, work_id, ended_at);
create index properties_project_idx on public.properties (project_id, archived_at);
create index properties_plan_idx on public.properties (cadastral_plan_number);
create index properties_number_idx on public.properties (property_number);
create index properties_registry_idx on public.properties (registry_folio, registry_entry);
create index managements_work_idx on public.managements (project_id, work_id, created_at desc);
create index managements_follow_up_idx on public.managements (next_follow_up_at) where archived_at is null;
create index tasks_work_idx on public.tasks (project_id, work_id, archived_at, due_at);
create index tasks_management_idx on public.tasks (management_id) where management_id is not null;
create index tasks_responsible_idx on public.tasks (responsible_user_id, due_at) where archived_at is null;
create index schedule_blocks_work_time_idx on public.schedule_blocks (project_id, work_id, starts_at, ends_at);
create index schedule_block_users_user_idx on public.schedule_block_users (user_id, schedule_block_id);
create index schedule_block_resources_resource_idx on public.schedule_block_resources (resource_id, schedule_block_id);
create index external_procedures_work_idx on public.external_procedures (project_id, work_id, provider, is_active);
create index external_procedures_contract_idx on public.external_procedures (contract_number);
create index external_procedures_plan_idx on public.external_procedures (plan_number);
create index external_procedures_property_idx on public.external_procedures (property_number);
create index external_procedures_registry_idx on public.external_procedures (registry_folio, registry_entry);
create index external_status_events_timeline_idx on public.external_status_events (project_id, work_id, recorded_at desc);
create index external_query_runs_work_idx on public.external_query_runs (project_id, work_id, started_at desc);
create index drive_items_work_idx on public.drive_items (project_id, work_id, archived_at);
create index drive_items_client_idx on public.drive_items (client_id, archived_at);
create index drive_items_name_idx on public.drive_items (lower(name));
create index approval_requests_work_idx on public.approval_requests (project_id, work_id, status, requested_at desc);
create index notifications_user_available_idx on public.notifications (user_id, available_at desc, read_at);
create index ai_runs_work_idx on public.ai_runs (project_id, work_id, started_at desc);
create index audit_events_entity_idx on public.audit_events (module_code, entity_kind, entity_id, occurred_at desc);
create index audit_events_work_idx on public.audit_events (project_id, work_id, occurred_at desc);
create index audit_events_correlation_idx on public.audit_events (correlation_id, occurred_at);
create index outbox_pending_idx on public.outbox_events (available_at, occurred_at)
  where status in ('pending', 'failed');
create index outbox_aggregate_idx on public.outbox_events (aggregate_kind, aggregate_id, aggregate_version);

commit;
