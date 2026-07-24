-- Fase 2 / 12: cada revisión de nota continúa exactamente la revisión
-- anterior de la misma nota lógica y de la misma Gestión.

begin;

create or replace function app_private.validate_management_note_revision_chain()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  previous_logical_note_id uuid;
  previous_revision integer;
begin
  if new.revision = 1 then
    return new;
  end if;

  select n.logical_note_id, n.revision
    into previous_logical_note_id, previous_revision
  from public.management_notes n
  where n.management_id = new.management_id
    and n.id = new.supersedes_note_id;

  if previous_logical_note_id is null
     or previous_logical_note_id is distinct from new.logical_note_id
     or previous_revision <> new.revision - 1 then
    raise exception using errcode = '23514',
      message = 'La revisión debe continuar la nota lógica y revisión inmediatamente anteriores';
  end if;

  return new;
end;
$$;

create trigger trg_management_notes_validate_revision_chain
before insert on public.management_notes
for each row execute function app_private.validate_management_note_revision_chain();

commit;
