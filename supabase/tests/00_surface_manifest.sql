-- Inventario canónico de superficies de Fase 2.
-- Se carga en una tabla temporal para que una sola sesión psql pueda ejecutar
-- preflight estructural y, tras aprobar DEC-0103, la matriz funcional.

create temporary table rls_test_surface_manifest (
  surface_name name primary key,
  surface_kind text not null check (surface_kind in ('table', 'view', 'materialized_view', 'function')),
  scope_kind text not null check (scope_kind in ('global', 'project', 'work', 'self', 'backend')),
  supported_scopes text[] not null default array['organization']::text[],
  requires_self_ownership boolean not null default false,
  lifecycle text not null check (lifecycle in ('mutable', 'archivable', 'append_only', 'backend_only')),
  client_read_expected boolean not null,
  notes text not null default ''
) on commit preserve rows;

-- El ejecutor cambia al rol de cliente para probar RLS; sus comprobaciones de
-- postcondición solo necesitan leer este inventario temporal, nunca modificarlo.
grant select on rls_test_surface_manifest to authenticated;

insert into rls_test_surface_manifest
  (surface_name, surface_kind, scope_kind, lifecycle, client_read_expected, notes)
values
  ('app_users', 'table', 'self', 'archivable', true, 'auth_subject enlaza auth.uid(); rol efectivo se resuelve en base'),
  ('roles', 'table', 'global', 'archivable', true, 'catálogo protegido'),
  ('permissions', 'table', 'global', 'archivable', true, 'catálogo protegido'),
  ('user_roles', 'table', 'global', 'archivable', false, 'concesión/revocación versionada; cambio sensible'),
  ('role_permissions', 'table', 'global', 'archivable', false, 'concesión versionada'),
  ('specialties', 'table', 'global', 'archivable', true, 'catálogo'),
  ('user_specialties', 'table', 'self', 'archivable', true, 'asignación de especialidad'),
  ('user_devices', 'table', 'self', 'archivable', true, 'dispositivo propio'),
  ('project_memberships', 'table', 'project', 'archivable', true, 'ancla directa de alcance, nunca por referencia indirecta'),
  ('work_memberships', 'table', 'work', 'archivable', true, 'ancla directa; no amplía a hermanos'),

  ('catalogs', 'table', 'global', 'archivable', true, 'configuración protegida'),
  ('catalog_versions', 'table', 'global', 'mutable', true, 'versión de negocio; sin borrado'),
  ('catalog_values', 'table', 'global', 'archivable', true, 'valor versionado'),
  ('work_types', 'table', 'global', 'archivable', true, 'tipo estable'),
  ('work_type_config_versions', 'table', 'global', 'mutable', true, 'configuración fijada por Trabajo; sin borrado'),
  ('work_state_definitions', 'table', 'global', 'archivable', true, 'estado configurable'),
  ('resources', 'table', 'global', 'archivable', true, 'recurso compartido'),

  ('clients', 'table', 'global', 'archivable', true, 'acceso contextual no se infiere por una referencia'),
  ('client_contacts', 'table', 'global', 'archivable', true, 'hijo de cliente'),
  ('client_addresses', 'table', 'global', 'archivable', true, 'hijo de cliente'),

  ('projects', 'table', 'project', 'archivable', true, 'Contratación'),
  ('works', 'table', 'work', 'archivable', true, 'Trabajo; ancla compuesta project_id + id'),
  ('project_participants', 'table', 'project', 'archivable', true, 'participación en Contratación'),
  ('properties', 'table', 'project', 'archivable', true, 'inmueble/lote de Contratación'),
  ('work_properties', 'table', 'work', 'archivable', true, 'vínculo operativo del Trabajo'),
  ('work_property_values', 'table', 'work', 'mutable', true, 'valor versionado; sin borrado'),
  ('work_type_history', 'table', 'work', 'append_only', true, 'cambio de tipo e historia APT/SIRI'),

  ('managements', 'table', 'work', 'archivable', true, 'Gestión'),
  ('management_notes', 'table', 'work', 'append_only', true, 'nota/version histórica'),
  ('management_wait_periods', 'table', 'work', 'mutable', true, 'solo se completa al reanudar; sin borrado'),

  ('tasks', 'table', 'work', 'archivable', true, 'Tarea'),
  ('task_checklists', 'table', 'work', 'archivable', true, 'lista'),
  ('task_checklist_items', 'table', 'work', 'archivable', true, 'ítem'),
  ('task_dependencies', 'table', 'work', 'archivable', true, 'dependencia no concede alcance'),

  ('schedule_blocks', 'table', 'work', 'archivable', true, 'bloque de ejecución'),
  ('schedule_block_users', 'table', 'work', 'archivable', true, 'asignación de persona'),
  ('schedule_block_resources', 'table', 'work', 'archivable', true, 'asignación de recurso'),

  ('external_procedures', 'table', 'work', 'archivable', true, 'APT/SIRI solo lectura y catastro activo'),
  ('external_status_events', 'table', 'work', 'append_only', true, 'texto original + normalización'),
  ('external_query_runs', 'table', 'work', 'mutable', false, 'escritura backend; lectura de frescura autorizada'),

  ('drive_items', 'table', 'work', 'archivable', true, 'solo metadatos e identificadores OneDrive'),
  ('drive_operations', 'table', 'work', 'mutable', true, 'ciclo de operación versionado; sin borrado'),
  ('drive_delta_cursors', 'table', 'backend', 'backend_only', false, 'cursor técnico por drive; no concede alcance ni se expone a clientes'),

  ('approval_targets', 'table', 'work', 'append_only', true, 'objetivo + versión revalidada'),
  ('approval_requests', 'table', 'work', 'mutable', true, 'solicitud versionada; decisiones separadas'),
  ('approval_decisions', 'table', 'work', 'append_only', true, 'decisión histórica'),
  ('approval_executions', 'table', 'work', 'mutable', true, 'ejecución versionada y a lo sumo una vez'),

  ('notifications', 'table', 'self', 'mutable', true, 'payload mínimo; enlace se reautoriza'),
  ('notification_preferences', 'table', 'self', 'mutable', true, 'preferencia propia'),
  ('push_subscriptions', 'table', 'self', 'archivable', true, 'suscripción propia; material sensible no se proyecta'),

  ('ai_prompt_versions', 'table', 'backend', 'backend_only', false, 'configuración backend versionada; transición de publicación sin acceso cliente'),
  ('ai_runs', 'table', 'work', 'mutable', true, 'ejecución versionada con fecha de corte'),
  ('ai_evidence', 'table', 'work', 'append_only', true, 'solo evidencia autorizada'),
  ('ai_proposals', 'table', 'work', 'mutable', true, 'propuesta versionada; no ejecuta por sí sola'),

  ('audit_events', 'table', 'backend', 'append_only', false, 'escritura backend de solo adición; consulta mediante proyección autorizada futura'),
  ('outbox_events', 'table', 'backend', 'backend_only', false, 'no se expone a clientes'),
  ('idempotent_consumptions', 'table', 'backend', 'append_only', false, 'no se expone a clientes; consumo inmutable');

