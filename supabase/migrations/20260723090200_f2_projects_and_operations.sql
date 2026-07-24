-- Fase 2 / 02: Contrataciones, Trabajos y entidades operativas.
-- Toda referencia operativa conserva project_id + work_id y valida el par por FK compuesta.

begin;

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete restrict,
  internal_code text not null unique check (btrim(internal_code) <> ''),
  name text not null check (btrim(name) <> ''),
  description text,
  contract_status_code text not null default 'active'
    check (contract_status_code in ('draft', 'active', 'on_hold', 'closed', 'cancelled', 'archived')),
  estimated_start_at timestamptz,
  estimated_end_at timestamptz,
  actual_start_at timestamptz,
  actual_end_at timestamptz,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint projects_estimated_dates check (
    estimated_end_at is null
    or (estimated_start_at is not null and estimated_end_at >= estimated_start_at)
  ),
  constraint projects_actual_dates check (
    actual_end_at is null
    or (actual_start_at is not null and actual_end_at >= actual_start_at)
  ),
  constraint projects_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.works (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete restrict,
  work_type_id uuid not null references public.work_types(id) on delete restrict,
  configuration_version_id uuid not null,
  internal_state_id uuid not null,
  name text not null check (btrim(name) <> ''),
  description text,
  priority_code text not null default 'normal'
    check (priority_code in ('low', 'normal', 'high', 'urgent', 'critical')),
  priority_justification text,
  responsible_user_id uuid references public.app_users(id) on delete restrict,
  estimated_start_at timestamptz,
  estimated_end_at timestamptz,
  actual_start_at timestamptz,
  actual_end_at timestamptz,
  wait_reason text,
  wait_follow_up_at timestamptz,
  wait_responsible text,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, id),
  unique (id, version),
  foreign key (work_type_id, configuration_version_id)
    references public.work_type_config_versions(work_type_id, id) on delete restrict,
  foreign key (configuration_version_id, internal_state_id)
    references public.work_state_definitions(configuration_version_id, id) on delete restrict,
  constraint works_priority_justification check (
    priority_code not in ('urgent', 'critical')
    or nullif(btrim(priority_justification), '') is not null
  ),
  constraint works_wait_complete check (
    (wait_reason is null and wait_follow_up_at is null and wait_responsible is null)
    or (
      nullif(btrim(wait_reason), '') is not null
      and wait_follow_up_at is not null
      and nullif(btrim(wait_responsible), '') is not null
    )
  ),
  constraint works_estimated_dates check (
    estimated_end_at is null
    or (estimated_start_at is not null and estimated_end_at >= estimated_start_at)
  ),
  constraint works_actual_dates check (
    actual_end_at is null
    or (actual_start_at is not null and actual_end_at >= actual_start_at)
  ),
  constraint works_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.project_memberships (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete restrict,
  user_id uuid not null references public.app_users(id) on delete restrict,
  assigned_at timestamptz not null default statement_timestamp(),
  assigned_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  ended_at timestamptz,
  ended_by uuid references public.app_users(id) on delete restrict,
  end_reason text,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, user_id, assigned_at),
  constraint project_memberships_end_complete check (
    (ended_at is null and ended_by is null and end_reason is null)
    or (
      ended_at is not null
      and ended_by is not null
      and nullif(btrim(end_reason), '') is not null
      and ended_at >= assigned_at
    )
  )
);

create table public.work_memberships (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  user_id uuid not null references public.app_users(id) on delete restrict,
  assigned_at timestamptz not null default statement_timestamp(),
  assigned_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  ended_at timestamptz,
  ended_by uuid references public.app_users(id) on delete restrict,
  end_reason text,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, work_id, user_id, assigned_at),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint work_memberships_end_complete check (
    (ended_at is null and ended_by is null and end_reason is null)
    or (
      ended_at is not null
      and ended_by is not null
      and nullif(btrim(end_reason), '') is not null
      and ended_at >= assigned_at
    )
  )
);

