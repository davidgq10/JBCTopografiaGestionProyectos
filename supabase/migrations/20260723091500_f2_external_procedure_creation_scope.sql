-- Fase 2 / 15: una alta APT/SIRI, incluso inactiva, solo pertenece a un
-- Trabajo Plano de catastro. La excepción histórica se limita a desactivar una
-- fila existente sin cambiar su proveedor ni su alcance.

begin;

create or replace function app_private.validate_external_procedure_work_type()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  apt_allowed boolean;
  siri_allowed boolean;
begin
  if tg_op = 'UPDATE'
     and not new.is_active
     and not new.monitoring_enabled
     and new.project_id is not distinct from old.project_id
     and new.work_id is not distinct from old.work_id
     and new.provider is not distinct from old.provider then
    return new;
  end if;

  select wt.supports_apt, wt.supports_siri
    into apt_allowed, siri_allowed
  from public.works w
  join public.work_types wt on wt.id = w.work_type_id
  where w.project_id = new.project_id and w.id = new.work_id;

  if new.provider = 'apt' and not coalesce(apt_allowed, false) then
    raise exception using errcode = '23514',
      message = 'APT solo se permite en Trabajo Plano de catastro';
  end if;

  if new.provider = 'siri' and not coalesce(siri_allowed, false) then
    raise exception using errcode = '23514',
      message = 'SIRI solo se permite en Trabajo Plano de catastro';
  end if;

  return new;
end;
$$;

revoke execute on function app_private.validate_external_procedure_work_type() from public;

commit;