update rls_test_surface_manifest
set supported_scopes = array[
  case scope_kind
    when 'global' then 'organization'
    else scope_kind
  end
];

update rls_test_surface_manifest
set supported_scopes = array['client', 'project', 'work']
where surface_name in ('drive_items', 'drive_operations');

update rls_test_surface_manifest
set supported_scopes = array['organization', 'project', 'work']
where surface_name in (
  'approval_targets', 'approval_requests', 'approval_decisions', 'approval_executions',
  'notifications', 'ai_runs', 'ai_evidence', 'ai_proposals', 'audit_events', 'outbox_events'
);

update rls_test_surface_manifest
set requires_self_ownership = true
where scope_kind = 'self'
   or surface_name in ('notifications', 'project_memberships', 'work_memberships');

alter table rls_test_surface_manifest
  alter column supported_scopes drop default,
  add constraint rls_test_surface_supported_scopes_ck check (
    cardinality(supported_scopes) > 0
    and supported_scopes <@ array[
      'organization', 'client', 'project', 'work', 'self', 'backend'
    ]::text[]
  );

create temporary table rls_test_subjects (
  auth_subject uuid primary key,
  app_user_id uuid not null unique,
  app_role text not null check (
    app_role in ('administrator', 'coordinator', 'technician', 'read_only')
  ),
  identity_state text not null check (
    identity_state in ('active', 'revoked', 'unauthorized')
  ),
  unique (auth_subject, app_role)
) on commit preserve rows;

