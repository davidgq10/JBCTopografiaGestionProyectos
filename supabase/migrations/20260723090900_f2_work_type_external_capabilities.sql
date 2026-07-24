-- Fase 2 / 09: APT/SIRI aplican exclusivamente a Plano de catastro.

begin;

alter table public.work_types
  drop constraint work_types_siri_requires_catastro,
  add constraint work_types_external_capabilities_exact check (
    (
      code = 'plano_catastro'
      and supports_apt
      and supports_siri
    )
    or (
      code <> 'plano_catastro'
      and not supports_apt
      and not supports_siri
    )
  );

create or replace function app_private.reject_work_type_capability_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.code is distinct from old.code
     or new.supports_apt is distinct from old.supports_apt
     or new.supports_siri is distinct from old.supports_siri then
    raise exception using errcode = '23514',
      message = 'El código y las capacidades APT/SIRI del tipo de Trabajo son invariantes físicos';
  end if;
  return new;
end;
$$;

create trigger trg_work_types_capabilities_immutable
before update of code, supports_apt, supports_siri
on public.work_types
for each row execute function app_private.reject_work_type_capability_change();

commit;
