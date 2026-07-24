-- Fase 2 / 01: fundamentos, identidad, administración y clientes.
-- PostgreSQL 15+ / Supabase. No contiene políticas RLS: DEC-0103 sigue pendiente.

begin;

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;
create schema if not exists app_private;

create or replace function app_private.touch_versioned_row()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at := statement_timestamp();
  new.version := old.version + 1;
  return new;
end;
$$;

create or replace function app_private.reject_delete()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  raise exception using
    errcode = '23514',
    message = format('DELETE no permitido en %I; archive el registro con motivo', tg_table_name);
end;
$$;

create or replace function app_private.reject_update_or_delete()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  raise exception using
    errcode = '23514',
    message = format('%s no permitido en la historia append-only %I', tg_op, tg_table_name);
end;
$$;

create table public.app_users (
  id uuid primary key default gen_random_uuid(),
  auth_subject uuid not null unique,
  display_name text not null check (btrim(display_name) <> ''),
  email text not null,
  is_pre_authorized boolean not null default false,
  is_active boolean not null default true,
  revoked_at timestamptz,
  revoked_reason text,
  preferred_accent text,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint app_users_email_not_blank check (btrim(email) <> ''),
  constraint app_users_revocation_complete check (
    (revoked_at is null and revoked_reason is null)
    or (revoked_at is not null and nullif(btrim(revoked_reason), '') is not null)
  ),
  constraint app_users_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create unique index app_users_email_normalized_uidx
  on public.app_users (lower(btrim(email)));

create table public.roles (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z][a-z0-9_]*$'),
  name text not null check (btrim(name) <> ''),
  description text,
  is_system boolean not null default false,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint roles_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.permissions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z][a-z0-9_.]*$'),
  name text not null check (btrim(name) <> ''),
  description text,
  module_code text not null check (module_code ~ '^[a-z][a-z0-9_]*$'),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint permissions_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.app_users(id) on delete restrict,
  role_id uuid not null references public.roles(id) on delete restrict,
  valid_from timestamptz not null default statement_timestamp(),
  valid_until timestamptz,
  assigned_at timestamptz not null default statement_timestamp(),
  assigned_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  revoked_at timestamptz,
  revoked_by uuid references public.app_users(id) on delete restrict,
  revocation_reason text,
  correlation_id uuid not null default gen_random_uuid(),
  unique (user_id, role_id, valid_from),
  constraint user_roles_valid_window check (valid_until is null or valid_until > valid_from),
  constraint user_roles_revocation_complete check (
    (revoked_at is null and revoked_by is null and revocation_reason is null)
    or (
      revoked_at is not null
      and revoked_by is not null
      and nullif(btrim(revocation_reason), '') is not null
    )
  )
);

create table public.role_permissions (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references public.roles(id) on delete restrict,
  permission_id uuid not null references public.permissions(id) on delete restrict,
  granted_at timestamptz not null default statement_timestamp(),
  granted_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  revoked_at timestamptz,
  revoked_by uuid references public.app_users(id) on delete restrict,
  revocation_reason text,
  correlation_id uuid not null default gen_random_uuid(),
  unique (role_id, permission_id, granted_at),
  constraint role_permissions_revocation_complete check (
    (revoked_at is null and revoked_by is null and revocation_reason is null)
    or (
      revoked_at is not null
      and revoked_by is not null
      and nullif(btrim(revocation_reason), '') is not null
    )
  )
);

