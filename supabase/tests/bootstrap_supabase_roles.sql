-- Solo para PostgreSQL efímero en CI. Supabase real ya proporciona estos roles/helpers.
do $bootstrap$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin noinherit bypassrls;
  end if;
end;
$bootstrap$;

create schema if not exists auth;

create or replace function auth.jwt()
returns jsonb
language sql
stable
as $function$
  select coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb, '{}'::jsonb)
$function$;

create or replace function auth.uid()
returns uuid
language sql
stable
as $function$
  select nullif(auth.jwt() ->> 'sub', '')::uuid
$function$;

grant usage on schema auth to anon, authenticated, service_role;
grant execute on function auth.jwt(), auth.uid() to anon, authenticated, service_role;
