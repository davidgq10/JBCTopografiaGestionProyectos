-- Ejecutor funcional parametrizado. Requiere que 30_case_data.sql contenga
-- fixtures sintéticos y casos acordes con DEC-0103 ya aprobada.

do $gate$
begin
  if coalesce(current_setting('rls_test.dec_0103_approved', true), '0') <> '1' then
    raise exception using
      errcode = 'P0001',
      message = 'RLS-MATRIX BLOCKED: DEC-0103 no aprobada; no se ejecutan ni congelan concesiones';
  end if;
end;
$gate$;

select pg_temp.assert_no_rows(
  'casos usan service_role',
  $probe$
    select case_id, command_sql
    from rls_test_cases
    where lower(command_sql) like '%service_role%'
  $probe$
);

select pg_temp.assert_no_rows(
  'SQL de caso no corresponde a la superficie/operación declarada',
  $probe$
    select case_id, surface_name, operation, command_sql
    from rls_test_cases
    where not pg_temp.rls_command_is_canonical(
      surface_name, operation, target_id, command_sql
    )
  $probe$
);

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

create or replace function pg_temp.rls_target_scope_matches(
  p_surface name,
  p_target_id uuid,
  p_scope_variant text,
  p_client_id uuid,
  p_project_id uuid,
  p_work_id uuid
)
returns boolean
language plpgsql
as $scope_matches$
declare
  has_client boolean;
  has_project boolean;
  has_work boolean;
  predicate text := 'id = $1';
  result boolean;
begin
  if p_scope_variant = 'organization' and exists (
    select 1
    from rls_test_surface_manifest m
    where m.surface_name = p_surface
      and m.supported_scopes = array['organization']::text[]
  ) then
    return pg_temp.rls_target_exists(p_surface, p_target_id);
  end if;

  if p_surface = 'projects'::name and p_scope_variant = 'project' then
    return p_target_id = p_project_id
      and exists (select 1 from public.projects where id = p_target_id);
  end if;

  if p_surface = 'works'::name and p_scope_variant = 'work' then
    return p_target_id = p_work_id
      and exists (
        select 1 from public.works
        where id = p_target_id and project_id = p_project_id
      );
  end if;

  select
    bool_or(column_name = 'client_id'),
    bool_or(column_name = 'project_id'),
    bool_or(column_name = 'work_id')
  into has_client, has_project, has_work
  from information_schema.columns
  where table_schema = 'public' and table_name = p_surface::text;

  if p_scope_variant = 'client' then
    if not coalesce(has_client, false) then return false; end if;
    predicate := predicate || ' and client_id = $2';
    if has_project then predicate := predicate || ' and project_id is null'; end if;
    if has_work then predicate := predicate || ' and work_id is null'; end if;
  elsif p_scope_variant = 'project' then
    if not coalesce(has_project, false) then return false; end if;
    predicate := predicate || ' and project_id = $3';
    if has_work then predicate := predicate || ' and work_id is null'; end if;
  elsif p_scope_variant = 'work' then
    if not coalesce(has_project, false) or not coalesce(has_work, false) then
      return false;
    end if;
    predicate := predicate || ' and project_id = $3 and work_id = $4';
  elsif p_scope_variant in ('organization', 'backend') then
    if has_client then predicate := predicate || ' and client_id is null'; end if;
    if has_project then predicate := predicate || ' and project_id is null'; end if;
    if has_work then predicate := predicate || ' and work_id is null'; end if;
  end if;

  execute format('select exists (select 1 from public.%I where %s)', p_surface, predicate)
    into result using p_target_id, p_client_id, p_project_id, p_work_id;
  return result;
end;
$scope_matches$;

create or replace function pg_temp.rls_self_target_matches(
  p_surface name,
  p_target_id uuid,
  p_app_user_id uuid
)
returns boolean
language plpgsql
as $self_matches$
declare
  has_user boolean;
  result boolean;
