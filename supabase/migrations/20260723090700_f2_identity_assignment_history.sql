-- Fase 2 / 07: impedir el borrado físico de asignaciones de identidad.
-- La revocación/archivo conserva la historia y el motivo; DELETE no es una
-- transición válida para estas superficies.

begin;

create trigger trg_user_roles_no_delete
before delete on public.user_roles
for each row execute function app_private.reject_delete();

create trigger trg_role_permissions_no_delete
before delete on public.role_permissions
for each row execute function app_private.reject_delete();

create trigger trg_user_specialties_no_delete
before delete on public.user_specialties
for each row execute function app_private.reject_delete();

commit;
