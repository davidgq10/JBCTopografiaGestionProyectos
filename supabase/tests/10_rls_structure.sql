-- Preflight estructural: no depende de DEC-0103 y debe fallar ante cualquier
-- superficie expuesta desconocida o control estructural ausente.

create or replace function pg_temp.assert_no_rows(check_name text, probe_sql text)
returns void
language plpgsql
as $assert$
declare
  first_failure text;
begin
  execute format('select row_to_json(f)::text from (%s) f limit 1', probe_sql)
    into first_failure;

  if first_failure is not null then
    raise exception using
      errcode = 'P0001',
      message = format('RLS-STRUCT FAIL [%s]: %s', check_name, first_failure);
  end if;
end;
$assert$;

select pg_temp.assert_no_rows(
  'superficies esperadas ausentes',
  $probe$
    select m.surface_name, m.surface_kind
    from rls_test_surface_manifest m
    left join pg_class c
      on c.relname = m.surface_name
    left join pg_namespace n
      on n.oid = c.relnamespace and n.nspname = 'public'
    where m.surface_kind <> 'function'
      and (c.oid is null or n.oid is null)
  $probe$
);

select pg_temp.assert_no_rows(
  'relaciones public no inventariadas',
  $probe$
    select c.relname, c.relkind
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    left join rls_test_surface_manifest m
      on m.surface_name = c.relname
     and m.surface_kind = case c.relkind
       when 'v' then 'view'
       when 'm' then 'materialized_view'
       else 'table'
     end
    where n.nspname = 'public'
      and c.relkind in ('r', 'p', 'v', 'm')
      and m.surface_name is null
  $probe$
);

select pg_temp.assert_no_rows(
  'funciones public no inventariadas',
  $probe$
    select p.proname, pg_get_function_identity_arguments(p.oid) as arguments
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    left join rls_test_surface_manifest m
      on m.surface_name = p.proname and m.surface_kind = 'function'
    where n.nspname = 'public'
      and m.surface_name is null
  $probe$
);

select pg_temp.assert_no_rows(
  'tabla sin RLS habilitada y forzada',
  $probe$
    select c.relname, c.relrowsecurity, c.relforcerowsecurity
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    join rls_test_surface_manifest m
      on m.surface_name = c.relname and m.surface_kind = 'table'
    where n.nspname = 'public'
      and c.relkind in ('r', 'p')
      and (not c.relrowsecurity or not c.relforcerowsecurity)
  $probe$
);

select pg_temp.assert_no_rows(
  'política concedida a public/anon/service_role',
  $probe$
    select schemaname, tablename, policyname, roles
    from pg_policies
    where schemaname = 'public'
      and roles && array['public', 'anon', 'service_role']::name[]
  $probe$
);

select pg_temp.assert_no_rows(
  'política DELETE en datos de negocio',
  $probe$
    select p.tablename, p.policyname, p.roles
    from pg_policies p
    join rls_test_surface_manifest m on m.surface_name = p.tablename
    where p.schemaname = 'public'
      and p.cmd = 'DELETE'
      and m.lifecycle <> 'backend_only'
  $probe$
);

select pg_temp.assert_no_rows(
  'política de mutación en tabla append-only',
  $probe$
    select p.tablename, p.policyname, p.cmd
    from pg_policies p
    join rls_test_surface_manifest m on m.surface_name = p.tablename
    where p.schemaname = 'public'
      and m.lifecycle in ('append_only', 'backend_only')
      and p.cmd in ('UPDATE', 'DELETE')
  $probe$
);

