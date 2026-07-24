-- Fase 2 / 19: RLS funcional conforme a DEC-0103 aprobada el 2026-07-23.
-- La autorización se resuelve desde identidad/roles/membresías persistidos.
-- Nunca se confía en roles o alcances declarados por el cliente.

begin;

insert into public.roles (id, code, name, description, is_system)
values
  ('10000000-0000-4000-8000-000000000001', 'administrator', 'Administrador', 'Administra usuarios, roles, configuración y operación.', true),
  ('10000000-0000-4000-8000-000000000002', 'coordinator', 'Coordinador', 'Administra operación y asignaciones; no usuarios ni roles.', true),
  ('10000000-0000-4000-8000-000000000003', 'technician', 'Técnico', 'Opera únicamente en Proyectos asignados directamente.', true),
  ('10000000-0000-4000-8000-000000000004', 'read_only', 'Solo lectura', 'Consulta global sin escrituras de negocio.', true)
on conflict (code) do nothing;

-- Una operación OneDrive conserva su alcance de forma directa. No se autoriza
-- derivarlo desde drive_item_id porque una referencia nunca concede acceso.
alter table public.drive_operations
  add column scope_kind text,
  add column client_id uuid references public.clients(id) on delete restrict;

update public.drive_operations operation
set
  scope_kind = case item.scope_kind
    when 'project_root' then 'project'
    else item.scope_kind
  end,
  client_id = item.client_id,
  project_id = item.project_id,
  work_id = item.work_id
from public.drive_items item
where item.id = operation.drive_item_id;

alter table public.drive_operations
  alter column scope_kind set not null,
  drop constraint drive_operations_work_pair,
  add constraint drive_operations_scope_kind_ck check (
    scope_kind in ('client', 'project', 'work')
  ),
  add constraint drive_operations_scope_ck check (
    (scope_kind = 'client' and client_id is not null and project_id is null and work_id is null)
    or (scope_kind = 'project' and client_id is null and project_id is not null and work_id is null)
    or (scope_kind = 'work' and client_id is null and project_id is not null and work_id is not null)
  );

create or replace function app_private.validate_drive_operation_scope()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
declare
  item_scope_kind text;
  item_client_id uuid;
  item_project_id uuid;
  item_work_id uuid;
begin
  select
    case scope_kind when 'project_root' then 'project' else scope_kind end,
    client_id,
    project_id,
    work_id
  into strict item_scope_kind, item_client_id, item_project_id, item_work_id
  from public.drive_items
  where id = new.drive_item_id;

  if new.scope_kind is distinct from item_scope_kind
     or new.client_id is distinct from item_client_id
     or new.project_id is distinct from item_project_id
     or new.work_id is distinct from item_work_id then
    raise exception using
      errcode = '23514',
      message = 'La operación OneDrive debe conservar scope_kind y anclas directas del elemento';
  end if;
  return new;
end;
$function$;

revoke all on function app_private.validate_drive_operation_scope() from public;

-- Los disparadores de integridad deben observar la fila padre real aun cuando el
-- actor no pueda leerla. Solo ejecutan SQL fijo interno; no son APIs cliente.
alter function app_private.assert_project_has_work() security definer;
alter function app_private.assert_project_has_work() set row_security = off;
alter function app_private.capture_work_type_change() security definer;
alter function app_private.capture_work_type_change() set row_security = off;
alter function app_private.reject_task_dependency_cycle() security definer;
alter function app_private.reject_task_dependency_cycle() set row_security = off;
alter function app_private.reject_task_parent_cycle() security definer;
alter function app_private.reject_task_parent_cycle() set row_security = off;
alter function app_private.validate_ai_scope() security definer;
alter function app_private.validate_ai_scope() set row_security = off;
alter function app_private.validate_approval_scope() security definer;
alter function app_private.validate_approval_scope() set row_security = off;
alter function app_private.validate_external_procedure_work_type() security definer;
alter function app_private.validate_external_procedure_work_type() set row_security = off;
alter function app_private.validate_management_note_revision_chain() security definer;
alter function app_private.validate_management_note_revision_chain() set row_security = off;

revoke all on function app_private.assert_project_has_work() from public;
revoke all on function app_private.capture_work_type_change() from public;
revoke all on function app_private.reject_task_dependency_cycle() from public;
revoke all on function app_private.reject_task_parent_cycle() from public;
revoke all on function app_private.validate_ai_scope() from public;
revoke all on function app_private.validate_approval_scope() from public;
revoke all on function app_private.validate_external_procedure_work_type() from public;
revoke all on function app_private.validate_management_note_revision_chain() from public;

