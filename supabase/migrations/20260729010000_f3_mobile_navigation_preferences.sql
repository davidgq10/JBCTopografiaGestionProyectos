-- Fase 3 / 21: orden personalizable de la navegación móvil.
-- Inicio y Más son fijos; cada usuario elige tres accesos intermedios.

begin;

alter table public.app_users
  add column mobile_nav_items text[] not null
  default array['agenda', 'avisos', 'cuenta']::text[]
  constraint app_users_mobile_nav_items_valid
  check (
    cardinality(mobile_nav_items) = 3
    and mobile_nav_items[1] is not null
    and mobile_nav_items[2] is not null
    and mobile_nav_items[3] is not null
    and mobile_nav_items[1] <> mobile_nav_items[2]
    and mobile_nav_items[1] <> mobile_nav_items[3]
    and mobile_nav_items[2] <> mobile_nav_items[3]
    and mobile_nav_items <@ array['agenda', 'avisos', 'cuenta', 'proyectos', 'tareas']::text[]
  );

create or replace function app_private.restrict_app_user_self_update()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $function$
declare
  actor_id uuid := app_private.current_app_user_id();
  only_profile_preferences boolean;
begin
  if current_user <> 'authenticated' then
    return new;
  end if;

  only_profile_preferences := old.id = actor_id
    and (to_jsonb(new) - array[
      'preferred_accent',
      'preferred_theme',
      'mobile_nav_items',
      'updated_at',
      'updated_by',
      'version'
    ]) is not distinct from (to_jsonb(old) - array[
      'preferred_accent',
      'preferred_theme',
      'mobile_nav_items',
      'updated_at',
      'updated_by',
      'version'
    ]);

  if app_private.has_role('administrator') then
    if only_profile_preferences then
      new.updated_at := statement_timestamp();
      new.updated_by := actor_id;
      new.version := old.version + 1;
    end if;
    return new;
  end if;

  if not only_profile_preferences then
    raise exception using
      errcode = '42501',
      message = 'La actualización propia solo permite cambiar preferencias visuales y navegación móvil';
  end if;

  new.updated_at := statement_timestamp();
  new.updated_by := actor_id;
  new.version := old.version + 1;
  return new;
end;
$function$;

create or replace function app_private.audit_preferred_accent_change()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public, app_private
as $function$
declare
  actor_id uuid := app_private.current_app_user_id();
  actor_role text;
begin
  if old.preferred_accent is not distinct from new.preferred_accent
     and old.preferred_theme is not distinct from new.preferred_theme
     and old.mobile_nav_items is not distinct from new.mobile_nav_items then
    return new;
  end if;

  if actor_id is null then
    return new;
  end if;

  select r.code
  into actor_role
  from public.user_roles ur
  join public.roles r on r.id = ur.role_id
  where ur.user_id = actor_id
    and ur.valid_from <= statement_timestamp()
    and (ur.valid_until is null or ur.valid_until > statement_timestamp())
    and ur.revoked_at is null
  order by case r.code
    when 'administrator' then 1
    when 'coordinator' then 2
    when 'technician' then 3
    when 'read_only' then 4
    else 5
  end, r.code
  limit 1;

  insert into public.audit_events (
    actor_user_id,
    actor_role_code,
    module_code,
    entity_kind,
    entity_id,
    action_code,
    result_code,
    old_values,
    new_values,
    correlation_id
  ) values (
    actor_id,
    actor_role,
    'identity',
    'app_user_profile',
    new.id,
    'profile.appearance_updated',
    'accepted',
    jsonb_build_object(
      'preferredAccent', coalesce(old.preferred_accent, 'teal'),
      'preferredTheme', old.preferred_theme,
      'mobileNavItems', to_jsonb(old.mobile_nav_items),
      'version', old.version
    ),
    jsonb_build_object(
      'preferredAccent', coalesce(new.preferred_accent, 'teal'),
      'preferredTheme', new.preferred_theme,
      'mobileNavItems', to_jsonb(new.mobile_nav_items),
      'version', new.version
    ),
    new.correlation_id
  );

  return new;
end;
$function$;

drop trigger if exists trg_app_users_accent_audit on public.app_users;
create trigger trg_app_users_accent_audit
after update of preferred_accent, preferred_theme, mobile_nav_items on public.app_users
for each row execute function app_private.audit_preferred_accent_change();

revoke all on function app_private.restrict_app_user_self_update() from public;
revoke all on function app_private.audit_preferred_accent_change() from public;

alter function app_private.restrict_app_user_self_update() owner to app_rls_owner;
alter function app_private.audit_preferred_accent_change() owner to app_rls_owner;

commit;