begin
  if p_surface = 'app_users'::name then
    return p_target_id = p_app_user_id;
  end if;
  select exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = p_surface::text
      and column_name = 'user_id'
  ) into has_user;
  if not has_user then return false; end if;
  execute format(
    'select exists (select 1 from public.%I where id = $1 and user_id = $2)',
    p_surface
  ) into result using p_target_id, p_app_user_id;
  return result;
end;
$self_matches$;

select pg_temp.assert_no_rows(
  'sujeto de caso no coincide con identidad/rol efectivo persistido',
  $probe$
    select c.case_id, c.app_role, s.identity_state
    from rls_test_cases c
    join rls_test_subjects s
      on s.auth_subject = c.auth_subject and s.app_role = c.app_role
    left join public.app_users u
      on u.id = s.app_user_id and u.auth_subject = s.auth_subject
    where u.id is null
       or not exists (
         select 1
         from public.user_roles ur
         join public.roles r on r.id = ur.role_id
         where ur.user_id = s.app_user_id
           and r.code = s.app_role
           and r.archived_at is null
           and ur.revoked_at is null
           and ur.valid_from <= statement_timestamp()
           and (ur.valid_until is null or ur.valid_until > statement_timestamp())
       )
       or case s.identity_state
            when 'active' then not (
              u.is_pre_authorized and u.is_active
              and u.revoked_at is null and u.archived_at is null
            )
            when 'revoked' then not (
              not u.is_active or u.revoked_at is not null or u.archived_at is not null
            )
            when 'unauthorized' then not (
              not u.is_pre_authorized and u.is_active
              and u.revoked_at is null and u.archived_at is null
            )
          end
       or (c.scope_case = 'revoked') <> (s.identity_state = 'revoked')
       or (c.scope_case = 'unauthorized') <> (s.identity_state = 'unauthorized')
  $probe$
);

select pg_temp.assert_no_rows(
  'UUID objetivo no está ligado al SQL o su existencia inicial es incorrecta',
  $probe$
    select c.case_id, c.surface_name, c.operation, c.target_id
    from rls_test_cases c
    join rls_test_subjects s
      on s.auth_subject = c.auth_subject and s.app_role = c.app_role
    where position(lower(c.target_id::text) in lower(c.command_sql)) = 0
       or (c.operation = 'INSERT' and c.target_client_id is not null
         and position(lower(c.target_client_id::text) in lower(c.command_sql)) = 0)
       or (c.operation = 'INSERT' and c.target_project_id is not null
         and position(lower(c.target_project_id::text) in lower(c.command_sql)) = 0)
       or (c.operation = 'INSERT' and c.target_work_id is not null
         and position(lower(c.target_work_id::text) in lower(c.command_sql)) = 0)
       or (c.operation = 'INSERT' and c.ownership_case = 'self'
         and position(lower(s.app_user_id::text) in lower(c.command_sql)) = 0)
       or (
         c.operation = 'INSERT'
         and pg_temp.rls_target_exists(c.surface_name, c.target_id)
       )
       or (
         c.operation <> 'INSERT'
         and not pg_temp.rls_target_exists(c.surface_name, c.target_id)
       )
  $probe$
);