drop trigger trg_drive_operations_validate_scope on public.drive_operations;
create trigger trg_drive_operations_validate_scope
before insert or update of drive_item_id, scope_kind, client_id, project_id, work_id
on public.drive_operations
for each row execute function app_private.validate_drive_operation_scope();

create or replace function app_private.current_app_user_id()
returns uuid
language sql
stable
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
  select u.id
  from public.app_users u
  where u.auth_subject = (
    nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub'
  )::uuid
    and u.is_pre_authorized
    and u.is_active
    and u.revoked_at is null
    and u.archived_at is null
  limit 1
$function$;

create or replace function app_private.has_role(p_role_code text)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
  select exists (
    select 1
    from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = app_private.current_app_user_id()
      and r.code = p_role_code
      and r.archived_at is null
      and ur.revoked_at is null
      and ur.valid_from <= statement_timestamp()
      and (ur.valid_until is null or ur.valid_until > statement_timestamp())
  )
$function$;

create or replace function app_private.is_active_actor()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
  select app_private.current_app_user_id() is not null
    and exists (
      select 1
      from public.user_roles ur
      join public.roles r on r.id = ur.role_id
      where ur.user_id = app_private.current_app_user_id()
        and r.code in ('administrator', 'coordinator', 'technician', 'read_only')
        and r.archived_at is null
        and ur.revoked_at is null
        and ur.valid_from <= statement_timestamp()
        and (ur.valid_until is null or ur.valid_until > statement_timestamp())
    )
$function$;

