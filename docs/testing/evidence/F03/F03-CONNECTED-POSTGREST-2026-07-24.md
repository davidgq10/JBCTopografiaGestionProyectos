# Evidencia conectada UI → PostgREST → PostgreSQL

Fecha: **2026-07-24**.

## Ejecución

```text
pnpm verify:connected
CONNECTED-FIXTURE PASS | datos sintéticos cargados
1 passed
CONNECTED-E2E PASS | UI -> PostgREST -> RLS -> PostgreSQL -> auditoría
CONNECTED-VERIFY PASS | UI + PostgREST 14.12 + PostgreSQL 17 + RLS + auditoría
```

Resultado: **PASS local**.

El arés creó contenedores efímeros PostgreSQL 17 y PostgREST 14.12, aplicó las 20 migraciones desde cero y cargó dos perfiles sintéticos. Chromium recorrió la interfaz en español, inició una sesión sintética AAL2, leyó por PostgREST y comprobó que RLS solo devolvía el perfil propio. Luego seleccionó tema oscuro y acento azul, guardó y observó la confirmación visible.

La comprobación posterior en la misma base demostró:

- acento `azul`, tema `dark` y versión incrementada de 1 a 2;
- perfil ajeno sin cambios;
- exactamente un evento `profile.appearance_updated` con actor técnico, valores anterior/nuevo y resultado `accepted`.

## Seguridad y alcance

El secreto de firma y el JWT se generan en memoria para cada ejecución. El proxy local conserva el JWT fuera del navegador y no lo escribe en archivos ni logs. El modo `connected-test` se selecciona mediante alias de compilación y no modifica el adaptador Supabase de producción.

Esta evidencia corrige técnicamente `F3-REV-P1-02`, pero no reemplaza el dictamen independiente ni demuestra Microsoft Entra, tenant, MFA, allowlist o revocación reales.