select pg_temp.assert_no_rows(
  'tabla append-only sin trigger físico de inmutabilidad',
  $probe$
    select m.surface_name
    from rls_test_surface_manifest m
    where m.surface_kind = 'table'
      and m.lifecycle = 'append_only'
      and not exists (
        select 1
        from pg_trigger t
        join pg_proc p on p.oid = t.tgfoid
        where t.tgrelid = format('public.%I', m.surface_name)::regclass
          and not t.tgisinternal
          and p.proname = 'reject_update_or_delete'
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'tabla archivable sin campo de cierre/archivo',
  $probe$
    select m.surface_name
    from rls_test_surface_manifest m
    where m.surface_kind = 'table'
      and m.lifecycle = 'archivable'
      and not exists (
        select 1
        from pg_attribute a
        where a.attrelid = format('public.%I', m.surface_name)::regclass
          and a.attname in ('archived_at', 'ended_at', 'revoked_at')
          and a.attnum > 0
          and not a.attisdropped
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'tabla archivable sin rechazo físico de DELETE',
  $probe$
    select m.surface_name
    from rls_test_surface_manifest m
    where m.surface_kind = 'table'
      and m.lifecycle = 'archivable'
      and not exists (
        select 1
        from pg_trigger t
        join pg_proc p on p.oid = t.tgfoid
        where t.tgrelid = format('public.%I', m.surface_name)::regclass
          and not t.tgisinternal
          and p.proname in ('reject_delete', 'reject_update_or_delete')
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'vista expuesta sin security_invoker',
  $probe$
    select c.relname, c.reloptions
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind = 'v'
      and not coalesce('security_invoker=true' = any(c.reloptions), false)
  $probe$
);

select pg_temp.assert_no_rows(
  'vista materializada expuesta',
  $probe$
    select c.relname
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind = 'm'
  $probe$
);

select pg_temp.assert_no_rows(
  'función security definer en esquema expuesto',
  $probe$
    select p.proname, pg_get_function_identity_arguments(p.oid) as arguments
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prosecdef
  $probe$
);

select pg_temp.assert_no_rows(
  'SECURITY DEFINER sin propietario NOLOGIN dedicado y no superusuario',
  $probe$
    select p.proname, owner_role.rolname, owner_role.rolcanlogin,
           owner_role.rolsuper, owner_role.rolbypassrls
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    join pg_roles owner_role on owner_role.oid = p.proowner
    where n.nspname = 'app_private'
      and p.prosecdef
      and (
        owner_role.rolname <> 'app_rls_owner'
        or owner_role.rolcanlogin
        or owner_role.rolsuper
        or not owner_role.rolbypassrls
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'función privada no autorizada ejecutable por rol cliente o PUBLIC',
  $probe$
    select p.proname, pg_get_function_identity_arguments(p.oid) as arguments
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'app_private'
      and (
        has_function_privilege('public', p.oid, 'EXECUTE')
        or has_function_privilege('anon', p.oid, 'EXECUTE')
        or (
          has_function_privilege('authenticated', p.oid, 'EXECUTE')
          and (p.proname, pg_get_function_identity_arguments(p.oid)) not in (
            ('current_app_user_id', ''),
            ('has_role', 'p_role_code text'),
            ('is_active_actor', ''),
            ('can_read_user', 'p_user_id uuid'),
            ('can_manage_identity', ''),
            ('can_manage_assignments', ''),
            ('can_read_project', 'p_project_id uuid'),
            ('can_write_project', 'p_project_id uuid')
          )
        )
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'helper RLS autorizado ausente o con definición insegura',
  $probe$
    with expected(proname, arguments) as (values
      ('current_app_user_id', ''),
      ('has_role', 'p_role_code text'),
      ('is_active_actor', ''),
      ('can_read_user', 'p_user_id uuid'),
      ('can_manage_identity', ''),
      ('can_manage_assignments', ''),
      ('can_read_project', 'p_project_id uuid'),
      ('can_write_project', 'p_project_id uuid')
    )
    select e.proname, e.arguments
    from expected e
    left join pg_proc p
      on p.proname = e.proname
     and pg_get_function_identity_arguments(p.oid) = e.arguments
    left join pg_namespace n
      on n.oid = p.pronamespace and n.nspname = 'app_private'
    where p.oid is null
       or n.oid is null
       or not p.prosecdef
       or p.provolatile <> 's'
       or not has_function_privilege('authenticated', p.oid, 'EXECUTE')
       or has_function_privilege('anon', p.oid, 'EXECUTE')
       or has_function_privilege('public', p.oid, 'EXECUTE')
       or not coalesce(p.proconfig @> array[
         'search_path=pg_catalog, public', 'row_security=off'
       ]::text[], false)
  $probe$
);

select pg_temp.assert_no_rows(
  'función public ejecutable por anon',
  $probe$
    select p.proname, pg_get_function_identity_arguments(p.oid) as arguments
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and has_function_privilege('anon', p.oid, 'EXECUTE')
  $probe$
);

select pg_temp.assert_no_rows(
  'tabla public concedida a anon',
  $probe$
    select c.relname
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind in ('r', 'p', 'v', 'm')
      and (
        has_table_privilege('anon', c.oid, 'SELECT')
        or has_table_privilege('anon', c.oid, 'INSERT')
        or has_table_privilege('anon', c.oid, 'UPDATE')
        or has_table_privilege('anon', c.oid, 'DELETE')
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'columna con nombre de secreto en esquema expuesto',
  $probe$
    select c.relname, a.attname
    from pg_attribute a
    join pg_class c on c.oid = a.attrelid
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind in ('r', 'p', 'v', 'm')
      and a.attnum > 0
      and not a.attisdropped
      and lower(a.attname) ~ '(password|passwd|secret|service_role|api_key|private_key|client_secret|refresh_token|access_token|cookie)'
  $probe$
);

select pg_temp.assert_no_rows(
  'binario de Proyecto/Trabajo en base expuesta',
  $probe$
    select c.relname, a.attname, format_type(a.atttypid, a.atttypmod) as data_type
    from pg_attribute a
    join pg_class c on c.oid = a.attrelid
    join pg_namespace n on n.oid = c.relnamespace
    join rls_test_surface_manifest m on m.surface_name = c.relname
    where n.nspname = 'public'
      and m.supported_scopes && array['project', 'work']::text[]
      and a.attnum > 0
      and not a.attisdropped
      and format_type(a.atttypid, a.atttypmod) in ('bytea', 'oid')
  $probe$
);

select pg_temp.assert_no_rows(
  'superficie de Proyecto sin project_id',
  $probe$
    select m.surface_name
    from rls_test_surface_manifest m
    where m.surface_kind = 'table'
      and 'project' = any(m.supported_scopes)
      and m.surface_name <> 'projects'
      and not exists (
        select 1
        from pg_attribute a
        where a.attrelid = format('public.%I', m.surface_name)::regclass
          and a.attname = 'project_id'
          and a.attnum > 0
          and not a.attisdropped
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'superficie de Trabajo sin project_id + work_id',
  $probe$
    select m.surface_name
    from rls_test_surface_manifest m
    where m.surface_kind = 'table'
      and 'work' = any(m.supported_scopes)
      and m.surface_name <> 'works'
      and not (
        exists (
          select 1 from pg_attribute a
          where a.attrelid = format('public.%I', m.surface_name)::regclass
            and a.attname = 'project_id' and a.attnum > 0 and not a.attisdropped
        )
        and exists (
          select 1 from pg_attribute a
          where a.attrelid = format('public.%I', m.surface_name)::regclass
            and a.attname = 'work_id' and a.attnum > 0 and not a.attisdropped
        )
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'superficie de Trabajo sin FK compuesta que preserve project_id + work_id',
  $probe$
    select m.surface_name
    from rls_test_surface_manifest m
    where m.surface_kind = 'table'
      and 'work' = any(m.supported_scopes)
      and m.surface_name <> 'works'
      and not exists (
        select 1
        from pg_constraint con
        where con.contype = 'f'
          and con.conrelid = format('public.%I', m.surface_name)::regclass
          and (
            select array_agg(a.attname order by k.ordinality)
            from unnest(con.conkey) with ordinality k(attnum, ordinality)
            join pg_attribute a on a.attrelid = con.conrelid and a.attnum = k.attnum
            where k.ordinality <= 2
          ) = array['project_id', 'work_id']::name[]
          and (
            (
              con.confrelid = 'public.works'::regclass
              and (
                select array_agg(a.attname order by k.ordinality)
                from unnest(con.confkey) with ordinality k(attnum, ordinality)
                join pg_attribute a on a.attrelid = con.confrelid and a.attnum = k.attnum
                where k.ordinality <= 2
              ) = array['project_id', 'id']::name[]
            )
            or
            (
              con.confrelid <> 'public.works'::regclass
              and (
                select array_agg(a.attname order by k.ordinality)
                from unnest(con.confkey) with ordinality k(attnum, ordinality)
                join pg_attribute a on a.attrelid = con.confrelid and a.attnum = k.attnum
                where k.ordinality <= 2
              ) = array['project_id', 'work_id']::name[]
            )
          )
      )
  $probe$
);

select pg_temp.assert_no_rows(
  'works sin clave única compuesta project_id + id',
  $probe$
    select 'works' as table_name
    where not exists (
      select 1
      from pg_constraint con
      where con.conrelid = 'public.works'::regclass
        and con.contype in ('p', 'u')
        and (
          select array_agg(a.attname order by k.ordinality)
          from unnest(con.conkey) with ordinality k(attnum, ordinality)
          join pg_attribute a on a.attrelid = con.conrelid and a.attnum = k.attnum
        ) = array['project_id', 'id']::name[]
    )
  $probe$
);

select pg_temp.assert_no_rows(
  'app_users.auth_subject no es UUID, NOT NULL y UNIQUE',
  $probe$
    select 'public.app_users.auth_subject' as invalid_column
    where not exists (
      select 1
      from pg_attribute a
      where a.attrelid = 'public.app_users'::regclass
        and a.attname = 'auth_subject'
        and a.attnum > 0
        and not a.attisdropped
        and format_type(a.atttypid, a.atttypmod) = 'uuid'
        and a.attnotnull
        and exists (
          select 1
          from pg_constraint con
          where con.conrelid = a.attrelid
            and con.contype in ('p', 'u')
            and cardinality(con.conkey) = 1
            and con.conkey[1] = a.attnum
        )
    )
  $probe$
);

select 'RLS-STRUCT PASS' as result,
       count(*) filter (where surface_kind = 'table') as inventoried_tables,
       count(*) filter (where surface_kind in ('view', 'materialized_view')) as inventoried_views,
       count(*) filter (where surface_kind = 'function') as inventoried_functions
from rls_test_surface_manifest;