create or replace function app_private.can_read_user(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
  select app_private.is_active_actor()
    and (
      p_user_id = app_private.current_app_user_id()
      or app_private.has_role('administrator')
      or app_private.has_role('coordinator')
    )
$function$;

create or replace function app_private.can_manage_identity()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
  select app_private.has_role('administrator')
$function$;

create or replace function app_private.can_manage_assignments()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
  select app_private.has_role('administrator')
      or app_private.has_role('coordinator')
$function$;

create or replace function app_private.can_read_project(p_project_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
  select p_project_id is not null
    and app_private.is_active_actor()
    and (
      app_private.has_role('administrator')
      or app_private.has_role('coordinator')
      or app_private.has_role('read_only')
      or (
        app_private.has_role('technician')
        and exists (
          select 1
          from public.project_memberships pm
          where pm.user_id = app_private.current_app_user_id()
            and pm.project_id = p_project_id
            and pm.ended_at is null
        )
      )
    )
$function$;

create or replace function app_private.can_write_project(p_project_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
set row_security = off
as $function$
  select p_project_id is not null
    and app_private.is_active_actor()
    and (
      app_private.has_role('administrator')
      or app_private.has_role('coordinator')
      or (
        app_private.has_role('technician')
        and exists (
          select 1
          from public.project_memberships pm
          where pm.user_id = app_private.current_app_user_id()
            and pm.project_id = p_project_id
            and pm.ended_at is null
        )
      )
    )
$function$;

revoke all on function app_private.current_app_user_id() from public;
revoke all on function app_private.has_role(text) from public;
revoke all on function app_private.is_active_actor() from public;
revoke all on function app_private.can_read_user(uuid) from public;
revoke all on function app_private.can_manage_identity() from public;
revoke all on function app_private.can_manage_assignments() from public;
revoke all on function app_private.can_read_project(uuid) from public;
revoke all on function app_private.can_write_project(uuid) from public;

do $roles$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant usage on schema app_private to authenticated;
    grant execute on function app_private.current_app_user_id() to authenticated;
    grant execute on function app_private.has_role(text) to authenticated;
    grant execute on function app_private.is_active_actor() to authenticated;
    grant execute on function app_private.can_read_user(uuid) to authenticated;
    grant execute on function app_private.can_manage_identity() to authenticated;
    grant execute on function app_private.can_manage_assignments() to authenticated;
    grant execute on function app_private.can_read_project(uuid) to authenticated;
    grant execute on function app_private.can_write_project(uuid) to authenticated;
    grant select, insert, update on all tables in schema public to authenticated;
  end if;
end;
$roles$;

-- Catálogos visibles a toda identidad activa.
do $catalog_policies$
declare
  table_name name;
begin
  foreach table_name in array array[
    'roles', 'permissions', 'specialties', 'catalogs', 'catalog_versions',
    'catalog_values', 'work_types', 'work_type_config_versions',
    'work_state_definitions', 'resources'
  ]::name[] loop
    execute format(
      'create policy %I on public.%I for select to authenticated using (app_private.is_active_actor())',
      'rls_' || table_name || '_select_active', table_name
    );
  end loop;

  foreach table_name in array array[
    'roles', 'permissions', 'specialties', 'catalogs', 'catalog_versions',
    'catalog_values', 'work_types', 'work_type_config_versions',
    'work_state_definitions'
  ]::name[] loop
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (app_private.can_manage_identity())',
      'rls_' || table_name || '_insert_admin', table_name
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using (app_private.can_manage_identity()) with check (app_private.can_manage_identity())',
      'rls_' || table_name || '_update_admin', table_name
    );
  end loop;

  create policy rls_resources_insert_operation
    on public.resources for insert to authenticated
    with check (app_private.can_manage_assignments());
  create policy rls_resources_update_operation
    on public.resources for update to authenticated
    using (app_private.can_manage_assignments())
    with check (app_private.can_manage_assignments());
end;
$catalog_policies$;

-- Identidad, especialidades, dispositivos y asignaciones.
create policy rls_app_users_select_authorized
  on public.app_users for select to authenticated
  using (app_private.can_read_user(id));
create policy rls_app_users_insert_admin
  on public.app_users for insert to authenticated
  with check (app_private.can_manage_identity());
create policy rls_app_users_update_admin
  on public.app_users for update to authenticated
  using (app_private.can_manage_identity())
  with check (app_private.can_manage_identity());
create policy rls_app_users_update_self_accent
  on public.app_users for update to authenticated
  using (
    app_private.is_active_actor()
    and id = app_private.current_app_user_id()
  )
  with check (
    app_private.is_active_actor()
    and id = app_private.current_app_user_id()
  );

create policy rls_user_roles_select_admin
  on public.user_roles for select to authenticated
  using (app_private.can_manage_identity());
create policy rls_user_roles_insert_admin
  on public.user_roles for insert to authenticated
  with check (app_private.can_manage_identity());
create policy rls_user_roles_update_admin
  on public.user_roles for update to authenticated
  using (app_private.can_manage_identity())
  with check (app_private.can_manage_identity());

create policy rls_role_permissions_select_admin
  on public.role_permissions for select to authenticated
  using (app_private.can_manage_identity());
create policy rls_role_permissions_insert_admin
  on public.role_permissions for insert to authenticated
  with check (app_private.can_manage_identity());
create policy rls_role_permissions_update_admin
  on public.role_permissions for update to authenticated
  using (app_private.can_manage_identity())
  with check (app_private.can_manage_identity());

create policy rls_user_specialties_select_authorized
  on public.user_specialties for select to authenticated
  using (
    app_private.can_manage_identity()
    or app_private.has_role('coordinator')
    or user_id = app_private.current_app_user_id()
  );
create policy rls_user_specialties_insert_admin
  on public.user_specialties for insert to authenticated
  with check (app_private.can_manage_identity());
create policy rls_user_specialties_update_admin
  on public.user_specialties for update to authenticated
  using (app_private.can_manage_identity())
  with check (app_private.can_manage_identity());

create policy rls_user_devices_select_self
  on public.user_devices for select to authenticated
  using (app_private.is_active_actor() and user_id = app_private.current_app_user_id());
create policy rls_user_devices_insert_self
  on public.user_devices for insert to authenticated
  with check (app_private.is_active_actor() and user_id = app_private.current_app_user_id());
create policy rls_user_devices_update_self
  on public.user_devices for update to authenticated
  using (app_private.is_active_actor() and user_id = app_private.current_app_user_id())
  with check (app_private.is_active_actor() and user_id = app_private.current_app_user_id());

do $membership_policies$
declare
  table_name name;
begin
  foreach table_name in array array['project_memberships', 'work_memberships']::name[] loop
    execute format(
      'create policy %I on public.%I for select to authenticated using (app_private.can_manage_assignments() or (app_private.is_active_actor() and user_id = app_private.current_app_user_id()))',
      'rls_' || table_name || '_select_authorized', table_name
    );
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (app_private.can_manage_assignments())',
      'rls_' || table_name || '_insert_management', table_name
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using (app_private.can_manage_assignments()) with check (app_private.can_manage_assignments())',
      'rls_' || table_name || '_update_management', table_name
    );
  end loop;
end;
$membership_policies$;

-- Clientes: Administrador y Coordinador únicamente.
do $client_policies$
declare
  table_name name;
begin
  foreach table_name in array array['clients', 'client_contacts', 'client_addresses']::name[] loop
    execute format(
      'create policy %I on public.%I for select to authenticated using (app_private.can_manage_assignments())',
      'rls_' || table_name || '_select_management', table_name
    );
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (app_private.can_manage_assignments())',
      'rls_' || table_name || '_insert_management', table_name
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using (app_private.can_manage_assignments()) with check (app_private.can_manage_assignments())',
      'rls_' || table_name || '_update_management', table_name
    );
  end loop;
