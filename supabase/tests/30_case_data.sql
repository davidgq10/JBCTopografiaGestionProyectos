-- Fixtures y casos funcionales de DEC-0103 aprobada el 2026-07-23.
-- Todo dato es sintético y la transacción exterior de run_rls.psql hace ROLLBACK.

create temporary table rls_fixture_users (
  app_user_id uuid primary key,
  auth_subject uuid not null unique,
  app_role text,
  access_case text not null,
  is_pre_authorized boolean not null,
  is_active boolean not null
) on commit preserve rows;

insert into rls_fixture_users values
  ('a1000000-0000-4000-8000-000000000001','b1000000-0000-4000-8000-000000000001','administrator','primary',true,true),
  ('a1000000-0000-4000-8000-000000000002','b1000000-0000-4000-8000-000000000002','coordinator','primary',true,true),
  ('a1000000-0000-4000-8000-000000000003','b1000000-0000-4000-8000-000000000003','technician','primary',true,true),
  ('a1000000-0000-4000-8000-000000000004','b1000000-0000-4000-8000-000000000004','read_only','primary',true,true),
  ('a1000000-0000-4000-8000-000000000005','b1000000-0000-4000-8000-000000000005','administrator','revoked',true,false),
  ('a1000000-0000-4000-8000-000000000006','b1000000-0000-4000-8000-000000000006','coordinator','revoked',true,false),
  ('a1000000-0000-4000-8000-000000000007','b1000000-0000-4000-8000-000000000007','technician','revoked',true,false),
  ('a1000000-0000-4000-8000-000000000008','b1000000-0000-4000-8000-000000000008','read_only','revoked',true,false),
  ('a1000000-0000-4000-8000-000000000009','b1000000-0000-4000-8000-000000000009','administrator','unauthorized',false,true),
  ('a1000000-0000-4000-8000-00000000000a','b1000000-0000-4000-8000-00000000000a','coordinator','unauthorized',false,true),
  ('a1000000-0000-4000-8000-00000000000b','b1000000-0000-4000-8000-00000000000b','technician','unauthorized',false,true),
  ('a1000000-0000-4000-8000-00000000000c','b1000000-0000-4000-8000-00000000000c','read_only','unauthorized',false,true),
  ('a1000000-0000-4000-8000-00000000000d','b1000000-0000-4000-8000-00000000000d','technician','work_only',true,true),
  ('a1000000-0000-4000-8000-00000000000e','b1000000-0000-4000-8000-00000000000e','technician','unassigned',true,true),
  ('a1000000-0000-4000-8000-00000000000f','b1000000-0000-4000-8000-00000000000f',null,'spare',true,true);

insert into public.app_users (
  id, auth_subject, display_name, email, is_pre_authorized, is_active,
  revoked_at, revoked_reason
)
select
  app_user_id,
  auth_subject,
  'Usuario ' || access_case || ' ' || coalesce(app_role, 'spare'),
  replace(app_user_id::text, '-', '') || '@rls.example.test',
  is_pre_authorized,
  is_active,
  case when access_case = 'revoked' then statement_timestamp() else null end,
  case when access_case = 'revoked' then 'Revocación sintética RLS' else null end
from rls_fixture_users;

insert into rls_test_subjects(auth_subject, app_user_id, app_role, identity_state)
select
  auth_subject,
  app_user_id,
  app_role,
  case access_case
    when 'revoked' then 'revoked'
    when 'unauthorized' then 'unauthorized'
    else 'active'
  end
from rls_fixture_users
where app_role is not null;

insert into public.user_roles(id, user_id, role_id, valid_from)
select
  md5('user-role:' || u.app_user_id::text)::uuid,
  u.app_user_id,
  r.id,
  statement_timestamp() - interval '1 day'
from rls_fixture_users u
join public.roles r on r.code = u.app_role
where u.app_role is not null;

-- Catálogos e identidad auxiliar.
insert into public.roles(id, code, name, description, is_system)
values ('11000000-0000-4000-8000-000000000001','fixture_role','Rol fixture','Solo pruebas RLS',false);

insert into public.permissions(id, code, name, module_code) values
  ('12000000-0000-4000-8000-000000000001','fixture.read','Lectura fixture','testing'),
  ('12000000-0000-4000-8000-000000000002','fixture.write','Escritura fixture','testing');

insert into public.role_permissions(id, role_id, permission_id)
values ('12100000-0000-4000-8000-000000000001','11000000-0000-4000-8000-000000000001','12000000-0000-4000-8000-000000000001');

insert into public.specialties(id, code, name) values
  ('13000000-0000-4000-8000-000000000001','fixture_topografia','Topografía fixture'),
  ('13000000-0000-4000-8000-000000000002','fixture_catastro','Catastro fixture');

insert into public.user_specialties(id, user_id, specialty_id)
select md5('specialty:' || app_user_id::text)::uuid, app_user_id,
       '13000000-0000-4000-8000-000000000001'::uuid
from rls_fixture_users;

insert into public.user_devices(id, user_id, device_label, platform)
select md5('device:' || app_user_id::text)::uuid, app_user_id,
       'Navegador RLS', 'web'
from rls_fixture_users;

insert into public.resources(id, code, name, resource_kind, status_code) values
  ('14000000-0000-4000-8000-000000000001','fixture_equipo_1','Equipo fixture 1','equipment','available'),
  ('14000000-0000-4000-8000-000000000002','fixture_equipo_2','Equipo fixture 2','equipment','available');

insert into public.catalogs(id, code, name)
values ('15000000-0000-4000-8000-000000000001','fixture_catalog','Catálogo fixture');
insert into public.catalog_versions(id, catalog_id, version_number, status)
values ('15100000-0000-4000-8000-000000000001','15000000-0000-4000-8000-000000000001',1,'draft');
insert into public.catalog_values(id, catalog_id, catalog_version_id, code, name)
values ('15200000-0000-4000-8000-000000000001','15000000-0000-4000-8000-000000000001','15100000-0000-4000-8000-000000000001','fixture_value','Valor fixture');

insert into public.work_type_config_versions(id, work_type_id, version_number, status, configuration)
select v.id, wt.id, 1, 'active', '{}'::jsonb
from (values
  ('16100000-0000-4000-8000-000000000001'::uuid,'plano_catastro'::text),
  ('16100000-0000-4000-8000-000000000002'::uuid,'delimitacion'::text)
) v(id, work_type_code)
join public.work_types wt on wt.code=v.work_type_code;
insert into public.work_state_definitions(id, work_type_id, configuration_version_id, code, name)
select v.id, wt.id, v.configuration_version_id, 'active', 'Activo'
from (values
  ('16200000-0000-4000-8000-000000000001'::uuid,'plano_catastro'::text,'16100000-0000-4000-8000-000000000001'::uuid),
  ('16200000-0000-4000-8000-000000000002'::uuid,'delimitacion'::text,'16100000-0000-4000-8000-000000000002'::uuid)
) v(id, work_type_code, configuration_version_id)
join public.work_types wt on wt.code=v.work_type_code;

-- Cliente, Proyecto asignado y dos Trabajos hermanos.
insert into public.clients(id, client_kind, display_name)
values ('17000000-0000-4000-8000-000000000001','organization','Cliente RLS');
insert into public.client_contacts(id, client_id, name)
values ('17100000-0000-4000-8000-000000000001','17000000-0000-4000-8000-000000000001','Contacto RLS');
insert into public.client_addresses(id, client_id, province, canton, district, address_line)
values ('17200000-0000-4000-8000-000000000001','17000000-0000-4000-8000-000000000001','San José','San José','Carmen','Dirección sintética');

insert into public.projects(id, client_id, internal_code, name, contract_status_code)
values ('18000000-0000-4000-8000-000000000001','17000000-0000-4000-8000-000000000001','RLS-P-A','Proyecto asignado RLS','active');
insert into public.works(id, project_id, work_type_id, configuration_version_id, internal_state_id, name) values
  ('18100000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001',(select id from public.work_types where code='plano_catastro'),'16100000-0000-4000-8000-000000000001','16200000-0000-4000-8000-000000000001','Trabajo objetivo RLS'),
  ('18100000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',(select id from public.work_types where code='plano_catastro'),'16100000-0000-4000-8000-000000000001','16200000-0000-4000-8000-000000000001','Trabajo hermano RLS');

insert into public.project_memberships(id, project_id, user_id)
values ('18200000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','a1000000-0000-4000-8000-000000000003');
insert into public.work_memberships(id, project_id, work_id, user_id) values
  ('18210000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000002','a1000000-0000-4000-8000-000000000003'),
  ('18210000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','a1000000-0000-4000-8000-00000000000d');

