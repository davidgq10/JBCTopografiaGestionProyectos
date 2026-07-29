# Verificación reproducible de Fase 3

Fecha: **2026-07-29 America/Costa_Rica** (regresión final del corte).

## Entorno

- Node.js `24.18.0` y pnpm `11.9.0`.
- Docker Engine `29.2.1`.
- PostgreSQL `17` y PostgREST `14.12` en contenedores efímeros.
- Datos sintéticos; no se usaron datos, credenciales ni servicios de producción.

## Resultados

| Comando                                         | Resultado                                                                                                                                                      |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pnpm verify:ci`                                | **PASS**: formato, lint, tipos, arquitectura, secretos, SQL, cobertura, build, Storybook, E2E Chromium 14/14 ejecutables (6 omitidas por viewport) y PWA 1/1   |
| `pnpm verify:database`                          | **PASS**: migraciones desde cero, 57 tablas RLS, `RLS-STRUCT PASS`, `RLS-MATRIX PASS 2561/2561`, `F3-ACCENT PASS`                                              |
| `pnpm verify:connected`                         | **PASS**: `UI → PostgREST 14.12 → PostgreSQL 17 → RLS → auditoría → respuesta visible`                                                                         |
| `pnpm --filter @jbc/web test:a11y:supplemental` | **PASS**: Edge de escritorio y WebKit con perfil iPhone emulado; Apariencia y Configuración con axe=0, teclado/foco y ausencia de overflow                     |
| navegación móvil F03                            | **PASS**: E2E Chromium 14/14 ejecutables, 6 omitidos por viewport; `Más` 44×44 px, Configuración, selección/orden, ARIA, Escape, foco y rutas Proyectos/Tareas |

La ejecución de `verify:database` se realizó dentro de un cliente PostgreSQL temporal en Docker porque el host Windows no tenía `psql`; el script del repositorio se ejecutó sin modificaciones contra PostgreSQL 17.

El CLI de Supabase generó `.temp` y `.branches` localmente. Ambos destinos quedan fuera del lint y del control de versiones; no contienen artefactos que deban publicarse.

La fila de navegación móvil es un addendum al corte base: la regresión final conserva los escenarios originales y demuestra la preferencia configurable en `F03-MOBILE-NAVIGATION-2026-07-28.md` y `F03-MOBILE-NAV-PREFERENCES-2026-07-29.md`.

El usuario aprobó explícitamente el P2 residual y G3 el 2026-07-29. La aprobación de cierre está
registrada en `F03-G3-USER-APPROVAL-2026-07-29.md`; no agrega pruebas físicas no ejecutadas a esta
verificación automatizada.
