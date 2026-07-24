-- Fase 2 / 10: serializar cambios del grafo de tareas y fijar la pertenencia
-- del Trabajo a su Contratación para cerrar carreras de integridad.

begin;

create or replace function app_private.reject_work_project_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.project_id is distinct from old.project_id then
    raise exception using errcode = '23514',
      message = 'Un Trabajo no puede trasladarse a otra Contratación';
  end if;
  return new;
end;
$$;

create trigger trg_works_project_immutable
before update of project_id on public.works
for each row execute function app_private.reject_work_project_change();

create or replace function app_private.reject_task_parent_cycle()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  cycle_found boolean;
begin
  if new.parent_task_id is null then
    return new;
  end if;

  -- Todos los cambios del grafo de un Trabajo bloquean la misma fila estable.
  perform 1
  from public.works w
  where w.project_id = new.project_id and w.id = new.work_id
  for update;

  with recursive ancestors(id, parent_task_id) as (
    select t.id, t.parent_task_id
    from public.tasks t
    where t.project_id = new.project_id
      and t.work_id = new.work_id
      and t.id = new.parent_task_id
    union all
    select t.id, t.parent_task_id
    from public.tasks t
    join ancestors a on a.parent_task_id = t.id
    where t.project_id = new.project_id and t.work_id = new.work_id
  )
  select exists (select 1 from ancestors where id = new.id) into cycle_found;

  if cycle_found then
    raise exception using errcode = '23514',
      message = 'La jerarquía de tareas no puede contener ciclos';
  end if;
  return new;
end;
$$;

create or replace function app_private.reject_task_dependency_cycle()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  cycle_found boolean;
begin
  perform 1
  from public.works w
  where w.project_id = new.project_id and w.id = new.work_id
  for update;

  with recursive reachable(task_id) as (
    select new.successor_task_id
    union
    select td.successor_task_id
    from public.task_dependencies td
    join reachable r on td.predecessor_task_id = r.task_id
    where td.project_id = new.project_id
      and td.work_id = new.work_id
      and td.archived_at is null
      and td.id <> new.id
  )
  select exists (
    select 1 from reachable where task_id = new.predecessor_task_id
  ) into cycle_found;

  if cycle_found then
    raise exception using errcode = '23514',
      message = 'Las dependencias de tareas no pueden contener ciclos';
  end if;
  return new;
end;
$$;

commit;