-- Asignaciones históricas por propietario para probar lectura propia/ajena sin
-- conceder alcance activo a los sujetos work_only o unassigned.
insert into public.project_memberships(
  id, project_id, user_id, assigned_at, ended_at, ended_by, end_reason
)
select md5('project-membership-owner:' || app_user_id::text)::uuid,
       '18000000-0000-4000-8000-000000000001', app_user_id,
       statement_timestamp() - interval '3 days', statement_timestamp() - interval '2 days',
       'a1000000-0000-4000-8000-000000000001', 'Fixture histórico RLS'
from rls_fixture_users;

insert into public.work_memberships(
  id, project_id, work_id, user_id, assigned_at, ended_at, ended_by, end_reason
)
select md5('work-membership-owner:' || app_user_id::text)::uuid,
       '18000000-0000-4000-8000-000000000001',
       '18100000-0000-4000-8000-000000000001', app_user_id,
       statement_timestamp() - interval '3 days', statement_timestamp() - interval '2 days',
       'a1000000-0000-4000-8000-000000000001', 'Fixture histórico RLS'
from rls_fixture_users;

insert into public.project_participants(id, project_id, client_contact_id, participation_role)
values ('18300000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','17100000-0000-4000-8000-000000000001','Contacto');
insert into public.properties(id, project_id, name, location) values
  ('18400000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','Inmueble objetivo','{}'),
  ('18400000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001','Inmueble auxiliar','{}');
insert into public.work_properties(id, project_id, work_id, property_id)
values ('18500000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','18400000-0000-4000-8000-000000000001');
insert into public.work_property_values(id, project_id, work_id, work_property_id, property_code, value)
values ('18600000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','18500000-0000-4000-8000-000000000001','fixture.area','{"value": 100}');

-- Gestión, tareas y programación.
insert into public.managements(id, project_id, work_id, management_type_code, title, status_code)
values ('19000000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','follow_up','Gestión RLS','active');
insert into public.management_notes(id, project_id, work_id, management_id, logical_note_id, revision, body, created_by)
values ('19100000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','19000000-0000-4000-8000-000000000001','19110000-0000-4000-8000-000000000001',1,'Nota RLS','a1000000-0000-4000-8000-000000000001');
insert into public.management_wait_periods(id, project_id, work_id, management_id, previous_status_code, reason, responsible_party, follow_up_at, started_by)
values ('19200000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','19000000-0000-4000-8000-000000000001','active','Espera RLS','Cliente',statement_timestamp()+interval '1 day','a1000000-0000-4000-8000-000000000001');

insert into public.tasks(id, project_id, work_id, task_type_code, title, status_code) values
  ('1a000000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','field','Tarea 1','pending'),
  ('1a000000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','office','Tarea 2','pending'),
  ('1a000000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','office','Tarea 3','pending'),
  ('1a000000-0000-4000-8000-000000000004','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','office','Tarea 4','pending');
insert into public.task_checklists(id, project_id, work_id, task_id, title)
values ('1a100000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','1a000000-0000-4000-8000-000000000001','Lista RLS');
insert into public.task_checklist_items(id, project_id, work_id, checklist_id, label)
values ('1a200000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','1a100000-0000-4000-8000-000000000001','Ítem RLS');
insert into public.task_dependencies(id, project_id, work_id, predecessor_task_id, successor_task_id)
values ('1a300000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','1a000000-0000-4000-8000-000000000001','1a000000-0000-4000-8000-000000000002');

insert into public.schedule_blocks(id, project_id, work_id, task_id, starts_at, ends_at, modality)
values ('1b000000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','1a000000-0000-4000-8000-000000000001',statement_timestamp()+interval '2 days',statement_timestamp()+interval '2 days 1 hour','field');
insert into public.schedule_block_users(id, project_id, work_id, schedule_block_id, user_id)
values ('1b100000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','1b000000-0000-4000-8000-000000000001','a1000000-0000-4000-8000-000000000003');
insert into public.schedule_block_resources(id, project_id, work_id, schedule_block_id, resource_id)
values ('1b200000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','1b000000-0000-4000-8000-000000000001','14000000-0000-4000-8000-000000000001');

-- APT/SIRI y OneDrive.
insert into public.external_procedures(id, project_id, work_id, provider, procedure_kind)
values ('1c000000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','apt','consulta');
insert into public.external_status_events(id, project_id, work_id, external_procedure_id, original_status_text, normalized_status_code, source_fingerprint)
values ('1c100000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','1c000000-0000-4000-8000-000000000001','En trámite','in_progress','status_fixture_1');
insert into public.external_query_runs(id, project_id, work_id, external_procedure_id, provider, trigger_kind, status, idempotency_key)
values ('1c200000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','1c000000-0000-4000-8000-000000000001','apt','manual','succeeded','query_fixture_1');