create temporary table rls_test_cases (
  case_id text primary key,
  surface_name name not null,
  operation text not null check (operation in ('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'EXECUTE')),
  app_role text not null check (app_role in ('administrator', 'coordinator', 'technician', 'read_only')),
  auth_subject uuid not null,
  scope_variant text not null check (
    scope_variant in ('organization', 'client', 'project', 'work', 'self', 'backend')
  ),
  ownership_case text not null check (
    ownership_case in ('not_applicable', 'self', 'other_user')
  ),
  scope_case text not null check (scope_case in (
    'global', 'assigned_project', 'assigned_work',
    'unassigned', 'sibling_work', 'revoked', 'unauthorized', 'indirect_reference'
  )),
  target_id uuid not null,
  target_client_id uuid,
  target_project_id uuid,
  target_work_id uuid,
  command_sql text not null,
  expected_access boolean not null,
  expected_kind text not null check (expected_kind in ('row_count', 'sqlstate')),
  expected_rows bigint,
  expected_ids uuid[],
  expected_sqlstate text,
  constraint rls_test_cases_surface_fk
    foreign key (surface_name) references rls_test_surface_manifest(surface_name),
  constraint rls_test_cases_subject_fk
    foreign key (auth_subject, app_role)
    references rls_test_subjects(auth_subject, app_role),
  constraint rls_test_cases_expected_result_ck check (
    (expected_kind = 'row_count' and expected_rows is not null and expected_sqlstate is null)
    or
    (expected_kind = 'sqlstate' and expected_rows is null and expected_sqlstate is not null)
  ),
  constraint rls_test_cases_select_identity_ck check (
    operation <> 'SELECT'
    or (
      expected_kind = 'row_count'
      and expected_ids is not null
      and cardinality(expected_ids) = expected_rows
    )
  ),
  constraint rls_test_cases_scope_anchor_ck check (
    (scope_variant in ('organization', 'self', 'backend')
      and target_client_id is null and target_project_id is null and target_work_id is null)
    or (scope_variant = 'client'
      and target_client_id is not null and target_project_id is null and target_work_id is null)
    or (scope_variant = 'project'
      and target_client_id is null and target_project_id is not null and target_work_id is null)
    or (scope_variant = 'work'
      and target_client_id is null and target_project_id is not null and target_work_id is not null)
  ),
  constraint rls_test_cases_scope_case_ck check (
    (scope_case = 'assigned_project' and scope_variant in ('project', 'work'))
    or (scope_case in ('assigned_work', 'sibling_work') and scope_variant = 'work')
    or (scope_case in ('unassigned', 'indirect_reference') and scope_variant in ('project', 'work'))
    or scope_case in ('global', 'revoked', 'unauthorized')
  ),
  constraint rls_test_cases_sqlstate_ck check (
    expected_sqlstate is null or expected_sqlstate in ('42501', '23514')
  )
) on commit preserve rows;

comment on table rls_test_cases is
  'Los fixtures aprobados insertan aquí los casos CRUD por rol/alcance; no usar service_role.';

create or replace function pg_temp.rls_target_exists(
  p_surface name,
  p_target_id uuid
)
returns boolean
language plpgsql
as $target_exists$
declare
  result boolean;
begin
  execute format(
    'select exists (select 1 from public.%I where id = $1)',
    p_surface
  ) into result using p_target_id;
  return result;
end;
$target_exists$;

create or replace function pg_temp.rls_command_is_canonical(
  p_surface name,
  p_operation text,
  p_target_id uuid,
  p_command_sql text
)
returns boolean
language plpgsql
immutable
as $canonical$
declare
  normalized_sql text := regexp_replace(btrim(p_command_sql), '[[:space:]]+', ' ', 'g');
begin
  if normalized_sql ~ ';|--|/\*|\*/'
     or normalized_sql ~* '^(set|reset|grant|revoke|truncate|copy|call|do)\M' then
    return false;
  end if;

  return case p_operation
    when 'SELECT' then lower(normalized_sql) = lower(format(
      'select id from public.%I where id = %L', p_surface, p_target_id
    ))
    when 'INSERT' then normalized_sql ~* format(
      '^insert into public\.%I \([a-z_][a-z0-9_]*(, [a-z_][a-z0-9_]*)*\) values \(.+\)$',
      p_surface
    )
    when 'UPDATE' then
      lower(normalized_sql) = lower(format(
        'update public.%I set id = id where id = %L', p_surface, p_target_id
      ))
      or (
        p_surface = 'app_users'
        and lower(normalized_sql) in (
          lower(format(
            'update public.app_users set preferred_accent = %L where id = %L',
            'azul', p_target_id
          )),
          lower(format(
            'update public.app_users set is_active = false where id = %L',
            p_target_id
          ))
        )
      )
      or (
        p_surface = 'notifications'
        and lower(normalized_sql) in (
          lower(format(
            'update public.notifications set read_at = statement_timestamp() where id = %L',
            p_target_id
          )),
          lower(format(
            'update public.notifications set body = %L where id = %L',
            'Payload alterado', p_target_id
          ))
        )
      )
      or (
        p_surface = 'drive_operations'
        and lower(normalized_sql) in (
          lower(format(
            'update public.drive_operations set status = %L, completed_at = statement_timestamp(), result_metadata = %L::jsonb where id = %L',
            'succeeded', '{"forged":true}', p_target_id
          )),
          lower(format(
            'update public.drive_operations set operation_kind = %L, status = %L, reason = %L where id = %L',
            'trash_empty_folder', 'approved', 'Intento sintético', p_target_id
          ))
        )
      )
    when 'DELETE' then lower(normalized_sql) = lower(format(
      'delete from public.%I where id = %L', p_surface, p_target_id
    ))
    else false
  end;
end;
$canonical$;
