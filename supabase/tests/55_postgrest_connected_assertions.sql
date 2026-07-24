\set ON_ERROR_STOP on
\pset pager off

do $connected$
declare
  audit_count integer;
  other_version bigint;
  stored_accent text;
  stored_theme text;
  stored_version bigint;
begin
  select preferred_accent, preferred_theme, version
    into stored_accent, stored_theme, stored_version
  from public.app_users
  where id = 'a1000000-0000-4000-8000-000000000003';

  if stored_accent <> 'azul' or stored_theme <> 'dark' or stored_version <> 2 then
    raise exception 'CONNECTED-E2E FAIL: la mutación visible no quedó persistida';
  end if;

  select version into other_version
  from public.app_users
  where id = 'a1000000-0000-4000-8000-000000000002';
  if other_version <> 1 then
    raise exception 'CONNECTED-E2E FAIL: el perfil ajeno fue modificado';
  end if;

  select count(*) into audit_count
  from public.audit_events
  where entity_id = 'a1000000-0000-4000-8000-000000000003'
    and actor_user_id = 'a1000000-0000-4000-8000-000000000003'
    and actor_role_code = 'technician'
    and action_code = 'profile.appearance_updated'
    and result_code = 'accepted'
    and old_values @> '{"preferredAccent":"teal","preferredTheme":"auto","version":1}'::jsonb
    and new_values @> '{"preferredAccent":"azul","preferredTheme":"dark","version":2}'::jsonb;

  if audit_count <> 1 then
    raise exception 'CONNECTED-E2E FAIL: falta el evento de auditoría correlacionado';
  end if;
end;
$connected$;

\echo 'CONNECTED-E2E PASS | UI -> PostgREST -> RLS -> PostgreSQL -> auditoría'
