-- Fase 3 / 20: preferencia de acento validada y auditada en la misma transacción.
-- No agrega superficies públicas ni contenido binario.

begin;

alter table public.app_users
  add column preferred_theme text not null default 'auto'
  constraint app_users_preferred_theme_valid
  check (preferred_theme in ('auto', 'light', 'dark'));

create or replace function app_private.accent_channel_luminance(p_channel integer)
returns double precision
language sql
immutable
strict
set search_path = pg_catalog
as $function$
  select case
    when p_channel / 255.0 <= 0.04045 then (p_channel / 255.0) / 12.92
    else power(((p_channel / 255.0) + 0.055) / 1.055, 2.4)
  end
$function$;

create or replace function app_private.accent_relative_luminance(p_color text)
returns double precision
language sql
immutable
strict
set search_path = pg_catalog, app_private
as $function$
  select
    0.2126 * app_private.accent_channel_luminance(get_byte(decode(substr(p_color, 2), 'hex'), 0))
    + 0.7152 * app_private.accent_channel_luminance(get_byte(decode(substr(p_color, 2), 'hex'), 1))
    + 0.0722 * app_private.accent_channel_luminance(get_byte(decode(substr(p_color, 2), 'hex'), 2))
$function$;

create or replace function app_private.is_accessible_preferred_accent(p_value text)
returns boolean
language plpgsql
immutable
set search_path = pg_catalog, app_private
as $function$
declare
  normalized text := lower(btrim(p_value));
  luminance double precision;
  contrast_with_white double precision;
begin
  if p_value is null then
    return true;
  end if;

  if normalized = any (array['teal', 'azul', 'indigo', 'violeta', 'rosa', 'naranja']) then
    return true;
  end if;

  if btrim(p_value) !~ '^#[0-9A-Fa-f]{6}$' then
    return false;
  end if;

  luminance := app_private.accent_relative_luminance(upper(btrim(p_value)));
  contrast_with_white := 1.05 / (luminance + 0.05);
  return contrast_with_white >= 4.5;
end;
$function$;

create or replace function app_private.validate_preferred_accent()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public, app_private
as $function$
begin
  if not app_private.is_accessible_preferred_accent(new.preferred_accent) then
    raise exception using
      errcode = '23514',
      constraint = 'app_users_preferred_accent_accessible',
      message = 'El acento debe ser una opción aprobada o un color hexadecimal con contraste WCAG AA';
  end if;

  if new.preferred_accent ~ '^#[0-9A-Fa-f]{6}$' then
    new.preferred_accent := upper(new.preferred_accent);
  elsif new.preferred_accent is not null then
    new.preferred_accent := lower(btrim(new.preferred_accent));
  end if;
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
     and old.preferred_theme is not distinct from new.preferred_theme then
    return new;
  end if;

  if actor_id is null then
    -- Migraciones y preflight del arnés operan como propietario sin JWT y se
    -- revierten. Las escrituras de aplicación siempre llegan con auth.uid().
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
      'version', old.version
    ),
    jsonb_build_object(
      'preferredAccent', coalesce(new.preferred_accent, 'teal'),
      'preferredTheme', new.preferred_theme,
      'version', new.version
    ),
    new.correlation_id
  );

  return new;
end;
$function$;

-- El trigger de Fase 2 ya incrementa versión para perfiles propios salvo el
-- Administrador, cuya rama permite además administrar identidad. Conservamos
-- esa capacidad y aplicamos concurrencia cuando su cambio es solo de acento.
create or replace function app_private.restrict_app_user_self_update()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $function$
declare
  actor_id uuid := app_private.current_app_user_id();
  only_accent boolean;
begin
  if current_user <> 'authenticated' then
    return new;
  end if;

  only_accent := old.id = actor_id
    and (to_jsonb(new) - array['preferred_accent','preferred_theme','updated_at','updated_by','version'])
      is not distinct from
      (to_jsonb(old) - array['preferred_accent','preferred_theme','updated_at','updated_by','version']);

  if app_private.has_role('administrator') then
    if only_accent then
      new.updated_at := statement_timestamp();
      new.updated_by := actor_id;
      new.version := old.version + 1;
    end if;
    return new;
  end if;

  if not only_accent then
    raise exception using
      errcode = '42501',
      message = 'La actualización propia solo permite cambiar el acento preferido';
  end if;

  new.updated_at := statement_timestamp();
  new.updated_by := actor_id;
  new.version := old.version + 1;
  return new;
end;
$function$;

drop trigger if exists trg_app_users_accent_validate on public.app_users;
create trigger trg_app_users_accent_validate
before insert or update of preferred_accent on public.app_users
for each row execute function app_private.validate_preferred_accent();

drop trigger if exists trg_app_users_accent_audit on public.app_users;
create trigger trg_app_users_accent_audit
after update of preferred_accent, preferred_theme on public.app_users
for each row execute function app_private.audit_preferred_accent_change();

revoke all on function app_private.accent_channel_luminance(integer) from public;
revoke all on function app_private.accent_relative_luminance(text) from public;
revoke all on function app_private.is_accessible_preferred_accent(text) from public;
revoke all on function app_private.validate_preferred_accent() from public;
revoke all on function app_private.audit_preferred_accent_change() from public;

grant insert on public.audit_events to app_rls_owner;

alter function app_private.validate_preferred_accent() owner to app_rls_owner;
alter function app_private.audit_preferred_accent_change() owner to app_rls_owner;
alter function app_private.accent_channel_luminance(integer) owner to app_rls_owner;
alter function app_private.accent_relative_luminance(text) owner to app_rls_owner;
alter function app_private.is_accessible_preferred_accent(text) owner to app_rls_owner;

commit;
