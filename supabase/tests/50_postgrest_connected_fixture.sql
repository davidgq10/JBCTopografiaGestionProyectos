\set ON_ERROR_STOP on

insert into public.app_users (
  id, auth_subject, display_name, email, is_pre_authorized, is_active,
  preferred_accent, preferred_theme
) values
  (
    'a1000000-0000-4000-8000-000000000003',
    'b1000000-0000-4000-8000-000000000003',
    'María Técnica', 'maria.tecnica@example.test', true, true, 'teal', 'auto'
  ),
  (
    'a1000000-0000-4000-8000-000000000002',
    'b1000000-0000-4000-8000-000000000002',
    'Coordinación Sintética', 'coordinacion@example.test', true, true, 'teal', 'auto'
  );

insert into public.user_roles (id, user_id, role_id, valid_from)
values
  (
    'c1000000-0000-4000-8000-000000000003',
    'a1000000-0000-4000-8000-000000000003',
    (select id from public.roles where code = 'technician'),
    statement_timestamp() - interval '1 day'
  ),
  (
    'c1000000-0000-4000-8000-000000000002',
    'a1000000-0000-4000-8000-000000000002',
    (select id from public.roles where code = 'coordinator'),
    statement_timestamp() - interval '1 day'
  );

\echo 'CONNECTED-FIXTURE PASS | datos sintéticos cargados'
