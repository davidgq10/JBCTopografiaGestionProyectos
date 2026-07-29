# Verificación reproducible de Fase 3

Fecha: **2026-07-28 America/Costa_Rica**.

## Entorno

- Node.js `24.18.0` y pnpm `11.9.0`.
- Docker Engine `29.2.1`.
- PostgreSQL `17` y PostgREST `14.12` en contenedores efímeros.
- Datos sintéticos; no se usaron datos, credenciales ni servicios de producción.

## Resultados

| Comando                                         | Resultado                                                                                                                      |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `pnpm verify:ci`                                | **PASS**: formato, lint, tipos, arquitectura, secretos, SQL, cobertura, build, Storybook, E2E Chromium 12/12 y PWA 1/1         |
| `pnpm verify:database`                          | **PASS**: migraciones desde cero, 57 tablas RLS, `RLS-STRUCT PASS`, `RLS-MATRIX PASS 2561/2561`, `F3-ACCENT PASS`              |
| `pnpm verify:connected`                         | **PASS**: `UI → PostgREST 14.12 → PostgreSQL 17 → RLS → auditoría → respuesta visible`                                         |
| `pnpm --filter @jbc/web test:a11y:supplemental` | **PASS**: Edge de escritorio y WebKit con perfil iPhone emulado; teclado/foco y ausencia de overflow                           |
| navegación móvil F03                            | **PASS**: E2E Chromium 13/13 ejecutables, 3 omitidos por viewport; `Más` 44×44 px, ARIA, Escape, foco y rutas Proyectos/Tareas |

La ejecución de `verify:database` se realizó dentro de un cliente PostgreSQL temporal en Docker porque el host Windows no tenía `psql`; el script del repositorio se ejecutó sin modificaciones contra PostgreSQL 17.

El CLI de Supabase generó `.temp` y `.branches` localmente. Ambos destinos quedan fuera del lint y del control de versiones; no contienen artefactos que deban publicarse.

La fila de navegación móvil es un addendum al corte base: el resultado anterior de `verify:ci` conserva sus 12/12 pruebas originales y la nueva evidencia específica está en `F03-MOBILE-NAVIGATION-2026-07-28.md`.