end;
$client_policies$;

-- Proyecto y Trabajo.
create policy rls_projects_select_scope
  on public.projects for select to authenticated
  using (app_private.can_read_project(id));
create policy rls_projects_insert_management
  on public.projects for insert to authenticated
  with check (app_private.can_manage_assignments());
create policy rls_projects_update_management
  on public.projects for update to authenticated
  using (app_private.can_manage_assignments())
  with check (app_private.can_manage_assignments());

create policy rls_works_select_scope
  on public.works for select to authenticated
  using (app_private.can_read_project(project_id));
create policy rls_works_insert_management
  on public.works for insert to authenticated
  with check (app_private.can_manage_assignments());
create policy rls_works_update_operation
  on public.works for update to authenticated
  using (app_private.can_write_project(project_id))
  with check (app_private.can_write_project(project_id));

-- Datos operativos mutables dentro de un Proyecto.
do $operational_policies$
declare
  table_name name;
begin
  foreach table_name in array array[
    'project_participants', 'properties', 'work_properties', 'work_property_values',
    'managements', 'management_wait_periods', 'tasks', 'task_checklists',
    'task_checklist_items', 'task_dependencies', 'schedule_blocks',
    'schedule_block_users', 'schedule_block_resources'
  ]::name[] loop
    execute format(
      'create policy %I on public.%I for select to authenticated using (app_private.can_read_project(project_id))',
      'rls_' || table_name || '_select_scope', table_name
    );
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (app_private.can_write_project(project_id))',
      'rls_' || table_name || '_insert_operation', table_name
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using (app_private.can_write_project(project_id)) with check (app_private.can_write_project(project_id))',
      'rls_' || table_name || '_update_operation', table_name
    );
  end loop;
end;
$operational_policies$;

create policy rls_management_notes_select_scope
  on public.management_notes for select to authenticated
  using (app_private.can_read_project(project_id));
create policy rls_management_notes_insert_operation
  on public.management_notes for insert to authenticated
  with check (app_private.can_write_project(project_id));

create policy rls_work_type_history_select_scope
  on public.work_type_history for select to authenticated
  using (app_private.can_read_project(project_id));
create policy rls_work_type_history_insert_operation
  on public.work_type_history for insert to authenticated
  with check (app_private.can_write_project(project_id));

-- APT/SIRI: lectura cliente, escritura exclusivamente backend.
create policy rls_external_procedures_select_scope
  on public.external_procedures for select to authenticated
  using (app_private.can_read_project(project_id));
create policy rls_external_status_events_select_scope
  on public.external_status_events for select to authenticated
  using (app_private.can_read_project(project_id));

-- OneDrive: solo metadatos; Cliente aislado no se deriva desde Proyecto.
create policy rls_drive_items_select_scope
  on public.drive_items for select to authenticated
  using (
    case scope_kind
      when 'client' then app_private.can_manage_assignments()
      else app_private.can_read_project(project_id)
    end
  );
create policy rls_drive_items_insert_operation
  on public.drive_items for insert to authenticated
  with check (
    case scope_kind
      when 'client' then app_private.can_manage_assignments()
      else app_private.can_write_project(project_id)
    end
  );
create policy rls_drive_items_update_operation
  on public.drive_items for update to authenticated
  using (
    case scope_kind
      when 'client' then app_private.can_manage_assignments()
      else app_private.can_write_project(project_id)
    end
  )
  with check (
    case scope_kind
      when 'client' then app_private.can_manage_assignments()
      else app_private.can_write_project(project_id)
    end
  );