create table public.specialties (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z][a-z0-9_]*$'),
  name text not null check (btrim(name) <> ''),
  description text,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint specialties_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.user_specialties (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.app_users(id) on delete restrict,
  specialty_id uuid not null references public.specialties(id) on delete restrict,
  assigned_at timestamptz not null default statement_timestamp(),
  assigned_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (user_id, specialty_id),
  constraint user_specialties_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.app_users(id) on delete restrict,
  device_label text not null check (btrim(device_label) <> ''),
  platform text not null check (platform in ('web', 'windows', 'android', 'ios', 'other')),
  last_seen_at timestamptz,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint user_devices_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.catalogs (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z][a-z0-9_]*$'),
  name text not null check (btrim(name) <> ''),
  description text,
  is_protected boolean not null default false,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint catalogs_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.catalog_versions (
  id uuid primary key default gen_random_uuid(),
  catalog_id uuid not null references public.catalogs(id) on delete restrict,
  version_number integer not null check (version_number > 0),
  status text not null check (status in ('draft', 'active', 'superseded', 'archived')),
  valid_from timestamptz,
  valid_until timestamptz,
  published_at timestamptz,
  published_by uuid references public.app_users(id) on delete restrict,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  row_version bigint not null default 1 check (row_version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  unique (catalog_id, version_number),
  unique (catalog_id, id),
  constraint catalog_versions_valid_window check (
    valid_until is null or (valid_from is not null and valid_until > valid_from)
  ),
  constraint catalog_versions_publication_complete check (
    (published_at is null and published_by is null)
    or (published_at is not null and published_by is not null)
  )
);

create table public.catalog_values (
  id uuid primary key default gen_random_uuid(),
  catalog_id uuid not null,
  catalog_version_id uuid not null,
  code text not null check (code ~ '^[a-z][a-z0-9_]*$'),
  name text not null check (btrim(name) <> ''),
  description text,
  color text,
  icon text,
  sort_order integer not null default 0,
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  is_other boolean not null default false,
  is_protected boolean not null default false,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (catalog_version_id, code),
  unique (catalog_id, catalog_version_id, id),
  foreign key (catalog_id, catalog_version_id)
    references public.catalog_versions(catalog_id, id) on delete restrict,
  constraint catalog_values_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.work_types (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z][a-z0-9_]*$'),
  name text not null check (btrim(name) <> ''),
  supports_apt boolean not null default false,
  supports_siri boolean not null default false,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint work_types_siri_requires_catastro check (not supports_siri or supports_apt),
  constraint work_types_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

insert into public.work_types (code, name, supports_apt, supports_siri)
values
  ('delimitacion', 'Delimitación', false, false),
  ('curvas_nivel', 'Curvas de nivel', false, false),
  ('avaluo', 'Avalúo', false, false),
  ('croquis', 'Croquis', false, false),
  ('plano_catastro', 'Plano de catastro', true, true)
on conflict (code) do nothing;

create table public.work_type_config_versions (
  id uuid primary key default gen_random_uuid(),
  work_type_id uuid not null references public.work_types(id) on delete restrict,
  version_number integer not null check (version_number > 0),
  status text not null check (status in ('draft', 'active', 'superseded', 'archived')),
  configuration jsonb not null default '{}'::jsonb check (jsonb_typeof(configuration) = 'object'),
  valid_from timestamptz,
  valid_until timestamptz,
  published_at timestamptz,
  published_by uuid references public.app_users(id) on delete restrict,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  row_version bigint not null default 1 check (row_version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  unique (work_type_id, version_number),
  unique (work_type_id, id),
  constraint work_type_configs_valid_window check (
    valid_until is null or (valid_from is not null and valid_until > valid_from)
  )
);

create table public.work_state_definitions (
  id uuid primary key default gen_random_uuid(),
  work_type_id uuid not null,
  configuration_version_id uuid not null,
  code text not null check (code ~ '^[a-z][a-z0-9_]*$'),
  name text not null check (btrim(name) <> ''),
  sort_order integer not null default 0,
  is_terminal boolean not null default false,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (configuration_version_id, code),
  unique (configuration_version_id, id),
  foreign key (work_type_id, configuration_version_id)
    references public.work_type_config_versions(work_type_id, id) on delete restrict,
  constraint work_state_definitions_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.resources (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z][a-z0-9_-]*$'),
  name text not null check (btrim(name) <> ''),
  resource_kind text not null check (resource_kind in ('equipment', 'vehicle', 'computer', 'personnel_auxiliary', 'other')),
  status_code text not null check (status_code in ('available', 'reserved', 'in_use', 'maintenance', 'out_of_service', 'archived')),
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint resources_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.clients (
  id uuid primary key default gen_random_uuid(),
  client_kind text not null check (client_kind in ('person', 'organization')),
  display_name text not null check (btrim(display_name) <> ''),
  identification text,
  normalized_identification text,
  primary_phone text,
  primary_email text,
  observations text,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint clients_identification_pair check (
    (identification is null and normalized_identification is null)
    or (
      nullif(btrim(identification), '') is not null
      and nullif(btrim(normalized_identification), '') is not null
    )
  ),
  constraint clients_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create unique index clients_normalized_identification_uidx
  on public.clients (normalized_identification)
  where normalized_identification is not null and archived_at is null;

create table public.client_contacts (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete restrict,
  name text not null check (btrim(name) <> ''),
  position_title text,
  relationship text,
  phone text,
  email text,
  preferred_channel text,
  is_primary boolean not null default false,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint client_contacts_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.client_addresses (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete restrict,
  address_kind text not null default 'other',
  province text not null check (btrim(province) <> ''),
  canton text not null check (btrim(canton) <> ''),
  district text not null check (btrim(district) <> ''),
  address_line text not null check (btrim(address_line) <> ''),
  is_primary boolean not null default false,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint client_addresses_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

commit;
