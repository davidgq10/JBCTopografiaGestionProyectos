-- Fase 2 / 14: las funciones privadas nuevas permanecen fail-closed.

begin;

alter default privileges in schema app_private
  revoke execute on functions from public;

revoke execute on function app_private.reject_work_type_capability_change() from public;
revoke execute on function app_private.reject_work_project_change() from public;
revoke execute on function app_private.reject_task_parent_cycle() from public;
revoke execute on function app_private.reject_task_dependency_cycle() from public;
revoke execute on function app_private.validate_management_note_revision_chain() from public;
revoke execute on function app_private.reject_catalog_value_code_change() from public;

do $roles$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke execute on all functions in schema app_private from anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    revoke execute on all functions in schema app_private from authenticated;
  end if;
end;
$roles$;

commit;
