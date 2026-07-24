-- Fase 2 / 06: preservar historia de asignaciones de agenda.
-- Reemplaza unicidad histórica por unicidad de asignación activa y prohíbe
-- borrar físicamente personas/recursos asignados a un bloque.

begin;

alter table public.schedule_block_users
  add column updated_at timestamptz not null default statement_timestamp(),
  add column updated_by uuid references public.app_users(id) on delete restrict,
  add column version bigint not null default 1 check (version > 0),
  add column ended_at timestamptz,
  add column ended_by uuid references public.app_users(id) on delete restrict,
  add column end_reason text,
  add constraint schedule_block_users_end_complete check (
    (ended_at is null and ended_by is null and end_reason is null)
    or (
      ended_at is not null
      and ended_by is not null
      and nullif(btrim(end_reason), '') is not null
      and ended_at >= created_at
    )
  );

alter table public.schedule_block_users
  drop constraint schedule_block_users_schedule_block_id_user_id_key;

create unique index schedule_block_users_active_uidx
  on public.schedule_block_users (schedule_block_id, user_id)
  where ended_at is null;

create trigger trg_schedule_block_users_touch_version
before update on public.schedule_block_users
for each row execute function app_private.touch_versioned_row();

create trigger trg_schedule_block_users_no_delete
before delete on public.schedule_block_users
for each row execute function app_private.reject_delete();

alter table public.schedule_block_resources
  add column updated_at timestamptz not null default statement_timestamp(),
  add column updated_by uuid references public.app_users(id) on delete restrict,
  add column version bigint not null default 1 check (version > 0),
  add column ended_at timestamptz,
  add column ended_by uuid references public.app_users(id) on delete restrict,
  add column end_reason text,
  add constraint schedule_block_resources_end_complete check (
    (ended_at is null and ended_by is null and end_reason is null)
    or (
      ended_at is not null
      and ended_by is not null
      and nullif(btrim(end_reason), '') is not null
      and ended_at >= created_at
    )
  );

alter table public.schedule_block_resources
  drop constraint schedule_block_resources_schedule_block_id_resource_id_key;

create unique index schedule_block_resources_active_uidx
  on public.schedule_block_resources (schedule_block_id, resource_id)
  where ended_at is null;

create trigger trg_schedule_block_resources_touch_version
before update on public.schedule_block_resources
for each row execute function app_private.touch_versioned_row();

create trigger trg_schedule_block_resources_no_delete
before delete on public.schedule_block_resources
for each row execute function app_private.reject_delete();

commit;
