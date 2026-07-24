-- Fase 2 / 18: el cambio sensible de tipo ejecuta exactamente la mutación
-- revisada, con decisión aprobatoria y ejecución vigente de un solo uso.

begin;

create or replace function app_private.reject_approval_request_payload_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if old.status <> 'draft'
     and (
       new.approval_target_id is distinct from old.approval_target_id
       or new.project_id is distinct from old.project_id
       or new.work_id is distinct from old.work_id
       or new.action_code is distinct from old.action_code
       or new.requested_change is distinct from old.requested_change
     ) then
    raise exception using errcode = '23514',
      message = 'El objetivo y cambio solicitado son invariables después del borrador';
  end if;
  return new;
end;
$$;

create trigger trg_approval_requests_payload_immutable
before update of approval_target_id, project_id, work_id, action_code, requested_change
on public.approval_requests
for each row execute function app_private.reject_approval_request_payload_change();

create or replace function app_private.reject_approval_execution_identity_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.approval_request_id is distinct from old.approval_request_id
     or new.project_id is distinct from old.project_id
     or new.work_id is distinct from old.work_id
     or new.execution_key is distinct from old.execution_key then
    raise exception using errcode = '23514',
      message = 'La identidad y el alcance de una ejecución de aprobación son invariables';
  end if;
  return new;
end;
$$;

create trigger trg_approval_executions_identity_immutable
before update of approval_request_id, project_id, work_id, execution_key
on public.approval_executions
for each row execute function app_private.reject_approval_execution_identity_change();

create or replace function app_private.capture_work_type_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  actor_id uuid;
  approval_id uuid;
  execution_id uuid;
  change_correlation_id uuid;
  comparison_payload jsonb;
  requested_change jsonb;
  target_snapshot jsonb;
  expected_request jsonb;
  expected_snapshot jsonb;
  expected_comparison_core jsonb;
  new_type_code text;
  apt_allowed boolean;
  siri_allowed boolean;
  approved_decision_exists boolean;
  rejected_decision_exists boolean;
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

  select wt.code, wt.supports_apt, wt.supports_siri
    into strict new_type_code, apt_allowed, siri_allowed
  from public.work_types wt
  where wt.id = new.work_type_id;

  expected_request := jsonb_build_object(
    'newType', new_type_code,
    'newConfigurationVersionId', new.configuration_version_id::text,
    'newInternalStateId', new.internal_state_id::text
  );
  expected_snapshot := jsonb_build_object(
    'workTypeId', old.work_type_id::text,
    'configurationVersionId', old.configuration_version_id::text,
    'internalStateId', old.internal_state_id::text
  );
  expected_comparison_core := jsonb_build_object(
    'previous', expected_snapshot,
    'requested', expected_request
  );

  select ar.requested_change, at.target_snapshot, ae.id
    into requested_change, target_snapshot, execution_id
  from public.approval_requests ar
  join public.approval_targets at on at.id = ar.approval_target_id
  join public.approval_executions ae on ae.approval_request_id = ar.id
  where ar.id = approval_id
    and ar.status = 'executing'
    and ar.action_code = 'work.change_type'
    and ar.project_id = old.project_id
    and ar.work_id = old.id
    and at.owner_module = 'projects'
    and at.target_kind = 'work_type_change'
    and at.scope_kind = 'work'
    and at.target_entity_id = old.id
    and at.target_version = old.version
    and at.project_id = old.project_id
    and at.work_id = old.id
    and ae.project_id = old.project_id
    and ae.work_id = old.id
    and ae.status = 'running'
    and ae.attempt_count > 0
    and ae.started_at is not null
    and ae.finished_at is null
    and ae.correlation_id = change_correlation_id
  for update of ar, ae;

  if not found then
    raise exception using errcode = '23514',
      message = 'El cambio requiere una solicitud ejecutándose y una ejecución vigente para la versión del Trabajo';
  end if;

  select
    exists (
      select 1
      from public.approval_decisions ad
      where ad.approval_request_id = approval_id
        and ad.project_id = old.project_id
        and ad.work_id = old.id
        and ad.decision = 'approved'
        and ad.target_version_reviewed = old.version
    ),
    exists (
      select 1
      from public.approval_decisions ad
      where ad.approval_request_id = approval_id
        and ad.decision = 'rejected'
    )
    into approved_decision_exists, rejected_decision_exists;

  if not approved_decision_exists or rejected_decision_exists then
    raise exception using errcode = '23514',
      message = 'El cambio requiere una decisión aprobatoria vigente y ninguna decisión de rechazo';
  end if;

  if requested_change is distinct from expected_request then
    raise exception using errcode = '23514',
      message = 'El tipo, configuración o estado nuevos no coinciden con el cambio aprobado';
  end if;

  if not (target_snapshot @> expected_snapshot) then
    raise exception using errcode = '23514',
      message = 'La fotografía aprobada no coincide con el tipo, configuración y estado anteriores';
  end if;

  if not (comparison_payload @> expected_comparison_core) then
    raise exception using errcode = '23514',
      message = 'El comparativo no contiene la fotografía anterior y el cambio exacto solicitado';
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
  ) values (
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

  update public.approval_executions
  set status = 'succeeded',
      finished_at = statement_timestamp(),
      result_metadata = result_metadata || jsonb_build_object(
        'workId', old.id::text,
        'newType', new_type_code,
        'workVersionBefore', old.version
      )
  where id = execution_id;

  update public.approval_requests
  set status = 'executed',
      updated_by = actor_id
  where id = approval_id;

  new.updated_by := actor_id;
  new.correlation_id := change_correlation_id;
  return new;
end;
$$;

revoke execute on function app_private.reject_approval_request_payload_change() from public;
revoke execute on function app_private.reject_approval_execution_identity_change() from public;
revoke execute on function app_private.capture_work_type_change() from public;

commit;