insert into public.drive_items(id, scope_kind, client_id, project_id, work_id, drive_id, drive_item_id, item_kind, name) values
  ('1d000000-0000-4000-8000-000000000001','client','17000000-0000-4000-8000-000000000001',null,null,'drive_fixture','item_client','folder','Cliente'),
  ('1d000000-0000-4000-8000-000000000002','project_root',null,'18000000-0000-4000-8000-000000000001',null,'drive_fixture','item_project','folder','Proyecto'),
  ('1d000000-0000-4000-8000-000000000003','work',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','drive_fixture','item_work','folder','Trabajo');
insert into public.drive_operations(id, drive_item_id, scope_kind, client_id, project_id, work_id, operation_kind, status, idempotency_key) values
  ('1d100000-0000-4000-8000-000000000001','1d000000-0000-4000-8000-000000000001','client','17000000-0000-4000-8000-000000000001',null,null,'link','requested','drive_op_client'),
  ('1d100000-0000-4000-8000-000000000002','1d000000-0000-4000-8000-000000000002','project',null,'18000000-0000-4000-8000-000000000001',null,'link','requested','drive_op_project'),
  ('1d100000-0000-4000-8000-000000000003','1d000000-0000-4000-8000-000000000003','work',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','link','requested','drive_op_work');
insert into public.drive_delta_cursors(id, drive_id, delta_cursor, last_successful_sync_at)
values ('1d200000-0000-4000-8000-000000000001','drive_cursor_fixture','cursor_fixture',statement_timestamp());

-- Aprobaciones en los tres alcances y solicitudes auxiliares para INSERT.
insert into public.approval_targets(id, owner_module, target_kind, target_entity_id, target_version, scope_kind, project_id, work_id, target_snapshot, snapshot_hash, registered_by) values
  ('1e000000-0000-4000-8000-000000000001','testing','fixture','1e010000-0000-4000-8000-000000000001',1,'organization',null,null,'{}','hash_org','a1000000-0000-4000-8000-000000000001'),
  ('1e000000-0000-4000-8000-000000000002','testing','fixture','1e010000-0000-4000-8000-000000000002',1,'project','18000000-0000-4000-8000-000000000001',null,'{}','hash_project','a1000000-0000-4000-8000-000000000001'),
  ('1e000000-0000-4000-8000-000000000003','testing','fixture','1e010000-0000-4000-8000-000000000003',1,'work','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','{}','hash_work','a1000000-0000-4000-8000-000000000001'),
  ('1e000000-0000-4000-8000-000000000004','testing','fixture_spare','1e010000-0000-4000-8000-000000000004',1,'organization',null,null,'{}','hash_org_spare','a1000000-0000-4000-8000-000000000001'),
  ('1e000000-0000-4000-8000-000000000005','testing','fixture_spare','1e010000-0000-4000-8000-000000000005',1,'project','18000000-0000-4000-8000-000000000001',null,'{}','hash_project_spare','a1000000-0000-4000-8000-000000000001'),
  ('1e000000-0000-4000-8000-000000000006','testing','fixture_spare','1e010000-0000-4000-8000-000000000006',1,'work','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','{}','hash_work_spare','a1000000-0000-4000-8000-000000000001');
insert into public.approval_requests(id, approval_target_id, project_id, work_id, action_code, status, requested_change, requested_by) values
  ('1e100000-0000-4000-8000-000000000001','1e000000-0000-4000-8000-000000000001',null,null,'fixture.action','draft','{}','a1000000-0000-4000-8000-00000000000f'),
  ('1e100000-0000-4000-8000-000000000002','1e000000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null,'fixture.action','draft','{}','a1000000-0000-4000-8000-00000000000f'),
  ('1e100000-0000-4000-8000-000000000003','1e000000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','fixture.action','draft','{}','a1000000-0000-4000-8000-00000000000f'),
  ('1e100000-0000-4000-8000-000000000004','1e000000-0000-4000-8000-000000000004',null,null,'fixture.spare','draft','{}','a1000000-0000-4000-8000-000000000001'),
  ('1e100000-0000-4000-8000-000000000005','1e000000-0000-4000-8000-000000000005','18000000-0000-4000-8000-000000000001',null,'fixture.spare','draft','{}','a1000000-0000-4000-8000-000000000001'),
  ('1e100000-0000-4000-8000-000000000006','1e000000-0000-4000-8000-000000000006','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','fixture.spare','draft','{}','a1000000-0000-4000-8000-000000000001'),
  ('1e100000-0000-4000-8000-000000000007','1e000000-0000-4000-8000-000000000001',null,null,'fixture.self_admin_org','draft','{}','a1000000-0000-4000-8000-000000000001'),
  ('1e100000-0000-4000-8000-000000000008','1e000000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null,'fixture.self_admin_project','draft','{}','a1000000-0000-4000-8000-000000000001'),
  ('1e100000-0000-4000-8000-000000000009','1e000000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','fixture.self_admin_work','draft','{}','a1000000-0000-4000-8000-000000000001'),
  ('1e100000-0000-4000-8000-00000000000a','1e000000-0000-4000-8000-000000000001',null,null,'fixture.self_coordinator_org','draft','{}','a1000000-0000-4000-8000-000000000002'),
  ('1e100000-0000-4000-8000-00000000000b','1e000000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null,'fixture.self_coordinator_project','draft','{}','a1000000-0000-4000-8000-000000000002'),
  ('1e100000-0000-4000-8000-00000000000c','1e000000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','fixture.self_coordinator_work','draft','{}','a1000000-0000-4000-8000-000000000002');
insert into public.approval_decisions(id, approval_request_id, project_id, work_id, decision, decided_by, target_version_reviewed) values
  ('1e200000-0000-4000-8000-000000000001','1e100000-0000-4000-8000-000000000001',null,null,'approved','a1000000-0000-4000-8000-000000000005',1),
  ('1e200000-0000-4000-8000-000000000002','1e100000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null,'approved','a1000000-0000-4000-8000-000000000005',1),
  ('1e200000-0000-4000-8000-000000000003','1e100000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','approved','a1000000-0000-4000-8000-000000000005',1);
insert into public.approval_executions(id, approval_request_id, project_id, work_id, execution_key, status) values
  ('1e300000-0000-4000-8000-000000000001','1e100000-0000-4000-8000-000000000001',null,null,'execution_org','pending'),
  ('1e300000-0000-4000-8000-000000000002','1e100000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null,'execution_project','pending'),
  ('1e300000-0000-4000-8000-000000000003','1e100000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','execution_work','pending');

insert into public.work_type_history(
  id, project_id, work_id, previous_work_type_id, new_work_type_id,
  previous_configuration_version_id, new_configuration_version_id,
  previous_internal_state_id, new_internal_state_id, previous_work_version,
  comparison, approval_request_id, changed_by, correlation_id
) values (
  '1e400000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',
  (select id from public.work_types where code='delimitacion'),
  (select id from public.work_types where code='plano_catastro'),
  '16100000-0000-4000-8000-000000000002','16100000-0000-4000-8000-000000000001',
  '16200000-0000-4000-8000-000000000002','16200000-0000-4000-8000-000000000001',1,
  '{}','1e100000-0000-4000-8000-000000000003','a1000000-0000-4000-8000-000000000001','1e410000-0000-4000-8000-000000000001'
);

-- Notificaciones y preferencias propias para cada identidad de prueba.
insert into public.notifications(id, user_id, category, severity, title, body, deduplication_key)
select md5('notification-org:' || app_user_id::text)::uuid, app_user_id,
       'system','info','Aviso global','Aviso sintético','org_' || replace(app_user_id::text,'-','')
from rls_fixture_users;
insert into public.notifications(id, user_id, project_id, category, severity, title, body, deduplication_key)
select md5('notification-project:' || app_user_id::text)::uuid, app_user_id,
       '18000000-0000-4000-8000-000000000001','task','info','Aviso Proyecto','Aviso sintético','project_' || replace(app_user_id::text,'-','')
from rls_fixture_users;
insert into public.notifications(id, user_id, project_id, work_id, category, severity, title, body, deduplication_key)
select md5('notification-work:' || app_user_id::text)::uuid, app_user_id,
       '18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','task','info','Aviso Trabajo','Aviso sintético','work_' || replace(app_user_id::text,'-','')
from rls_fixture_users;
insert into public.notification_preferences(id, user_id, category)
select md5('preference:' || app_user_id::text)::uuid, app_user_id, 'task'
from rls_fixture_users;
insert into public.push_subscriptions(id, user_id, user_device_id, endpoint_hash, subscription_reference)
select md5('push:' || app_user_id::text)::uuid, app_user_id,
       md5('device:' || app_user_id::text)::uuid,
       'endpoint_' || replace(app_user_id::text,'-',''),
       'subscription_' || replace(app_user_id::text,'-','')
from rls_fixture_users;

-- IA, auditoría, outbox e idempotencia.
insert into public.ai_prompt_versions(id, prompt_code, version_number, schema_version, prompt_template, model_route, status)
values ('1f000000-0000-4000-8000-000000000001','fixture.prompt',1,'1','Plantilla RLS','simulator','active');
insert into public.ai_runs(id, prompt_version_id, requested_by, project_id, work_id, purpose_code, status, cutoff_at) values
  ('1f100000-0000-4000-8000-000000000001','1f000000-0000-4000-8000-000000000001','a1000000-0000-4000-8000-000000000001',null,null,'fixture.summary','succeeded',statement_timestamp()),
  ('1f100000-0000-4000-8000-000000000002','1f000000-0000-4000-8000-000000000001','a1000000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001',null,'fixture.summary','succeeded',statement_timestamp()),
  ('1f100000-0000-4000-8000-000000000003','1f000000-0000-4000-8000-000000000001','a1000000-0000-4000-8000-000000000001','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','fixture.summary','succeeded',statement_timestamp());
insert into public.ai_evidence(id, ai_run_id, project_id, work_id, source_module, source_entity_id, source_version, excerpt_or_fact, observed_at) values
  ('1f200000-0000-4000-8000-000000000001','1f100000-0000-4000-8000-000000000001',null,null,'testing','1f210000-0000-4000-8000-000000000001',1,'Evidencia global',statement_timestamp()),
  ('1f200000-0000-4000-8000-000000000002','1f100000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null,'testing','1f210000-0000-4000-8000-000000000002',1,'Evidencia Proyecto',statement_timestamp()),
  ('1f200000-0000-4000-8000-000000000003','1f100000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','testing','1f210000-0000-4000-8000-000000000003',1,'Evidencia Trabajo',statement_timestamp());
insert into public.ai_proposals(id, ai_run_id, project_id, work_id, proposal_kind, proposal_payload, confidence, cutoff_at) values
  ('1f300000-0000-4000-8000-000000000001','1f100000-0000-4000-8000-000000000001',null,null,'fixture.summary','{}',0.8,statement_timestamp()),
  ('1f300000-0000-4000-8000-000000000002','1f100000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null,'fixture.summary','{}',0.8,statement_timestamp()),
  ('1f300000-0000-4000-8000-000000000003','1f100000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','fixture.summary','{}',0.8,statement_timestamp());

insert into public.audit_events(id, actor_process, module_code, entity_kind, entity_id, project_id, work_id, action_code, result_code, correlation_id) values
  ('20000000-0000-4000-8000-000000000001','rls_fixture','testing','fixture','20010000-0000-4000-8000-000000000001',null,null,'fixture.read','ok','20020000-0000-4000-8000-000000000001'),
  ('20000000-0000-4000-8000-000000000002','rls_fixture','testing','fixture','20010000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null,'fixture.read','ok','20020000-0000-4000-8000-000000000002'),
  ('20000000-0000-4000-8000-000000000003','rls_fixture','testing','fixture','20010000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','fixture.read','ok','20020000-0000-4000-8000-000000000003');
insert into public.outbox_events(id, event_name, event_version, aggregate_kind, aggregate_id, aggregate_version, project_id, work_id, payload, idempotency_key, correlation_id) values
  ('20100000-0000-4000-8000-000000000001','fixture.created.v1',1,'fixture','20110000-0000-4000-8000-000000000001',1,null,null,'{}','outbox_org','20120000-0000-4000-8000-000000000001'),
  ('20100000-0000-4000-8000-000000000002','fixture.created.v1',1,'fixture','20110000-0000-4000-8000-000000000002',1,'18000000-0000-4000-8000-000000000001',null,'{}','outbox_project','20120000-0000-4000-8000-000000000002'),
  ('20100000-0000-4000-8000-000000000003','fixture.created.v1',1,'fixture','20110000-0000-4000-8000-000000000003',1,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001','{}','outbox_work','20120000-0000-4000-8000-000000000003');
insert into public.idempotent_consumptions(id, consumer_name, idempotency_key, correlation_id)
values ('20200000-0000-4000-8000-000000000001','fixture.consumer','consumption_fixture','20210000-0000-4000-8000-000000000001');

-- Registro autoritativo de objetivos físicos por superficie/alcance/propietario.
create temporary table rls_fixture_targets (
  surface_name name not null,
  scope_variant text not null,
  target_id uuid not null,
  target_client_id uuid,
  target_project_id uuid,
  target_work_id uuid,
  owner_user_id uuid,
  primary key(surface_name, scope_variant, target_id)
) on commit preserve rows;

insert into rls_fixture_targets(surface_name, scope_variant, target_id) values
  ('roles','organization','11000000-0000-4000-8000-000000000001'),
  ('permissions','organization','12000000-0000-4000-8000-000000000001'),
  ('user_roles','organization',md5('user-role:a1000000-0000-4000-8000-000000000001')::uuid),
  ('role_permissions','organization','12100000-0000-4000-8000-000000000001'),
  ('specialties','organization','13000000-0000-4000-8000-000000000001'),
  ('catalogs','organization','15000000-0000-4000-8000-000000000001'),
  ('catalog_versions','organization','15100000-0000-4000-8000-000000000001'),
  ('catalog_values','organization','15200000-0000-4000-8000-000000000001'),
  ('work_types','organization',(select id from public.work_types where code='plano_catastro')),
  ('work_type_config_versions','organization','16100000-0000-4000-8000-000000000001'),
  ('work_state_definitions','organization','16200000-0000-4000-8000-000000000001'),
  ('resources','organization','14000000-0000-4000-8000-000000000001'),
  ('clients','organization','17000000-0000-4000-8000-000000000001'),
  ('client_contacts','organization','17100000-0000-4000-8000-000000000001'),
  ('client_addresses','organization','17200000-0000-4000-8000-000000000001'),
  ('ai_prompt_versions','backend','1f000000-0000-4000-8000-000000000001'),
  ('drive_delta_cursors','backend','1d200000-0000-4000-8000-000000000001'),
  ('idempotent_consumptions','backend','20200000-0000-4000-8000-000000000001');

insert into rls_fixture_targets values
  ('projects','project','18000000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('project_participants','project','18300000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('properties','project','18400000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('works','work','18100000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('work_properties','work','18500000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('work_property_values','work','18600000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('work_type_history','work','1e400000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('managements','work','19000000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('management_notes','work','19100000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('management_wait_periods','work','19200000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('tasks','work','1a000000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('task_checklists','work','1a100000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('task_checklist_items','work','1a200000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('task_dependencies','work','1a300000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('schedule_blocks','work','1b000000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('schedule_block_users','work','1b100000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('schedule_block_resources','work','1b200000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('external_procedures','work','1c000000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('external_status_events','work','1c100000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('external_query_runs','work','1c200000-0000-4000-8000-000000000001',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null);

insert into rls_fixture_targets
select 'project_memberships','project',
       md5('project-membership-owner:' || app_user_id::text)::uuid,
       null,'18000000-0000-4000-8000-000000000001',null,app_user_id
from rls_fixture_users;

insert into rls_fixture_targets
select 'work_memberships','work',
       md5('work-membership-owner:' || app_user_id::text)::uuid,
       null,'18000000-0000-4000-8000-000000000001',
       '18100000-0000-4000-8000-000000000001',app_user_id
from rls_fixture_users;

insert into rls_fixture_targets values
  ('drive_items','client','1d000000-0000-4000-8000-000000000001','17000000-0000-4000-8000-000000000001',null,null,null),
  ('drive_items','project','1d000000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('drive_items','work','1d000000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('drive_operations','client','1d100000-0000-4000-8000-000000000001','17000000-0000-4000-8000-000000000001',null,null,null),
  ('drive_operations','project','1d100000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('drive_operations','work','1d100000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('approval_targets','organization','1e000000-0000-4000-8000-000000000001',null,null,null,null),
  ('approval_targets','project','1e000000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('approval_targets','work','1e000000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('approval_requests','organization','1e100000-0000-4000-8000-000000000001',null,null,null,null),
  ('approval_requests','project','1e100000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('approval_requests','work','1e100000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('approval_decisions','organization','1e200000-0000-4000-8000-000000000001',null,null,null,null),
  ('approval_decisions','project','1e200000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('approval_decisions','work','1e200000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('approval_executions','organization','1e300000-0000-4000-8000-000000000001',null,null,null,null),
  ('approval_executions','project','1e300000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('approval_executions','work','1e300000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('ai_runs','organization','1f100000-0000-4000-8000-000000000001',null,null,null,null),
  ('ai_runs','project','1f100000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('ai_runs','work','1f100000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('ai_evidence','organization','1f200000-0000-4000-8000-000000000001',null,null,null,null),
  ('ai_evidence','project','1f200000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('ai_evidence','work','1f200000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('ai_proposals','organization','1f300000-0000-4000-8000-000000000001',null,null,null,null),
  ('ai_proposals','project','1f300000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('ai_proposals','work','1f300000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('audit_events','organization','20000000-0000-4000-8000-000000000001',null,null,null,null),
  ('audit_events','project','20000000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('audit_events','work','20000000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null),
  ('outbox_events','organization','20100000-0000-4000-8000-000000000001',null,null,null,null),
  ('outbox_events','project','20100000-0000-4000-8000-000000000002',null,'18000000-0000-4000-8000-000000000001',null,null),
  ('outbox_events','work','20100000-0000-4000-8000-000000000003',null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',null);

-- Superficies de propietario propio/ajeno.
insert into rls_fixture_targets
select 'app_users','self',app_user_id,null,null,null,app_user_id from rls_fixture_users;
insert into rls_fixture_targets
select 'user_specialties','self',md5('specialty:' || app_user_id::text)::uuid,null,null,null,app_user_id from rls_fixture_users;
insert into rls_fixture_targets
select 'user_devices','self',md5('device:' || app_user_id::text)::uuid,null,null,null,app_user_id from rls_fixture_users;
insert into rls_fixture_targets
select 'notification_preferences','self',md5('preference:' || app_user_id::text)::uuid,null,null,null,app_user_id from rls_fixture_users;
insert into rls_fixture_targets
select 'push_subscriptions','self',md5('push:' || app_user_id::text)::uuid,null,null,null,app_user_id from rls_fixture_users;
insert into rls_fixture_targets
select 'notifications','organization',md5('notification-org:' || app_user_id::text)::uuid,null,null,null,app_user_id from rls_fixture_users;
insert into rls_fixture_targets
select 'notifications','project',md5('notification-project:' || app_user_id::text)::uuid,null,'18000000-0000-4000-8000-000000000001',null,app_user_id from rls_fixture_users;
insert into rls_fixture_targets
select 'notifications','work',md5('notification-work:' || app_user_id::text)::uuid,null,'18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001',app_user_id from rls_fixture_users;

-- Construye INSERT VALUES con literales tipados a partir de un fixture válido.
create or replace function pg_temp.rls_build_insert_sql(
  p_surface name,
  p_template_id uuid,
  p_new_id uuid,
  p_actor_user_id uuid default null,
  p_approval_request_id uuid default null,
  p_drive_status text default null,
  p_drive_result_metadata jsonb default null
)
returns text
language plpgsql
as $builder$
declare
  column_row record;
  literal_value text;
  column_list text := '';
  value_list text := '';
  suffix text := substr(replace(p_new_id::text, '-', ''), 1, 12);
begin
  for column_row in
    select a.attname,
           format_type(a.atttypid, a.atttypmod) as data_type
    from pg_attribute a
    where a.attrelid = format('public.%I', p_surface)::regclass
      and a.attnum > 0
      and not a.attisdropped
      and a.attgenerated = ''
    order by a.attnum
  loop
    execute format(
      'select quote_nullable(%I::text) from public.%I where id = $1',
      column_row.attname, p_surface
    ) into literal_value using p_template_id;

    if column_row.attname = 'id' then
      literal_value := quote_literal(p_new_id::text);
    elsif p_surface = 'app_users' and column_row.attname = 'auth_subject' then
      literal_value := quote_literal(p_new_id::text);
    elsif p_surface = 'app_users' and column_row.attname = 'email' then
      literal_value := quote_literal(suffix || '@insert.rls.test');
    elsif column_row.attname in (
      'code', 'internal_code', 'prompt_code', 'execution_key', 'idempotency_key',
      'drive_id', 'drive_item_id', 'source_fingerprint', 'deduplication_key',
      'endpoint_hash'
    ) and column_row.data_type in ('text', 'character varying') then
      literal_value := quote_literal('fixture_' || suffix);
    elsif p_surface = 'approval_targets' and column_row.attname = 'target_entity_id' then
      literal_value := quote_literal(p_new_id::text);
    elsif p_surface = 'approval_targets' and column_row.attname = 'registered_by'
      and p_actor_user_id is not null then
      literal_value := quote_literal(p_actor_user_id::text);
    elsif p_surface = 'approval_requests' and column_row.attname = 'requested_by'
      and p_actor_user_id is not null then
      literal_value := quote_literal(p_actor_user_id::text);
    elsif p_surface = 'drive_operations' and column_row.attname = 'requested_by'
      and p_actor_user_id is not null then
      literal_value := quote_literal(p_actor_user_id::text);
    elsif p_surface = 'drive_operations' and column_row.attname = 'status'
      and p_drive_status is not null then
      literal_value := quote_literal(p_drive_status);
    elsif p_surface = 'drive_operations' and column_row.attname = 'result_metadata'
      and p_drive_result_metadata is not null then
      literal_value := quote_literal(p_drive_result_metadata::text);
    elsif p_surface = 'management_notes' and column_row.attname = 'logical_note_id' then
      literal_value := quote_literal(p_new_id::text);
    elsif column_row.attname = 'version_number' then
      literal_value := quote_literal('999');
    elsif p_surface = 'work_type_history' and column_row.attname = 'previous_work_version' then
      literal_value := quote_literal('999');
    elsif p_surface = 'work_types' and column_row.attname in ('supports_apt', 'supports_siri') then
      literal_value := quote_literal('false');
    elsif p_surface = 'role_permissions' and column_row.attname = 'permission_id' then
      literal_value := quote_literal('12000000-0000-4000-8000-000000000002');
    elsif p_surface in ('project_memberships', 'work_memberships')
      and column_row.attname = 'assigned_at' then
      literal_value := quote_literal((statement_timestamp() - interval '1 hour')::text);
    elsif p_surface in ('project_memberships', 'work_memberships')
      and column_row.attname = 'ended_at' then
      literal_value := quote_literal(statement_timestamp()::text);
    elsif p_surface in ('project_memberships', 'work_memberships')
      and column_row.attname = 'ended_by' then
      literal_value := quote_literal('a1000000-0000-4000-8000-000000000001');
    elsif p_surface in ('project_memberships', 'work_memberships')
      and column_row.attname = 'end_reason' then
      literal_value := quote_literal('Fixture insert RLS');
    elsif p_surface = 'user_roles' and column_row.attname = 'user_id' then
      literal_value := quote_literal('a1000000-0000-4000-8000-00000000000f');
    elsif p_surface = 'user_specialties' and column_row.attname = 'specialty_id' then
      literal_value := quote_literal('13000000-0000-4000-8000-000000000002');
    elsif p_surface = 'schedule_block_users' and column_row.attname = 'user_id' then
      literal_value := quote_literal('a1000000-0000-4000-8000-00000000000f');
    elsif p_surface = 'schedule_block_resources' and column_row.attname = 'resource_id' then
      literal_value := quote_literal('14000000-0000-4000-8000-000000000002');
    elsif p_surface = 'work_properties' and column_row.attname = 'property_id' then
      literal_value := quote_literal('18400000-0000-4000-8000-000000000002');
    elsif p_surface = 'work_property_values' and column_row.attname = 'property_code' then
      literal_value := quote_literal('fixture.' || suffix);
    elsif p_surface = 'task_dependencies' and column_row.attname = 'predecessor_task_id' then
      literal_value := quote_literal('1a000000-0000-4000-8000-000000000003');
    elsif p_surface = 'task_dependencies' and column_row.attname = 'successor_task_id' then
      literal_value := quote_literal('1a000000-0000-4000-8000-000000000004');
    elsif p_surface = 'notification_preferences' and column_row.attname = 'category' then
      literal_value := quote_literal('schedule');
    elsif p_surface = 'approval_decisions' and column_row.attname = 'decided_by' then
      literal_value := quote_literal(coalesce(
        p_actor_user_id,
        'a1000000-0000-4000-8000-00000000000f'::uuid
      )::text);
    elsif p_surface = 'approval_decisions' and column_row.attname = 'approval_request_id'
      and p_approval_request_id is not null then
      literal_value := quote_literal(p_approval_request_id::text);
    elsif p_surface = 'approval_executions' and column_row.attname = 'approval_request_id' then
      literal_value := quote_literal(case
        when p_template_id = '1e300000-0000-4000-8000-000000000001' then '1e100000-0000-4000-8000-000000000004'
        when p_template_id = '1e300000-0000-4000-8000-000000000002' then '1e100000-0000-4000-8000-000000000005'
        else '1e100000-0000-4000-8000-000000000006'
      end);
    end if;

    column_list := column_list || case when column_list = '' then '' else ', ' end
      || quote_ident(column_row.attname);
    value_list := value_list || case when value_list = '' then '' else ', ' end
      || coalesce(literal_value, 'NULL') || '::' || column_row.data_type;
  end loop;

  return format(
    'insert into public.%I (%s) values (%s)',
    p_surface, column_list, value_list
  );
end;
$builder$;

create or replace function pg_temp.rls_expected_access(
  p_surface name,
  p_operation text,
  p_role text,
  p_scope_variant text,
  p_scope_case text,
  p_ownership_case text
)
returns boolean
language plpgsql
immutable
as $expected$
declare
  project_read boolean := p_role in ('administrator','coordinator','read_only')
    or (p_role = 'technician' and p_scope_case in ('assigned_project','sibling_work'));
  project_write boolean := p_role in ('administrator','coordinator')
    or (p_role = 'technician' and p_scope_case in ('assigned_project','sibling_work'));
  own_row boolean := p_ownership_case <> 'other_user';
begin
  if p_operation = 'DELETE' then return false; end if;

  if p_operation = 'SELECT' then
    if p_surface in ('ai_prompt_versions','drive_delta_cursors','external_query_runs','outbox_events','idempotent_consumptions') then return false; end if;
    if p_surface in ('roles','permissions','specialties','catalogs','catalog_versions','catalog_values','work_types','work_type_config_versions','work_state_definitions','resources') then return true; end if;
    if p_surface = 'app_users' then return p_role in ('administrator','coordinator') or own_row; end if;
    if p_surface in ('user_roles','role_permissions') then return p_role = 'administrator'; end if;
    if p_surface = 'user_specialties' then return p_role in ('administrator','coordinator') or own_row; end if;
    if p_surface = 'user_devices' then return own_row; end if;
    if p_surface in ('project_memberships','work_memberships') then return p_role in ('administrator','coordinator') or own_row; end if;
    if p_surface in ('clients','client_contacts','client_addresses') then return p_role in ('administrator','coordinator'); end if;
    if p_surface in ('notification_preferences','push_subscriptions') then return own_row; end if;
    if p_surface = 'notifications' then return own_row and (p_scope_variant = 'organization' or project_read); end if;
    if p_surface = 'audit_events' then return p_role = 'administrator'; end if;
    if p_surface in ('drive_items','drive_operations') and p_scope_variant = 'client' then return p_role in ('administrator','coordinator'); end if;
    if p_surface in ('approval_targets','approval_requests','approval_decisions','approval_executions','ai_runs','ai_evidence','ai_proposals')
       and p_scope_variant = 'organization' then return p_role in ('administrator','coordinator'); end if;
    return project_read;
  end if;

  if p_operation = 'INSERT' then
    if p_surface in ('roles','permissions','specialties','catalogs','catalog_versions','catalog_values','work_types','work_type_config_versions','work_state_definitions') then return p_role = 'administrator'; end if;
    if p_surface = 'resources' then return p_role in ('administrator','coordinator'); end if;
    if p_surface in ('app_users','user_roles','role_permissions','user_specialties') then return p_role = 'administrator'; end if;
    if p_surface in ('user_devices','notification_preferences','push_subscriptions') then return own_row; end if;
    if p_surface in ('project_memberships','work_memberships','clients','client_contacts','client_addresses','projects') then return p_role in ('administrator','coordinator'); end if;
    if p_surface = 'works' then return p_role in ('administrator','coordinator'); end if;
    if p_surface in ('project_participants','properties','work_properties','work_property_values','managements','management_notes','management_wait_periods','tasks','task_checklists','task_checklist_items','task_dependencies','schedule_blocks','schedule_block_users','schedule_block_resources','work_type_history') then return project_write; end if;
    if p_surface in ('drive_items','drive_operations') then return case when p_scope_variant='client' then p_role in ('administrator','coordinator') else project_write end; end if;
    if p_surface = 'approval_targets' then return case when p_scope_variant='organization' then p_role in ('administrator','coordinator') else project_write end; end if;
    if p_surface = 'approval_requests' then return case when p_scope_variant='organization' then p_role in ('administrator','coordinator') else project_write end; end if;
    if p_surface = 'approval_decisions' then return p_role in ('administrator','coordinator'); end if;
    return false;
  end if;

  if p_operation = 'UPDATE' then
    if p_surface in ('roles','permissions','specialties','catalogs','catalog_versions','catalog_values','work_types','work_type_config_versions','work_state_definitions') then return p_role = 'administrator'; end if;
    if p_surface = 'resources' then return p_role in ('administrator','coordinator'); end if;
    if p_surface = 'app_users' then return p_role = 'administrator' or own_row; end if;
    if p_surface in ('user_roles','role_permissions','user_specialties') then return p_role = 'administrator'; end if;
    if p_surface in ('user_devices','notification_preferences','push_subscriptions') then return own_row; end if;
    if p_surface in ('project_memberships','work_memberships','clients','client_contacts','client_addresses','projects') then return p_role in ('administrator','coordinator'); end if;
    if p_surface = 'works' then return project_write; end if;
    if p_surface in ('project_participants','properties','work_properties','work_property_values','managements','management_wait_periods','tasks','task_checklists','task_checklist_items','task_dependencies','schedule_blocks','schedule_block_users','schedule_block_resources') then return project_write; end if;
    if p_surface = 'drive_items' then return case when p_scope_variant='client' then p_role in ('administrator','coordinator') else project_write end; end if;
    if p_surface = 'drive_operations' then return false; end if;
    if p_surface = 'notifications' then return own_row and (p_scope_variant = 'organization' or project_read); end if;
    if p_surface = 'approval_requests' then return false; end if;
    return false;
  end if;
  return false;
end;
$expected$;

-- Casos base: las cuatro operaciones, cuatro roles, todos los alcances y propiedad.
with actors as (
  select * from rls_fixture_users where access_case = 'primary'
), required as (
  select
    m.surface_name,
    s.scope_variant,
    a.app_role,
    a.auth_subject,
    a.app_user_id,
    o.operation,
    own.ownership_case,
    case
      when a.app_role = 'technician' and m.surface_name = 'projects' and o.operation = 'INSERT' then 'unassigned'
      when a.app_role = 'technician' and s.scope_variant in ('project','work') then 'assigned_project'
      else 'global'
    end as scope_case
  from rls_test_surface_manifest m
  cross join lateral unnest(m.supported_scopes) s(scope_variant)
  cross join actors a
  cross join (values ('SELECT'),('INSERT'),('UPDATE'),('DELETE')) o(operation)
  cross join lateral unnest(
    case when m.requires_self_ownership
      then array['self','other_user']::text[]
      else array['not_applicable']::text[] end
  ) own(ownership_case)
  where m.surface_kind = 'table'
    and not (m.surface_name = 'app_users' and o.operation = 'INSERT' and own.ownership_case = 'self')
), resolved as (
  select r.*, t.target_id as template_id,
         case when r.operation='INSERT' then md5(
           concat_ws(':','insert',r.surface_name,r.scope_variant,r.app_role,r.ownership_case,r.scope_case)
         )::uuid else t.target_id end as target_id,
         t.target_client_id, t.target_project_id, t.target_work_id
  from required r
  join rls_fixture_targets t
    on t.surface_name = r.surface_name
   and t.scope_variant = r.scope_variant
   and (
     r.ownership_case = 'not_applicable'
     or (r.ownership_case = 'self' and t.owner_user_id = r.app_user_id)
     or (r.ownership_case = 'other_user' and t.owner_user_id = 'a1000000-0000-4000-8000-00000000000f')
   )
), decided as (
  select r.*, pg_temp.rls_expected_access(
    surface_name, operation, app_role, scope_variant, scope_case, ownership_case
  ) as allowed
  from resolved r
)
insert into rls_test_cases(
  case_id, surface_name, operation, app_role, auth_subject,
  scope_variant, ownership_case, scope_case, target_id,
  target_client_id, target_project_id, target_work_id,
  command_sql, expected_access, expected_kind, expected_rows,
  expected_ids, expected_sqlstate
)
select
  concat_ws('__','base',surface_name,scope_variant,app_role,lower(operation),ownership_case),
  surface_name, operation, app_role, auth_subject,
  scope_variant, ownership_case, scope_case, target_id,
  target_client_id,
  case when operation='INSERT' and surface_name='projects' then target_id else target_project_id end,
  case when operation='INSERT' and surface_name='works' then target_id else target_work_id end,
  case operation
    when 'SELECT' then format('select id from public.%I where id = %L',surface_name,target_id)
    when 'INSERT' then pg_temp.rls_build_insert_sql(surface_name,template_id,target_id,app_user_id)
    when 'UPDATE' then format('update public.%I set id = id where id = %L',surface_name,target_id)
    when 'DELETE' then format('delete from public.%I where id = %L',surface_name,target_id)
  end,
  allowed,
  case
    when operation='DELETE' then 'sqlstate'
    when operation='INSERT' and not allowed then 'sqlstate'
    else 'row_count'
  end,
  case
    when operation='DELETE' or (operation='INSERT' and not allowed) then null
    when allowed then 1 else 0
  end,
  case
    when operation='SELECT' and allowed then array[target_id]::uuid[]
    when operation='SELECT' then array[]::uuid[]
    else null
  end,
  case
    when operation='DELETE' or (operation='INSERT' and not allowed) then '42501'
    else null
  end
from decided;

-- Los campos de autoría de las aprobaciones no pueden atribuirse a otra cuenta.
with actors as (
  select * from rls_fixture_users where access_case = 'primary'
), candidates as (
  select
    m.surface_name,
    s.scope_variant,
    a.app_role,
    a.auth_subject,
    case
      when a.app_role = 'technician' then 'assigned_project'
      else 'global'
    end as scope_case,
    t.target_id as template_id,
    t.target_project_id,
    t.target_work_id
  from rls_test_surface_manifest m
  cross join lateral unnest(m.supported_scopes) s(scope_variant)
  cross join actors a
  join rls_fixture_targets t
    on t.surface_name = m.surface_name
   and t.scope_variant = s.scope_variant
  where m.surface_name in ('approval_targets', 'approval_requests', 'approval_decisions')
), allowed_inserts as (
  select c.*,
         md5(concat_ws(':','approval_actor_spoof',surface_name,scope_variant,app_role))::uuid as target_id
  from candidates c
  where pg_temp.rls_expected_access(
    surface_name, 'INSERT', app_role, scope_variant, scope_case, 'not_applicable'
  )
)
insert into rls_test_cases(
  case_id, surface_name, operation, app_role, auth_subject,
  scope_variant, ownership_case, scope_case, target_id,
  target_project_id, target_work_id, command_sql, expected_access,
  expected_kind, expected_sqlstate
)
select
  concat_ws('__','approval_actor_spoof',surface_name,scope_variant,app_role),
  surface_name, 'INSERT', app_role, auth_subject,
  scope_variant, 'not_applicable', scope_case, target_id,
  target_project_id, target_work_id,
  pg_temp.rls_build_insert_sql(
    surface_name, template_id, target_id,
    'a1000000-0000-4000-8000-00000000000e'
  ),
  false, 'sqlstate', '42501'
from allowed_inserts;

-- La separación de funciones impide que Administrador o Coordinador decidan
-- una solicitud creada por su propia cuenta.
with actors(app_role, auth_subject, app_user_id) as (values
  ('administrator'::text,'b1000000-0000-4000-8000-000000000001'::uuid,'a1000000-0000-4000-8000-000000000001'::uuid),
  ('coordinator','b1000000-0000-4000-8000-000000000002','a1000000-0000-4000-8000-000000000002')
), scopes(scope_variant, template_id, target_project_id, target_work_id) as (values
  ('organization'::text,'1e200000-0000-4000-8000-000000000001'::uuid,null::uuid,null::uuid),
  ('project','1e200000-0000-4000-8000-000000000002','18000000-0000-4000-8000-000000000001',null),
  ('work','1e200000-0000-4000-8000-000000000003','18000000-0000-4000-8000-000000000001','18100000-0000-4000-8000-000000000001')
), cases as (
  select
    a.*,
    s.*,
    md5(concat_ws(':','approval_self_decision',a.app_role,s.scope_variant))::uuid as target_id,
    case a.app_role
      when 'administrator' then case s.scope_variant
        when 'organization' then '1e100000-0000-4000-8000-000000000007'::uuid
        when 'project' then '1e100000-0000-4000-8000-000000000008'::uuid
        else '1e100000-0000-4000-8000-000000000009'::uuid end
      else case s.scope_variant
        when 'organization' then '1e100000-0000-4000-8000-00000000000a'::uuid
        when 'project' then '1e100000-0000-4000-8000-00000000000b'::uuid
        else '1e100000-0000-4000-8000-00000000000c'::uuid end
    end as approval_request_id
  from actors a cross join scopes s
)
insert into rls_test_cases(
  case_id, surface_name, operation, app_role, auth_subject,
  scope_variant, ownership_case, scope_case, target_id,
  target_project_id, target_work_id, command_sql, expected_access,
  expected_kind, expected_sqlstate
)
select
  concat_ws('__','approval_self_decision',app_role,scope_variant),
  'approval_decisions', 'INSERT', app_role, auth_subject,
  scope_variant, 'not_applicable', 'global', target_id,
  target_project_id, target_work_id,
  pg_temp.rls_build_insert_sql(
    'approval_decisions', template_id, target_id, app_user_id, approval_request_id
  ),
  false, 'sqlstate', '42501'
from cases;

-- Regresiones específicas de columnas propias y estados autoritativos.
insert into rls_test_cases(
  case_id, surface_name, operation, app_role, auth_subject,
  scope_variant, ownership_case, scope_case, target_id,
  command_sql, expected_access, expected_kind, expected_rows, expected_sqlstate
) values
  (
    'self_profile__technician__accent_positive', 'app_users', 'UPDATE',
    'technician', 'b1000000-0000-4000-8000-000000000003',
    'self', 'self', 'global', 'a1000000-0000-4000-8000-000000000003',
    'update public.app_users set preferred_accent = ''azul'' where id = ''a1000000-0000-4000-8000-000000000003''',
    true, 'row_count', 1, null
  ),
  (
    'self_profile__technician__authorization_negative', 'app_users', 'UPDATE',
    'technician', 'b1000000-0000-4000-8000-000000000003',
    'self', 'self', 'global', 'a1000000-0000-4000-8000-000000000003',
    'update public.app_users set is_active = false where id = ''a1000000-0000-4000-8000-000000000003''',
    false, 'sqlstate', null, '42501'
  );

with own_notification as (
  select target_id
  from rls_fixture_targets
  where surface_name = 'notifications'
    and scope_variant = 'organization'
    and owner_user_id = 'a1000000-0000-4000-8000-000000000003'
)
insert into rls_test_cases(
  case_id, surface_name, operation, app_role, auth_subject,
  scope_variant, ownership_case, scope_case, target_id,
  command_sql, expected_access, expected_kind, expected_rows, expected_sqlstate
)
select
  'self_notification__technician__read_positive', 'notifications', 'UPDATE',
  'technician', 'b1000000-0000-4000-8000-000000000003'::uuid,
  'organization', 'self', 'global', target_id,
  format('update public.notifications set read_at = statement_timestamp() where id = %L', target_id),
  true, 'row_count', 1, null
from own_notification
union all
select
  'self_notification__technician__payload_negative', 'notifications', 'UPDATE',
  'technician', 'b1000000-0000-4000-8000-000000000003'::uuid,
  'organization', 'self', 'global', target_id,
  format('update public.notifications set body = %L where id = %L', 'Payload alterado', target_id),
  false, 'sqlstate', null, '42501'
from own_notification;

insert into rls_test_cases(
  case_id, surface_name, operation, app_role, auth_subject,
  scope_variant, ownership_case, scope_case, target_id,
  target_project_id, command_sql, expected_access, expected_kind, expected_rows
) values
  (
    'drive_operation__technician__result_forgery_negative', 'drive_operations', 'UPDATE',
    'technician', 'b1000000-0000-4000-8000-000000000003',
    'project', 'not_applicable', 'assigned_project',
    '1d100000-0000-4000-8000-000000000002',
    '18000000-0000-4000-8000-000000000001',
    'update public.drive_operations set status = ''succeeded'', completed_at = statement_timestamp(), result_metadata = ''{"forged":true}''::jsonb where id = ''1d100000-0000-4000-8000-000000000002''',
    false, 'row_count', 0
  ),
  (
    'drive_operation__technician__destructive_approval_negative', 'drive_operations', 'UPDATE',
    'technician', 'b1000000-0000-4000-8000-000000000003',
    'project', 'not_applicable', 'assigned_project',
    '1d100000-0000-4000-8000-000000000002',
    '18000000-0000-4000-8000-000000000001',
    'update public.drive_operations set operation_kind = ''trash_empty_folder'', status = ''approved'', reason = ''Intento sintético'' where id = ''1d100000-0000-4000-8000-000000000002''',
    false, 'row_count', 0
  );

with target as (
  select target_id as template_id, target_project_id
  from rls_fixture_targets
  where surface_name = 'drive_operations'
    and scope_variant = 'project'
), cases(case_suffix, target_id, actor_user_id, drive_status, result_metadata) as (values
  ('approved_status'::text, md5('drive_insert:approved_status')::uuid,
   'a1000000-0000-4000-8000-000000000003'::uuid, 'approved'::text, null::jsonb),
  ('other_requester', md5('drive_insert:other_requester')::uuid,
   'a1000000-0000-4000-8000-00000000000e'::uuid, null, null),
  ('forged_result', md5('drive_insert:forged_result')::uuid,
   'a1000000-0000-4000-8000-000000000003'::uuid, null, '{"forged":true}'::jsonb)
)
insert into rls_test_cases(
  case_id, surface_name, operation, app_role, auth_subject,
  scope_variant, ownership_case, scope_case, target_id,
  target_project_id, command_sql, expected_access, expected_kind, expected_sqlstate
)
select
  'drive_operation_insert__technician__' || case_suffix,
  'drive_operations', 'INSERT', 'technician',
  'b1000000-0000-4000-8000-000000000003',
  'project', 'not_applicable', 'assigned_project', c.target_id,
  t.target_project_id,
  pg_temp.rls_build_insert_sql(
    'drive_operations', t.template_id, c.target_id, c.actor_user_id,
    null, c.drive_status, c.result_metadata
  ),
  false, 'sqlstate', '42501'
from target t cross join cases c;

-- Técnico con una asignación aislada a Trabajo: nunca obtiene alcance.
with actor as (
  select * from rls_fixture_users where access_case='work_only'
), required as (
  select m.surface_name, 'work'::text scope_variant, a.app_role, a.auth_subject,
         o.operation, 'not_applicable'::text ownership_case,
         case when m.surface_name='works' and o.operation='INSERT'
           then 'unassigned' else 'assigned_work' end::text scope_case
  from rls_test_surface_manifest m cross join actor a
  cross join (values ('SELECT'),('INSERT'),('UPDATE'),('DELETE')) o(operation)
  where m.surface_kind='table' and 'work'=any(m.supported_scopes)
    and not m.requires_self_ownership
), resolved as (
  select r.*, t.target_id template_id,
         case when operation='INSERT' then md5(concat_ws(':','work_only',surface_name,lower(operation)))::uuid else t.target_id end target_id,
         t.target_project_id,t.target_work_id
  from required r join rls_fixture_targets t using(surface_name,scope_variant)
)
insert into rls_test_cases(
  case_id,surface_name,operation,app_role,auth_subject,scope_variant,ownership_case,scope_case,
  target_id,target_project_id,target_work_id,command_sql,expected_access,expected_kind,
  expected_rows,expected_ids,expected_sqlstate
)
select concat_ws('__','work_only',surface_name,lower(operation)),surface_name,operation,app_role,auth_subject,
  scope_variant,ownership_case,scope_case,target_id,target_project_id,
  case when operation='INSERT' and surface_name='works' then target_id else target_work_id end,
  case operation
    when 'SELECT' then format('select id from public.%I where id = %L',surface_name,target_id)
    when 'INSERT' then pg_temp.rls_build_insert_sql(surface_name,template_id,target_id)
    when 'UPDATE' then format('update public.%I set id = id where id = %L',surface_name,target_id)
    when 'DELETE' then format('delete from public.%I where id = %L',surface_name,target_id)
  end,
  false,
  case when operation in ('INSERT','DELETE') then 'sqlstate' else 'row_count' end,
  case when operation in ('INSERT','DELETE') then null else 0 end,
  case when operation='SELECT' then array[]::uuid[] else null end,
  case when operation in ('INSERT','DELETE') then '42501' else null end
from resolved;

-- Técnico sin asignación: negativos completos por Proyecto/Trabajo.
with actor as (
  select * from rls_fixture_users where access_case='unassigned'
), required as (
  select m.surface_name,s.scope_variant,a.app_role,a.auth_subject,o.operation,
         own.ownership_case,'unassigned'::text scope_case
  from rls_test_surface_manifest m
  cross join lateral unnest(m.supported_scopes) s(scope_variant)
  cross join actor a cross join (values ('SELECT'),('INSERT'),('UPDATE'),('DELETE')) o(operation)
  cross join lateral unnest(
    case when m.requires_self_ownership
      then array['self','other_user']::text[]
      else array['not_applicable']::text[] end
  ) own(ownership_case)
  where m.surface_kind='table' and s.scope_variant in ('project','work')
    and (not m.requires_self_ownership or m.surface_name in ('project_memberships','work_memberships'))
), resolved as (
  select r.*,t.target_id template_id,
         case when r.operation='INSERT' then md5(concat_ws(':','unassigned',r.surface_name,r.scope_variant,lower(r.operation),r.ownership_case))::uuid else t.target_id end target_id,
         t.target_project_id,t.target_work_id
  from required r join rls_fixture_targets t
    on t.surface_name=r.surface_name and t.scope_variant=r.scope_variant
   and (
     r.ownership_case='not_applicable'
     or (r.ownership_case='self' and t.owner_user_id='a1000000-0000-4000-8000-00000000000e')
     or (r.ownership_case='other_user' and t.owner_user_id='a1000000-0000-4000-8000-00000000000f')
   )
)
insert into rls_test_cases(
  case_id,surface_name,operation,app_role,auth_subject,scope_variant,ownership_case,scope_case,
  target_id,target_project_id,target_work_id,command_sql,expected_access,expected_kind,
  expected_rows,expected_ids,expected_sqlstate
)
select concat_ws('__','unassigned',surface_name,scope_variant,lower(operation),ownership_case),surface_name,operation,app_role,auth_subject,
  scope_variant,ownership_case,scope_case,target_id,
  case when operation='INSERT' and surface_name='projects' then target_id else target_project_id end,
  case when operation='INSERT' and surface_name='works' then target_id else target_work_id end,
  case operation
    when 'SELECT' then format('select id from public.%I where id = %L',surface_name,target_id)
    when 'INSERT' then pg_temp.rls_build_insert_sql(surface_name,template_id,target_id)
    when 'UPDATE' then format('update public.%I set id = id where id = %L',surface_name,target_id)
    when 'DELETE' then format('delete from public.%I where id = %L',surface_name,target_id)
  end,
  surface_name in ('project_memberships','work_memberships')
    and operation='SELECT' and ownership_case='self',
  case when operation in ('INSERT','DELETE') then 'sqlstate' else 'row_count' end,
  case when operation in ('INSERT','DELETE') then null
       when surface_name in ('project_memberships','work_memberships')
         and operation='SELECT' and ownership_case='self' then 1 else 0 end,
  case when operation='SELECT' and surface_name in ('project_memberships','work_memberships')
         and ownership_case='self' then array[target_id]::uuid[]
       when operation='SELECT' then array[]::uuid[] else null end,
  case when operation in ('INSERT','DELETE') then '42501' else null end
from resolved;

-- Notificaciones propias/ajenas ligadas a Proyecto/Trabajo sin asignación.
with actor as (
  select * from rls_fixture_users where access_case='unassigned'
), required as (
  select s.scope_variant,a.app_role,a.auth_subject,a.app_user_id,o.operation,own.ownership_case
  from (values ('project'),('work')) s(scope_variant)
  cross join actor a
  cross join (values ('SELECT'),('INSERT'),('UPDATE'),('DELETE')) o(operation)
  cross join (values ('self'),('other_user')) own(ownership_case)
), resolved as (
  select r.*,t.target_id template_id,
         case when r.operation='INSERT' then md5(concat_ws(':','unassigned_notification',r.scope_variant,lower(r.operation),r.ownership_case))::uuid else t.target_id end target_id,
         t.target_project_id,t.target_work_id
  from required r join rls_fixture_targets t
    on t.surface_name='notifications' and t.scope_variant=r.scope_variant
   and (
     (r.ownership_case='self' and t.owner_user_id=r.app_user_id)
     or (r.ownership_case='other_user' and t.owner_user_id='a1000000-0000-4000-8000-00000000000f')
   )
)
insert into rls_test_cases(
  case_id,surface_name,operation,app_role,auth_subject,scope_variant,ownership_case,scope_case,
  target_id,target_project_id,target_work_id,command_sql,expected_access,expected_kind,
  expected_rows,expected_ids,expected_sqlstate
)
select concat_ws('__','unassigned','notifications',scope_variant,lower(operation),ownership_case),
  'notifications',operation,app_role,auth_subject,scope_variant,ownership_case,'unassigned',
  target_id,target_project_id,target_work_id,
  case operation
    when 'SELECT' then format('select id from public.notifications where id = %L',target_id)
    when 'INSERT' then pg_temp.rls_build_insert_sql('notifications',template_id,target_id)
    when 'UPDATE' then format('update public.notifications set id = id where id = %L',target_id)
    when 'DELETE' then format('delete from public.notifications where id = %L',target_id)
  end,
  false,
  case when operation in ('INSERT','DELETE') then 'sqlstate' else 'row_count' end,
  case when operation in ('INSERT','DELETE') then null else 0 end,
  case when operation='SELECT' then array[]::uuid[] else null end,
  case when operation in ('INSERT','DELETE') then '42501' else null end
from resolved;

-- Trabajo objetivo sin membresía directa, pero dentro del Proyecto asignado: permitido.
insert into rls_test_cases(
  case_id,surface_name,operation,app_role,auth_subject,scope_variant,ownership_case,scope_case,
  target_id,target_project_id,target_work_id,command_sql,expected_access,expected_kind,expected_rows,expected_ids
)
select concat_ws('__','sibling',m.surface_name,'select',own.ownership_case),m.surface_name,'SELECT','technician',
  'b1000000-0000-4000-8000-000000000003','work',own.ownership_case,'sibling_work',
  t.target_id,t.target_project_id,t.target_work_id,
  format('select id from public.%I where id = %L',m.surface_name,t.target_id),
  not m.requires_self_ownership or own.ownership_case='self','row_count',
  case when not m.requires_self_ownership or own.ownership_case='self' then 1 else 0 end,
  case when not m.requires_self_ownership or own.ownership_case='self'
    then array[t.target_id]::uuid[] else array[]::uuid[] end
from rls_test_surface_manifest m
cross join lateral unnest(
  case when m.requires_self_ownership
    then array['self','other_user']::text[]
    else array['not_applicable']::text[] end
) own(ownership_case)
join rls_fixture_targets t
  on t.surface_name=m.surface_name and t.scope_variant='work'
 and (
   not m.requires_self_ownership
   or (own.ownership_case='self' and t.owner_user_id='a1000000-0000-4000-8000-000000000003')
   or (own.ownership_case='other_user' and t.owner_user_id='a1000000-0000-4000-8000-00000000000f')
 )
where m.surface_kind='table' and 'work'=any(m.supported_scopes)
  and m.client_read_expected
  and m.surface_name <> 'work_memberships';

-- Referencias indirectas no conceden alcance al Técnico sin Proyecto.
insert into rls_test_cases(
  case_id,surface_name,operation,app_role,auth_subject,scope_variant,ownership_case,scope_case,
  target_id,target_project_id,target_work_id,command_sql,expected_access,expected_kind,expected_rows,expected_ids
)
select concat_ws('__','indirect',m.surface_name,'select'),m.surface_name,'SELECT','technician',
  'b1000000-0000-4000-8000-00000000000e','work',
  case when manifest.requires_self_ownership then 'self' else 'not_applicable' end,
  'indirect_reference',t.target_id,t.target_project_id,t.target_work_id,
  format('select id from public.%I where id = %L',m.surface_name,t.target_id),
  false,'row_count',0,array[]::uuid[]
from (values
  ('task_dependencies'::name),('notifications'::name),('approval_targets'::name),
  ('drive_items'::name),('ai_evidence'::name)
) m(surface_name)
join rls_test_surface_manifest manifest on manifest.surface_name=m.surface_name
join rls_fixture_targets t
  on t.surface_name=m.surface_name and t.scope_variant='work'
 and (not manifest.requires_self_ownership or t.owner_user_id='a1000000-0000-4000-8000-00000000000e');

-- Revocados y no preautorizados: SELECT denegado en toda superficie/alcance.
with actors as (
  select * from rls_fixture_users where access_case in ('revoked','unauthorized')
), required as (
  select m.surface_name,s.scope_variant,a.app_role,a.auth_subject,a.app_user_id,a.access_case,
         own.ownership_case
  from rls_test_surface_manifest m
  cross join lateral unnest(m.supported_scopes) s(scope_variant)
  cross join actors a
  cross join lateral unnest(
    case when m.requires_self_ownership then array['self','other_user']::text[]
         else array['not_applicable']::text[] end
  ) own(ownership_case)
  where m.surface_kind='table'
), resolved as (
  select r.*,t.target_id,t.target_client_id,t.target_project_id,t.target_work_id
  from required r join rls_fixture_targets t
    on t.surface_name=r.surface_name and t.scope_variant=r.scope_variant
   and (
     r.ownership_case='not_applicable'
     or (r.ownership_case='self' and t.owner_user_id=r.app_user_id)
     or (r.ownership_case='other_user' and t.owner_user_id='a1000000-0000-4000-8000-00000000000f')
   )
)
insert into rls_test_cases(
  case_id,surface_name,operation,app_role,auth_subject,scope_variant,ownership_case,scope_case,
  target_id,target_client_id,target_project_id,target_work_id,command_sql,expected_access,
  expected_kind,expected_rows,expected_ids
)
select concat_ws('__',access_case,surface_name,scope_variant,app_role,ownership_case),surface_name,'SELECT',app_role,
  auth_subject,scope_variant,ownership_case,access_case,target_id,target_client_id,target_project_id,target_work_id,
  format('select id from public.%I where id = %L',surface_name,target_id),
  false,'row_count',0,array[]::uuid[]
from resolved;
