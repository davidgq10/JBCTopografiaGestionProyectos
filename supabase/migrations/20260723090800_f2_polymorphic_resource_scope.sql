-- Fase 2 / 08: alinear el alcance polimórfico organization|project|work.
-- Un work_id siempre exige project_id; project_id sin work_id representa un
-- alcance directo de Proyecto. La FK simple preserva integridad en ese caso y
-- la FK compuesta preserva pertenencia cuando existe Trabajo.

begin;

alter table public.approval_decisions
  drop constraint approval_decisions_work_pair,
  add constraint approval_decisions_project_fk
    foreign key (project_id) references public.projects(id) on delete restrict,
  add constraint approval_decisions_scope_complete check (
    work_id is null or project_id is not null
  );

alter table public.approval_executions
  drop constraint approval_execution_work_pair,
  add constraint approval_executions_project_fk
    foreign key (project_id) references public.projects(id) on delete restrict,
  add constraint approval_executions_scope_complete check (
    work_id is null or project_id is not null
  );

alter table public.notifications
  drop constraint notifications_work_pair,
  add constraint notifications_project_fk
    foreign key (project_id) references public.projects(id) on delete restrict,
  add constraint notifications_scope_complete check (
    work_id is null or project_id is not null
  );

alter table public.ai_runs
  drop constraint ai_runs_work_pair,
  add constraint ai_runs_project_fk
    foreign key (project_id) references public.projects(id) on delete restrict,
  add constraint ai_runs_scope_complete check (
    work_id is null or project_id is not null
  );

alter table public.ai_evidence
  drop constraint ai_evidence_work_pair,
  add constraint ai_evidence_project_fk
    foreign key (project_id) references public.projects(id) on delete restrict,
  add constraint ai_evidence_scope_complete check (
    work_id is null or project_id is not null
  );

alter table public.ai_proposals
  drop constraint ai_proposals_work_pair,
  add constraint ai_proposals_project_fk
    foreign key (project_id) references public.projects(id) on delete restrict,
  add constraint ai_proposals_scope_complete check (
    work_id is null or project_id is not null
  );

alter table public.audit_events
  drop constraint audit_work_pair,
  add constraint audit_events_project_fk
    foreign key (project_id) references public.projects(id) on delete restrict,
  add constraint audit_events_scope_complete check (
    work_id is null or project_id is not null
  );

alter table public.outbox_events
  drop constraint outbox_work_pair,
  add constraint outbox_events_project_fk
    foreign key (project_id) references public.projects(id) on delete restrict,
  add constraint outbox_events_scope_complete check (
    work_id is null or project_id is not null
  );

commit;
