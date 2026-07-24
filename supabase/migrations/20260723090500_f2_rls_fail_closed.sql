-- Fase 2 / 05: postura RLS fail-closed previa a DEC-0103.
-- Habilita y fuerza RLS en toda tabla expuesta, pero no concede permisos ni
-- crea políticas funcionales. Las concesiones se añaden solo tras aprobación.

begin;

do $$
declare
  relation_name name;
begin
  for relation_name in
    select c.relname
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind in ('r', 'p')
    order by c.relname
  loop
    execute format('alter table public.%I enable row level security', relation_name);
    execute format('alter table public.%I force row level security', relation_name);
  end loop;
end;
$$;

revoke all on all tables in schema public from public;
revoke all on all sequences in schema public from public;
alter default privileges in schema public revoke all on tables from public;
alter default privileges in schema public revoke all on sequences from public;

revoke all on schema app_private from public;
revoke all on all functions in schema app_private from public;
alter default privileges in schema app_private revoke execute on functions from public;

do $$
declare
  client_role name;
begin
  foreach client_role in array array['anon'::name, 'authenticated'::name]
  loop
    if exists (select 1 from pg_roles where rolname = client_role) then
      execute format('revoke all on all tables in schema public from %I', client_role);
      execute format('revoke all on all sequences in schema public from %I', client_role);
      execute format('revoke all on schema app_private from %I', client_role);
      execute format('revoke all on all functions in schema app_private from %I', client_role);
      execute format(
        'alter default privileges in schema public revoke all on tables from %I',
        client_role
      );
      execute format(
        'alter default privileges in schema public revoke all on sequences from %I',
        client_role
      );
      execute format(
        'alter default privileges in schema app_private revoke execute on functions from %I',
        client_role
      );
    end if;
  end loop;
end;
$$;

commit;