create policy rls_drive_operations_select_scope
  on public.drive_operations for select to authenticated
  using (
    case scope_kind
      when 'client' then app_private.can_manage_assignments()
      else app_private.can_read_project(project_id)
    end
  );
create policy rls_drive_operations_insert_operation
  on public.drive_operations for insert to authenticated
  with check (
    requested_by = app_private.current_app_user_id()
    and status = 'requested'
    and operation_kind <> 'delta_observed'
    and completed_at is null
    and result_metadata = '{}'::jsonb
    and version = 1
    and (
      case scope_kind
        when 'client' then app_private.can_manage_assignments()
        else app_private.can_write_project(project_id)
      end
    )
  );

-- Aprobaciones: solicitar no concede decidir ni ejecutar.
create policy rls_approval_targets_select_scope
  on public.approval_targets for select to authenticated
  using (
    (scope_kind = 'organization' and app_private.can_manage_assignments())
    or (scope_kind <> 'organization' and app_private.can_read_project(project_id))
  );
create policy rls_approval_targets_insert_scope
  on public.approval_targets for insert to authenticated
  with check (
    registered_by = app_private.current_app_user_id()
    and (
      (scope_kind = 'organization' and app_private.can_manage_assignments())
      or (scope_kind <> 'organization' and app_private.can_write_project(project_id))
    )
  );

create policy rls_approval_requests_select_scope
  on public.approval_requests for select to authenticated
  using (
    (project_id is null and app_private.can_manage_assignments())
    or (project_id is not null and app_private.can_read_project(project_id))
  );
create policy rls_approval_requests_insert_scope
  on public.approval_requests for insert to authenticated
  with check (
    requested_by = app_private.current_app_user_id()
    and (
      (project_id is null and app_private.can_manage_assignments())
      or (project_id is not null and app_private.can_write_project(project_id))
    )
  );

create policy rls_approval_decisions_select_scope
  on public.approval_decisions for select to authenticated
  using (
    (project_id is null and app_private.can_manage_assignments())
    or (project_id is not null and app_private.can_read_project(project_id))
  );
create policy rls_approval_decisions_insert_management
  on public.approval_decisions for insert to authenticated
  with check (
    app_private.can_manage_assignments()
    and decided_by = app_private.current_app_user_id()
    and exists (
      select 1
      from public.approval_requests request_row
      where request_row.id = approval_request_id
        and request_row.requested_by <> app_private.current_app_user_id()
    )
  );

create policy rls_approval_executions_select_scope
  on public.approval_executions for select to authenticated
  using (
    (project_id is null and app_private.can_manage_assignments())
    or (project_id is not null and app_private.can_read_project(project_id))
  );

-- Notificaciones y preferencias propias.
create policy rls_notifications_select_self_scope
  on public.notifications for select to authenticated
  using (
    app_private.is_active_actor()
    and user_id = app_private.current_app_user_id()
    and (project_id is null or app_private.can_read_project(project_id))
  );
create policy rls_notifications_update_self_read
  on public.notifications for update to authenticated
  using (
    app_private.is_active_actor()
    and user_id = app_private.current_app_user_id()
    and (project_id is null or app_private.can_read_project(project_id))
  )
  with check (
    app_private.is_active_actor()
    and user_id = app_private.current_app_user_id()
    and (project_id is null or app_private.can_read_project(project_id))
  );

create policy rls_notification_preferences_select_self
  on public.notification_preferences for select to authenticated
  using (app_private.is_active_actor() and user_id = app_private.current_app_user_id());
create policy rls_notification_preferences_insert_self
  on public.notification_preferences for insert to authenticated
  with check (app_private.is_active_actor() and user_id = app_private.current_app_user_id());
create policy rls_notification_preferences_update_self
  on public.notification_preferences for update to authenticated
  using (app_private.is_active_actor() and user_id = app_private.current_app_user_id())
  with check (app_private.is_active_actor() and user_id = app_private.current_app_user_id());

create policy rls_push_subscriptions_select_self
  on public.push_subscriptions for select to authenticated
  using (app_private.is_active_actor() and user_id = app_private.current_app_user_id());
create policy rls_push_subscriptions_insert_self
  on public.push_subscriptions for insert to authenticated
  with check (app_private.is_active_actor() and user_id = app_private.current_app_user_id());
