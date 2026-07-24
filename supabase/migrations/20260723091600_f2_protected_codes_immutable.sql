-- Fase 2 / 16: códigos físicos usados por contratos, seguridad y
-- configuraciones referenciadas no se reinterpretan mediante UPDATE.

begin;

create or replace function app_private.reject_physical_code_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.code is distinct from old.code then
    raise exception using errcode = '23514',
      message = format('El código físico de %I es invariable', tg_table_name);
  end if;
  return new;
end;
$$;

create trigger trg_roles_code_immutable
before update of code on public.roles
for each row execute function app_private.reject_physical_code_change();

create trigger trg_permissions_code_immutable
before update of code on public.permissions
for each row execute function app_private.reject_physical_code_change();

create trigger trg_catalogs_code_immutable
before update of code on public.catalogs
for each row execute function app_private.reject_physical_code_change();

create trigger trg_specialties_code_immutable
before update of code on public.specialties
for each row execute function app_private.reject_physical_code_change();

create trigger trg_work_state_definitions_code_immutable
before update of code on public.work_state_definitions
for each row execute function app_private.reject_physical_code_change();

revoke execute on function app_private.reject_physical_code_change() from public;

commit;