create table public.project_participants (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete restrict,
  participant_user_id uuid references public.app_users(id) on delete restrict,
  client_contact_id uuid references public.client_contacts(id) on delete restrict,
  participation_role text not null check (btrim(participation_role) <> ''),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  constraint project_participant_exactly_one check (
    (participant_user_id is not null)::integer + (client_contact_id is not null)::integer = 1
  ),
  constraint project_participants_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.properties (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete restrict,
  name text not null check (btrim(name) <> ''),
  property_number text,
  cadastral_plan_number text,
  registry_folio text,
  registry_entry text,
  real_area numeric(18, 4) check (real_area is null or real_area >= 0),
  area_unit text,
  location jsonb not null default '{}'::jsonb check (jsonb_typeof(location) = 'object'),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, id),
  constraint properties_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.work_properties (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  property_id uuid not null,
  relation_kind text not null default 'subject',
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (work_id, property_id),
  unique (project_id, work_id, id),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  foreign key (project_id, property_id)
    references public.properties(project_id, id) on delete restrict,
  constraint work_properties_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.work_property_values (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  work_property_id uuid not null,
  property_code text not null check (property_code ~ '^[a-z][a-z0-9_.]*$'),
  value jsonb not null,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  unique (work_property_id, property_code),
  foreign key (project_id, work_id, work_property_id)
    references public.work_properties(project_id, work_id, id) on delete restrict
);

create table public.work_type_history (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  previous_work_type_id uuid not null references public.work_types(id) on delete restrict,
  new_work_type_id uuid not null references public.work_types(id) on delete restrict,
  previous_configuration_version_id uuid not null references public.work_type_config_versions(id) on delete restrict,
  new_configuration_version_id uuid not null references public.work_type_config_versions(id) on delete restrict,
  previous_internal_state_id uuid not null references public.work_state_definitions(id) on delete restrict,
  new_internal_state_id uuid not null references public.work_state_definitions(id) on delete restrict,
  previous_work_version bigint not null check (previous_work_version > 0),
  comparison jsonb not null check (jsonb_typeof(comparison) = 'object'),
  approval_request_id uuid not null,
  changed_at timestamptz not null default statement_timestamp(),
  changed_by uuid not null references public.app_users(id) on delete restrict,
  correlation_id uuid not null,
  unique (work_id, previous_work_version),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint work_type_history_actual_change check (previous_work_type_id <> new_work_type_id)
);

create table public.managements (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  management_type_code text not null check (management_type_code ~ '^[a-z][a-z0-9_]*$'),
  other_type_description text,
  title text not null check (btrim(title) <> ''),
  description text,
  status_code text not null,
  priority_code text not null default 'normal'
    check (priority_code in ('low', 'normal', 'high', 'urgent', 'critical')),
  priority_justification text,
  responsible_user_id uuid references public.app_users(id) on delete restrict,
  started_at timestamptz,
  due_at timestamptz,
  next_follow_up_at timestamptz,
  result text,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, work_id, id),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  constraint managements_other_description check (
    management_type_code <> 'other'
    or nullif(btrim(other_type_description), '') is not null
  ),
  constraint managements_priority_justification check (
    priority_code not in ('urgent', 'critical')
    or nullif(btrim(priority_justification), '') is not null
  ),
  constraint managements_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.management_notes (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  management_id uuid not null,
  logical_note_id uuid not null,
  revision integer not null check (revision > 0),
  body text not null check (btrim(body) <> ''),
  supersedes_note_id uuid,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid not null references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (management_id, logical_note_id, revision),
  unique (management_id, id),
  foreign key (project_id, work_id, management_id)
    references public.managements(project_id, work_id, id) on delete restrict,
  foreign key (management_id, supersedes_note_id)
    references public.management_notes(management_id, id) on delete restrict,
  constraint management_notes_revision_chain check (
    (revision = 1 and supersedes_note_id is null)
    or (revision > 1 and supersedes_note_id is not null)
  )
);

create table public.management_wait_periods (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  management_id uuid not null,
  previous_status_code text not null,
  reason text not null check (btrim(reason) <> ''),
  responsible_party text not null check (btrim(responsible_party) <> ''),
  follow_up_at timestamptz not null,
  started_at timestamptz not null default statement_timestamp(),
  started_by uuid not null references public.app_users(id) on delete restrict,
  resumed_at timestamptz,
  resumed_by uuid references public.app_users(id) on delete restrict,
  resume_note text,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id, management_id)
    references public.managements(project_id, work_id, id) on delete restrict,
  constraint management_wait_resume_complete check (
    (resumed_at is null and resumed_by is null)
    or (resumed_at is not null and resumed_by is not null and resumed_at >= started_at)
  )
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  management_id uuid,
  parent_task_id uuid,
  task_type_code text not null check (task_type_code ~ '^[a-z][a-z0-9_]*$'),
  other_type_description text,
  title text not null check (btrim(title) <> ''),
  description text,
  status_code text not null,
  priority_code text not null default 'normal'
    check (priority_code in ('low', 'normal', 'high', 'urgent', 'critical')),
  priority_justification text,
  responsible_user_id uuid references public.app_users(id) on delete restrict,
  estimated_effort_minutes integer check (estimated_effort_minutes is null or estimated_effort_minutes >= 0),
  actual_duration_minutes integer check (actual_duration_minutes is null or actual_duration_minutes >= 0),
  progress_percent numeric(5, 2) not null default 0 check (progress_percent between 0 and 100),
  due_at timestamptz,
  wait_reason text,
  wait_follow_up_at timestamptz,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, work_id, id),
  foreign key (project_id, work_id)
    references public.works(project_id, id) on delete restrict,
  foreign key (project_id, work_id, management_id)
    references public.managements(project_id, work_id, id) on delete restrict,
  foreign key (project_id, work_id, parent_task_id)
    references public.tasks(project_id, work_id, id) on delete restrict,
  constraint tasks_not_own_parent check (parent_task_id is null or parent_task_id <> id),
  constraint tasks_other_description check (
    task_type_code <> 'other'
    or nullif(btrim(other_type_description), '') is not null
  ),
  constraint tasks_priority_justification check (
    priority_code not in ('urgent', 'critical')
    or nullif(btrim(priority_justification), '') is not null
  ),
  constraint tasks_wait_complete check (
    (wait_reason is null and wait_follow_up_at is null)
    or (nullif(btrim(wait_reason), '') is not null and wait_follow_up_at is not null)
  ),
  constraint tasks_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.task_checklists (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  task_id uuid not null,
  title text not null check (btrim(title) <> ''),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, work_id, id),
  foreign key (project_id, work_id, task_id)
    references public.tasks(project_id, work_id, id) on delete restrict,
  constraint task_checklists_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.task_checklist_items (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  checklist_id uuid not null,
  label text not null check (btrim(label) <> ''),
  sort_order integer not null default 0,
  is_completed boolean not null default false,
  completed_at timestamptz,
  completed_by uuid references public.app_users(id) on delete restrict,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  foreign key (project_id, work_id, checklist_id)
    references public.task_checklists(project_id, work_id, id) on delete restrict,
  constraint checklist_item_completion_complete check (
    (not is_completed and completed_at is null and completed_by is null)
    or (is_completed and completed_at is not null and completed_by is not null)
  ),
  constraint checklist_items_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.task_dependencies (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  predecessor_task_id uuid not null,
  successor_task_id uuid not null,
  dependency_kind text not null default 'finish_to_start'
    check (dependency_kind in ('finish_to_start', 'start_to_start', 'finish_to_finish', 'start_to_finish')),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (predecessor_task_id, successor_task_id),
  foreign key (project_id, work_id, predecessor_task_id)
    references public.tasks(project_id, work_id, id) on delete restrict,
  foreign key (project_id, work_id, successor_task_id)
    references public.tasks(project_id, work_id, id) on delete restrict,
  constraint task_dependency_not_self check (predecessor_task_id <> successor_task_id),
  constraint task_dependencies_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.schedule_blocks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  task_id uuid not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  modality text not null check (modality in ('office', 'field', 'meeting', 'follow_up', 'other')),
  location text,
  status_code text not null default 'planned'
    check (status_code in ('planned', 'confirmed', 'in_progress', 'completed', 'cancelled', 'archived')),
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  updated_at timestamptz not null default statement_timestamp(),
  updated_by uuid references public.app_users(id) on delete restrict,
  version bigint not null default 1 check (version > 0),
  archived_at timestamptz,
  archive_reason text,
  archived_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (project_id, work_id, id),
  foreign key (project_id, work_id, task_id)
    references public.tasks(project_id, work_id, id) on delete restrict,
  constraint schedule_blocks_time_order check (ends_at > starts_at),
  constraint schedule_blocks_archive_complete check (
    (archived_at is null and archive_reason is null and archived_by is null)
    or (
      archived_at is not null
      and nullif(btrim(archive_reason), '') is not null
      and archived_by is not null
    )
  )
);

create table public.schedule_block_users (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  schedule_block_id uuid not null,
  user_id uuid not null references public.app_users(id) on delete restrict,
  assignment_role text,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (schedule_block_id, user_id),
  foreign key (project_id, work_id, schedule_block_id)
    references public.schedule_blocks(project_id, work_id, id) on delete restrict
);

create table public.schedule_block_resources (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  work_id uuid not null,
  schedule_block_id uuid not null,
  resource_id uuid not null references public.resources(id) on delete restrict,
  created_at timestamptz not null default statement_timestamp(),
  created_by uuid references public.app_users(id) on delete restrict,
  correlation_id uuid not null default gen_random_uuid(),
  unique (schedule_block_id, resource_id),
  foreign key (project_id, work_id, schedule_block_id)
    references public.schedule_blocks(project_id, work_id, id) on delete restrict
);

commit;