create policy rls_push_subscriptions_update_self
  on public.push_subscriptions for update to authenticated
  using (app_private.is_active_actor() and user_id = app_private.current_app_user_id())
  with check (app_private.is_active_actor() and user_id = app_private.current_app_user_id());

-- IA: lectura reautorizada; generación/escritura continúa en backend.
do $ai_read_policies$
declare
  table_name name;
begin
  foreach table_name in array array['ai_runs', 'ai_evidence', 'ai_proposals']::name[] loop
    execute format(
      'create policy %I on public.%I for select to authenticated using ((project_id is null and app_private.can_manage_assignments()) or (project_id is not null and app_private.can_read_project(project_id)))',
      'rls_' || table_name || '_select_scope', table_name
    );
  end loop;
end;
$ai_read_policies$;

-- Auditoría es append-only y solo visible al Administrador en este corte.
create policy rls_audit_events_select_admin
  on public.audit_events for select to authenticated
  using (app_private.can_manage_identity());

-- Las dos actualizaciones propias expuestas se limitan físicamente a los
-- campos de UX declarados. El actor no puede alterar identidad, autorización,
-- alcance ni payload; los metadatos de versión se derivan en el servidor.
create or replace function app_private.restrict_app_user_self_update()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $function$
begin
  if current_user <> 'authenticated' or app_private.has_role('administrator') then
    return new;
  end if;

  if old.id <> app_private.current_app_user_id()
     or (to_jsonb(new) - array['preferred_accent','updated_at','updated_by','version'])
        is distinct from
        (to_jsonb(old) - array['preferred_accent','updated_at','updated_by','version']) then
    raise exception using
      errcode = '42501',
      message = 'La actualización propia solo permite cambiar el acento preferido';
  end if;

  new.updated_at := statement_timestamp();
  new.updated_by := app_private.current_app_user_id();
  new.version := old.version + 1;
  return new;
end;
$function$;

create or replace function app_private.restrict_notification_self_update()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $function$
begin
  if current_user <> 'authenticated' then
    return new;
  end if;

  if old.user_id <> app_private.current_app_user_id()
     or (to_jsonb(new) - array['read_at','updated_at','version'])
        is distinct from
        (to_jsonb(old) - array['read_at','updated_at','version']) then
    raise exception using
      errcode = '42501',
      message = 'La actualización propia de una notificación solo permite cambiar su estado de lectura';
  end if;

  new.updated_at := statement_timestamp();
  new.version := old.version + 1;
  return new;
end;
$function$;

revoke all on function app_private.restrict_app_user_self_update() from public;
revoke all on function app_private.restrict_notification_self_update() from public;

create trigger trg_app_users_restrict_self_update
before update on public.app_users
for each row execute function app_private.restrict_app_user_self_update();

create trigger trg_notifications_restrict_self_update
before update on public.notifications
for each row execute function app_private.restrict_notification_self_update();

-- Propietario dedicado de funciones privilegiadas. BYPASSRLS es necesario para
-- que los helpers SECURITY DEFINER evalúen la fila real; NOLOGIN y la ausencia
-- de superusuario reducen el privilegio frente al propietario postgres.
do $owner_role$
begin
  if not exists (select 1 from pg_roles where rolname = 'app_rls_owner') then
    create role app_rls_owner
      nologin nosuperuser nocreatedb nocreaterole noinherit noreplication bypassrls;
  end if;
end;
$owner_role$;

grant usage on schema public, app_private to app_rls_owner;
grant select on public.app_users, public.user_roles, public.roles,
  public.project_memberships, public.projects, public.works, public.tasks,
  public.task_dependencies, public.ai_runs, public.approval_targets,
  public.approval_requests, public.drive_items, public.work_types,
  public.management_notes, public.approval_executions,
  public.approval_decisions, public.external_procedures
to app_rls_owner;
grant insert on public.work_type_history to app_rls_owner;
grant update on public.external_procedures, public.approval_executions,
  public.approval_requests, public.works
to app_rls_owner;

do $security_definer_owner$
declare
  function_row record;
begin
  for function_row in
    select p.oid::regprocedure as function_signature
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'app_private'
      and p.prosecdef
  loop
    execute format(
      'alter function %s owner to app_rls_owner',
      function_row.function_signature
    );
  end loop;
end;
$security_definer_owner$;

commit;
