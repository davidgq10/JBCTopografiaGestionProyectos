-- Fase 2 / 17: conservar historia y permitir una nueva asignación de la misma
-- especialidad después de archivar la anterior. La unicidad activa parcial de
-- la migración 11 sigue impidiendo duplicados simultáneos.

begin;

alter table public.user_specialties
  drop constraint user_specialties_user_id_specialty_id_key;

commit;