select pg_temp.assert_no_rows(
  'ancla física de alcance no coincide con la fila objetivo',
  $probe$
    select c.case_id, c.surface_name, c.scope_variant, c.target_id
    from rls_test_cases c
    where c.operation <> 'INSERT'
      and not pg_temp.rls_target_scope_matches(
        c.surface_name, c.target_id, c.scope_variant,
        c.target_client_id, c.target_project_id, c.target_work_id
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'caso asignado/no asignado/hermano no coincide con membresías persistidas',
  $probe$
    select c.case_id, c.scope_case, c.target_project_id, c.target_work_id
    from rls_test_cases c
    join rls_test_subjects s
      on s.auth_subject = c.auth_subject and s.app_role = c.app_role
    where case c.scope_case
      when 'assigned_project' then not exists (
        select 1 from public.project_memberships pm
        where pm.user_id = s.app_user_id
          and pm.project_id = c.target_project_id
          and pm.ended_at is null
      )
      when 'assigned_work' then not exists (
        select 1 from public.work_memberships wm
        where wm.user_id = s.app_user_id
          and wm.project_id = c.target_project_id
          and wm.work_id = c.target_work_id
          and wm.ended_at is null
      )
      or exists (
        select 1 from public.project_memberships pm
        where pm.user_id = s.app_user_id
          and pm.project_id = c.target_project_id
          and pm.ended_at is null
      )
      when 'sibling_work' then
        exists (
          select 1 from public.work_memberships wm
          where wm.user_id = s.app_user_id
            and wm.project_id = c.target_project_id
            and wm.work_id = c.target_work_id
            and wm.ended_at is null
        )
        or not exists (
          select 1 from public.work_memberships wm
          where wm.user_id = s.app_user_id
            and wm.project_id = c.target_project_id
            and wm.work_id <> c.target_work_id
            and wm.ended_at is null
        )
        or not exists (
          select 1 from public.project_memberships pm
          where pm.user_id = s.app_user_id
            and pm.project_id = c.target_project_id
            and pm.ended_at is null
        )
      when 'unassigned' then
        exists (
          select 1 from public.project_memberships pm
          where pm.user_id = s.app_user_id
            and pm.project_id = c.target_project_id
            and pm.ended_at is null
        )
        or exists (
          select 1 from public.work_memberships wm
          where wm.user_id = s.app_user_id
            and wm.project_id = c.target_project_id
            and (c.target_work_id is null or wm.work_id = c.target_work_id)
            and wm.ended_at is null
        )
      when 'indirect_reference' then
        exists (
          select 1 from public.project_memberships pm
          where pm.user_id = s.app_user_id
            and pm.project_id = c.target_project_id
            and pm.ended_at is null
        )
        or exists (
          select 1 from public.work_memberships wm
          where wm.user_id = s.app_user_id
            and wm.project_id = c.target_project_id
            and (c.target_work_id is null or wm.work_id = c.target_work_id)
            and wm.ended_at is null
        )
      else false
    end
  $probe$
);

select pg_temp.assert_no_rows(
  'resultado esperado no coincide con acceso/UUID objetivo declarado',
  $probe$
    select case_id, expected_access, expected_kind, expected_rows, expected_ids
    from rls_test_cases
    where (expected_access and expected_kind <> 'row_count')
       or (expected_access and expected_rows <> 1)
       or (not expected_access and expected_kind = 'row_count' and expected_rows <> 0)
       or (
         operation = 'SELECT'
         and expected_access
         and expected_ids <> array[target_id]::uuid[]
       )
       or (
         operation = 'SELECT'
         and not expected_access
         and expected_ids <> array[]::uuid[]
       )
  $probe$
);

select pg_temp.assert_no_rows(
  'SQLSTATE de integridad usado como falso rechazo RLS',
  $probe$
    select c.case_id, c.surface_name, c.operation, c.expected_sqlstate, m.lifecycle
    from rls_test_cases c
    join rls_test_surface_manifest m using (surface_name)
    where c.expected_sqlstate = '23514'
      and (
        c.operation not in ('UPDATE', 'DELETE')
        or m.lifecycle not in ('append_only', 'backend_only')
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'dimensión propietario propio/ajeno mal declarada',
  $probe$
    select c.case_id, c.surface_name, c.ownership_case, m.requires_self_ownership
    from rls_test_cases c
    join rls_test_surface_manifest m using (surface_name)
    where (m.requires_self_ownership and c.ownership_case = 'not_applicable')
       or (not m.requires_self_ownership and c.ownership_case <> 'not_applicable')
  $probe$
);

select pg_temp.assert_no_rows(
  'propietario real de fila no coincide con el caso declarado',
  $probe$
    select c.case_id, c.surface_name, c.ownership_case
    from rls_test_cases c
    join rls_test_subjects s
      on s.auth_subject = c.auth_subject and s.app_role = c.app_role
    where c.operation <> 'INSERT'
      and (
        (c.ownership_case = 'self' and not pg_temp.rls_self_target_matches(
          c.surface_name, c.target_id, s.app_user_id
        ))
        or
        (c.ownership_case = 'other_user' and pg_temp.rls_self_target_matches(
          c.surface_name, c.target_id, s.app_user_id
        ))
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'cobertura CRUD por tabla y cuatro roles incompleta',
  $probe$
    with required as (
      select m.surface_name, r.app_role, o.operation, s.scope_variant, own.ownership_case
      from rls_test_surface_manifest m
      cross join lateral unnest(m.supported_scopes) s(scope_variant)
      cross join lateral (
        select ownership_case
        from unnest(
          case when m.requires_self_ownership
            then array['self', 'other_user']::text[]
            else array['not_applicable']::text[]
          end
        ) ownership_case
      ) own
      cross join (values
        ('administrator'), ('coordinator'), ('technician'), ('read_only')
      ) r(app_role)
      cross join (values
        ('SELECT'), ('INSERT'), ('UPDATE'), ('DELETE')
      ) o(operation)
      where m.surface_kind = 'table'
        and not (
          m.surface_name = 'app_users'
          and o.operation = 'INSERT'
          and own.ownership_case = 'self'
        )
    )
    select required.*
    from required
    left join rls_test_cases c
      on c.surface_name = required.surface_name
     and c.app_role = required.app_role
     and c.operation = required.operation
     and c.scope_variant = required.scope_variant
     and c.ownership_case = required.ownership_case
    where c.case_id is null
  $probe$
);

select pg_temp.assert_no_rows(
  'caso declara una variante de alcance no soportada por su superficie',
  $probe$
    select c.case_id, c.surface_name, c.scope_variant
    from rls_test_cases c
    join rls_test_surface_manifest m using (surface_name)
    where not c.scope_variant = any(m.supported_scopes)
  $probe$
);

select pg_temp.assert_no_rows(
  'Técnico usa etiqueta global para omitir membresía de Proyecto',
  $probe$
    select case_id, app_role, scope_variant, scope_case
    from rls_test_cases
    where app_role = 'technician'
      and scope_variant in ('project', 'work')
      and scope_case = 'global'
  $probe$
);

select pg_temp.assert_no_rows(
  'alcance de Proyecto asignado del Técnico incompleto',
  $probe$
    with scoped as (
      select m.surface_name, r.app_role, o.operation, s.scope_variant, s.scope_case, own.ownership_case
      from rls_test_surface_manifest m
      cross join (values ('technician')) r(app_role)
      cross join (values ('SELECT'), ('INSERT'), ('UPDATE'), ('DELETE')) o(operation)
      cross join lateral (
        select v.scope_variant, v.scope_case
        from (values
          ('project', 'assigned_project'),
          ('work', 'assigned_project')
        ) v(scope_variant, scope_case)
        where v.scope_variant = any(m.supported_scopes)
      ) s
      cross join lateral (
        select ownership_case from unnest(
          case when m.requires_self_ownership
            then array['self', 'other_user']::text[]
            else array['not_applicable']::text[] end
        ) ownership_case
      ) own
      where m.surface_kind = 'table'
        and m.supported_scopes && array['project', 'work']::text[]
        and m.client_read_expected
        and not (m.surface_name = 'projects' and o.operation = 'INSERT')
    )
    select scoped.*
    from scoped
    left join rls_test_cases c
      on c.surface_name = scoped.surface_name
     and c.app_role = scoped.app_role
     and c.operation = scoped.operation
     and c.scope_case = scoped.scope_case
     and c.scope_variant = scoped.scope_variant
     and c.ownership_case = scoped.ownership_case
    where c.case_id is null
  $probe$
);

select pg_temp.assert_no_rows(
  'alcance no asignado del Técnico incompleto',
  $probe$
    with scoped as (
      select m.surface_name, r.app_role, o.operation, s.scope_variant, own.ownership_case
      from rls_test_surface_manifest m
      cross join (values ('technician')) r(app_role)
      cross join (values ('SELECT'), ('INSERT'), ('UPDATE'), ('DELETE')) o(operation)
      cross join lateral unnest(m.supported_scopes) s(scope_variant)
      cross join lateral (
        select ownership_case from unnest(
          case when m.requires_self_ownership
            then array['self', 'other_user']::text[]
            else array['not_applicable']::text[] end
        ) ownership_case
      ) own
      where m.surface_kind = 'table'
        and s.scope_variant in ('project', 'work')
        and m.client_read_expected
    )
    select scoped.*
    from scoped
    left join rls_test_cases c
      on c.surface_name = scoped.surface_name
     and c.app_role = scoped.app_role
     and c.operation = scoped.operation
     and c.scope_case = 'unassigned'
     and c.scope_variant = scoped.scope_variant
     and c.ownership_case = scoped.ownership_case
    where c.case_id is null
  $probe$
);

select pg_temp.assert_no_rows(
  'Trabajo hermano dentro de Proyecto asignado no cubierto',
  $probe$
    with required as (
      select m.surface_name, r.app_role, own.ownership_case
      from rls_test_surface_manifest m
      cross join (values ('technician')) r(app_role)
      cross join lateral (
        select ownership_case from unnest(
          case when m.requires_self_ownership
            then array['self', 'other_user']::text[]
            else array['not_applicable']::text[] end
        ) ownership_case
      ) own
      where m.surface_kind = 'table'
        and 'work' = any(m.supported_scopes)
        and m.client_read_expected
        and m.surface_name <> 'work_memberships'
    )
    select required.*
    from required
    left join rls_test_cases c
      on c.surface_name = required.surface_name
     and c.app_role = required.app_role
     and c.operation = 'SELECT'
     and c.scope_case = 'sibling_work'
     and c.scope_variant = 'work'
     and c.ownership_case = required.ownership_case
    where c.case_id is null
  $probe$
);

select pg_temp.assert_no_rows(
  'alcance global aprobado incompleto',
  $probe$
    with required as (
      select m.surface_name, r.app_role, o.operation, s.scope_variant, own.ownership_case
      from rls_test_surface_manifest m
      cross join (values ('administrator'), ('coordinator'), ('read_only')) r(app_role)
      cross join (values ('SELECT'), ('INSERT'), ('UPDATE'), ('DELETE')) o(operation)
      cross join lateral unnest(m.supported_scopes) s(scope_variant)
      cross join lateral (
        select ownership_case from unnest(
          case when m.requires_self_ownership
            then array['self', 'other_user']::text[]
            else array['not_applicable']::text[] end
        ) ownership_case
      ) own
      where m.surface_kind = 'table'
        and s.scope_variant in ('project', 'work')
        and m.client_read_expected
    )
    select required.*
    from required
    left join rls_test_cases c
      on c.surface_name = required.surface_name
     and c.app_role = required.app_role
     and c.operation = required.operation
     and c.scope_variant = required.scope_variant
     and c.scope_case = 'global'
     and c.ownership_case = required.ownership_case
    where c.case_id is null
  $probe$
);

select pg_temp.assert_no_rows(
  'usuario revocado/no autorizado no cubierto',
  $probe$
    with required as (
      select m.surface_name, r.app_role, s.scope_case, v.scope_variant, own.ownership_case
      from rls_test_surface_manifest m
      cross join (values
        ('administrator'), ('coordinator'), ('technician'), ('read_only')
      ) r(app_role)
      cross join (values ('revoked'), ('unauthorized')) s(scope_case)
      cross join lateral unnest(m.supported_scopes) v(scope_variant)
      cross join lateral (
        select ownership_case from unnest(
          case when m.requires_self_ownership
            then array['self', 'other_user']::text[]
            else array['not_applicable']::text[] end
        ) ownership_case
      ) own
      where m.surface_kind = 'table'
    )
    select required.*
    from required
    left join rls_test_cases c
      on c.surface_name = required.surface_name
     and c.app_role = required.app_role
     and c.operation = 'SELECT'
     and c.scope_case = required.scope_case
     and c.scope_variant = required.scope_variant
     and c.ownership_case = required.ownership_case
    where c.case_id is null
  $probe$
);

select pg_temp.assert_no_rows(
  'append-only sin negativos UPDATE/DELETE por rol',
  $probe$
    with required as (
      select m.surface_name, r.app_role, o.operation
      from rls_test_surface_manifest m
      cross join (values
        ('administrator'), ('coordinator'), ('technician'), ('read_only')
      ) r(app_role)
      cross join (values ('UPDATE'), ('DELETE')) o(operation)
      where m.surface_kind = 'table'
        and m.lifecycle in ('append_only', 'backend_only')
    )
    select required.*
    from required
    left join rls_test_cases c
      on c.surface_name = required.surface_name
     and c.app_role = required.app_role
     and c.operation = required.operation
    where c.case_id is null
  $probe$
);

select pg_temp.assert_no_rows(
  'referencia indirecta sin negativo',
  $probe$
    with required(surface_name) as (
      values
        ('task_dependencies'::name),
        ('notifications'::name),
        ('approval_targets'::name),
        ('drive_items'::name),
        ('ai_evidence'::name)
    )
    select required.surface_name, r.app_role
    from required
    cross join (values ('technician')) r(app_role)
    where not exists (
      select 1
      from rls_test_cases c
      where c.surface_name = required.surface_name
        and c.app_role = r.app_role
        and c.operation = 'SELECT'
        and c.scope_case = 'indirect_reference'
        and c.scope_variant = 'work'
    )
  $probe$
);

create temporary table rls_owner_preflight_results (
  case_id text primary key,
  passed boolean not null,
  actual_sqlstate text,
  actual_rows bigint,
  actual_ids uuid[],
  postcondition_passed boolean
) on commit preserve rows;

create or replace function pg_temp.run_rls_owner_preflight(
  p_case_id text,
  p_app_user_id uuid,
  p_command_sql text,
  p_operation text,
  p_surface name,
  p_target_id uuid,
  p_scope_variant text,
  p_target_client_id uuid,
  p_target_project_id uuid,
  p_target_work_id uuid,
  p_ownership_case text,
  p_lifecycle text
)
returns void
language plpgsql
as $owner_preflight$
declare
  actual_rows bigint;
  actual_ids uuid[];
  actual_state text;
  actual_postcondition boolean;
  is_pass boolean := false;
begin
  begin
    begin
      if p_operation = 'SELECT' then
        execute format(
          'select coalesce(array_agg(q.id order by q.id), array[]::uuid[]) from (%s) q',
          p_command_sql
        ) into actual_ids;
        actual_rows := cardinality(actual_ids);
      else
        execute p_command_sql;
        get diagnostics actual_rows = row_count;
      end if;

      -- La autorización ya fue evaluada como authenticated. La comprobación física
      -- consulta tablas temporales del arnés y debe ejecutarse como propietario.
      execute 'reset role';

      if p_operation in ('INSERT', 'UPDATE') and actual_rows > 0 then
        actual_postcondition :=
          pg_temp.rls_target_exists(p_surface, p_target_id)
          and pg_temp.rls_target_scope_matches(
            p_surface,
            p_target_id,
            p_scope_variant,
            p_target_client_id,
            p_target_project_id,
            p_target_work_id
          )
          and case p_ownership_case
                when 'self' then pg_temp.rls_self_target_matches(
                  p_surface, p_target_id, p_app_user_id
                )
                when 'other_user' then not pg_temp.rls_self_target_matches(
                  p_surface, p_target_id, p_app_user_id
                )
                else true
              end;
      elsif p_operation = 'DELETE' then
        actual_postcondition := not pg_temp.rls_target_exists(p_surface, p_target_id);
      end if;

      -- Revierte siempre la ejecución como propietario; solo conserva el diagnóstico.
      raise exception using errcode = 'P0004', message = 'RLS_OWNER_PREFLIGHT_ROLLBACK';
    exception
      when sqlstate 'P0004' then null;
    end;
  exception when others then
    get stacked diagnostics actual_state = returned_sqlstate;
  end;

  is_pass := coalesce(case p_operation
    when 'SELECT' then actual_state is null
      and actual_rows = 1
      and actual_ids = array[p_target_id]::uuid[]
    when 'INSERT' then actual_state is null
      and actual_rows = 1
      and actual_postcondition
    when 'UPDATE' then
      case when p_lifecycle = 'append_only'
        then actual_state = '23514'
        else actual_state is null and actual_rows = 1 and actual_postcondition
      end
    when 'DELETE' then
      actual_state = '23514'
      or (actual_state is null and actual_rows = 1 and actual_postcondition)
    else false
  end, false);

  insert into rls_owner_preflight_results(
    case_id, passed, actual_sqlstate, actual_rows, actual_ids, postcondition_passed
  ) values (
    p_case_id, is_pass, actual_state, actual_rows, actual_ids, actual_postcondition
  );
end;
$owner_preflight$;

do $execute_owner_preflight$
declare
  test_case rls_test_cases%rowtype;
  test_app_user_id uuid;
  test_lifecycle text;
begin
  for test_case in select * from rls_test_cases order by case_id loop
    select s.app_user_id, m.lifecycle
      into strict test_app_user_id, test_lifecycle
    from rls_test_subjects s
    join rls_test_surface_manifest m on m.surface_name = test_case.surface_name
    where s.auth_subject = test_case.auth_subject
      and s.app_role = test_case.app_role;

    perform pg_temp.run_rls_owner_preflight(
      test_case.case_id,
      test_app_user_id,
      test_case.command_sql,
      test_case.operation,
      test_case.surface_name,
      test_case.target_id,
      test_case.scope_variant,
      test_case.target_client_id,
      test_case.target_project_id,
      test_case.target_work_id,
      test_case.ownership_case,
      test_lifecycle
    );
  end loop;
end;
$execute_owner_preflight$;

select pg_temp.assert_no_rows(
  'comando no demuestra objetivo/datos válidos al ejecutarse como propietario',
  $probe$
    select case_id, actual_sqlstate, actual_rows, actual_ids, postcondition_passed
    from rls_owner_preflight_results
    where not passed
  $probe$
);

create temporary table rls_test_results (
  case_id text primary key,
  passed boolean not null,
  expected text not null,
  actual text not null,
  actual_sqlstate text,
  actual_ids uuid[],
  postcondition_passed boolean,
  executed_at timestamptz not null default clock_timestamp()
) on commit preserve rows;

create or replace function pg_temp.run_rls_case(
  p_case_id text,
  p_auth_subject uuid,
  p_app_user_id uuid,
  p_command_sql text,
  p_expected_kind text,
  p_expected_rows bigint,
  p_expected_ids uuid[],
  p_expected_sqlstate text,
  p_operation text,
  p_surface name,
  p_target_id uuid,
  p_scope_variant text,
  p_target_client_id uuid,
  p_target_project_id uuid,
  p_target_work_id uuid,
  p_ownership_case text
)
returns void
language plpgsql
as $runner$
declare
  actual_rows bigint;
  actual_ids uuid[];
  actual_state text;
  actual_message text;
  actual_postcondition boolean;
  is_pass boolean := false;
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', p_auth_subject::text,
      'role', 'authenticated',
      'aal', 'aal2'
    )::text,
    true
  );

  begin
    execute 'set local role authenticated';
    begin
      if p_operation = 'SELECT' then
        execute format(
          'select coalesce(array_agg(q.id order by q.id), array[]::uuid[]) from (%s) q',
          p_command_sql
        ) into actual_ids;
        actual_rows := cardinality(actual_ids);
      else
        execute p_command_sql;
        get diagnostics actual_rows = row_count;
      end if;

      if p_operation in ('INSERT', 'UPDATE') then
        actual_postcondition :=
          pg_temp.rls_target_exists(p_surface, p_target_id)
          and pg_temp.rls_target_scope_matches(
            p_surface,
            p_target_id,
            p_scope_variant,
            p_target_client_id,
            p_target_project_id,
            p_target_work_id
          )
          and case p_ownership_case
                when 'self' then pg_temp.rls_self_target_matches(
                  p_surface, p_target_id, p_app_user_id
                )
                when 'other_user' then not pg_temp.rls_self_target_matches(
                  p_surface, p_target_id, p_app_user_id
                )
                else true
              end;
      elsif p_operation = 'DELETE' then
        actual_postcondition := not pg_temp.rls_target_exists(p_surface, p_target_id);
      end if;

      -- Cada caso se ejecuta en una subtransacción que siempre se revierte.
      raise exception using errcode = 'P0002', message = 'RLS_TEST_ROLLBACK';
    exception
      when sqlstate 'P0002' then null;
    end;
    execute 'reset role';
  exception when others then
    get stacked diagnostics
      actual_state = returned_sqlstate,
      actual_message = message_text;
    execute 'reset role';
  end;

  if p_expected_kind = 'row_count' then
    is_pass := coalesce(actual_state is null
      and actual_rows = p_expected_rows
      and (p_operation <> 'SELECT' or actual_ids = p_expected_ids)
      and (p_operation = 'SELECT' or p_expected_rows = 0 or actual_postcondition), false);
  elsif p_expected_kind = 'sqlstate' then
    is_pass := coalesce(actual_state = p_expected_sqlstate, false);
  end if;

  insert into rls_test_results(
    case_id, passed, expected, actual, actual_sqlstate, actual_ids, postcondition_passed
  )
  values (
    p_case_id,
    is_pass,
    case p_expected_kind
      when 'row_count' then format(
        'row_count=%s ids=%s postcondition=%s',
        p_expected_rows,
        coalesce(p_expected_ids::text, 'n/a'),
        case when p_operation = 'SELECT' or p_expected_rows = 0 then 'n/a' else 'true' end
      )
      else format('sqlstate=%s', p_expected_sqlstate)
    end,
    case
      when actual_state is null then format(
        'row_count=%s ids=%s postcondition=%s',
        actual_rows,
        coalesce(actual_ids::text, 'n/a'),
        coalesce(actual_postcondition::text, 'n/a')
      )
      else format('error=%s', left(coalesce(actual_message, ''), 240))
    end,
    actual_state,
    actual_ids,
    actual_postcondition
  );
end;
$runner$;

do $execute_cases$
declare
  test_case rls_test_cases%rowtype;
  test_app_user_id uuid;
begin
  for test_case in select * from rls_test_cases order by case_id loop
    select s.app_user_id
      into strict test_app_user_id
    from rls_test_subjects s
    where s.auth_subject = test_case.auth_subject
      and s.app_role = test_case.app_role;

    perform pg_temp.run_rls_case(
      test_case.case_id,
      test_case.auth_subject,
      test_app_user_id,
      test_case.command_sql,
      test_case.expected_kind,
      test_case.expected_rows,
      test_case.expected_ids,
      test_case.expected_sqlstate,
      test_case.operation,
      test_case.surface_name,
      test_case.target_id,
      test_case.scope_variant,
      test_case.target_client_id,
      test_case.target_project_id,
      test_case.target_work_id,
      test_case.ownership_case
    );
  end loop;
end;
$execute_cases$;

select pg_temp.assert_no_rows(
  'resultado funcional distinto de lo esperado',
  $probe$
    select case_id, expected, actual, actual_sqlstate
    from rls_test_results
    where not passed
  $probe$
);

select 'RLS-MATRIX PASS' as result,
       count(*) as executed_cases,
       count(*) filter (where passed) as passed_cases,
       min(executed_at) as started_at_utc,
       max(executed_at) as finished_at_utc
from rls_test_results;
