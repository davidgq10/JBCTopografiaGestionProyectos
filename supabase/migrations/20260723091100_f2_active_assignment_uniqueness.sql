-- Fase 2 / 11: una sola concesión/membresía activa por sujeto y alcance.

begin;

create unique index user_roles_active_uidx
  on public.user_roles (user_id, role_id)
  where revoked_at is null;

create unique index role_permissions_active_uidx
  on public.role_permissions (role_id, permission_id)
  where revoked_at is null;

create unique index user_specialties_active_uidx
  on public.user_specialties (user_id, specialty_id)
  where archived_at is null;

create unique index project_memberships_active_uidx
  on public.project_memberships (project_id, user_id)
  where ended_at is null;

create unique index work_memberships_active_uidx
  on public.work_memberships (project_id, work_id, user_id)
  where ended_at is null;

commit;
