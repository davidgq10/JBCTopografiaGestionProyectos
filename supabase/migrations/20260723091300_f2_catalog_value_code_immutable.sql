-- Fase 2 / 13: RF-014 exige que el código de cada valor sea invariable.

begin;

create or replace function app_private.reject_catalog_value_code_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.code is distinct from old.code then
    raise exception using errcode = '23514',
      message = 'El código de un valor de catálogo es invariable';
  end if;
  return new;
end;
$$;

create trigger trg_catalog_values_code_immutable
before update of code on public.catalog_values
for each row execute function app_private.reject_catalog_value_code_change();

commit;
