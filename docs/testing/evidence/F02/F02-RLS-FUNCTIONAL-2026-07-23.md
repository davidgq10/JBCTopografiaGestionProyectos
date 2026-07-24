# Evidencia RLS funcional — Fase 2

Fecha: **2026-07-23 19:33:22** (`America/Costa_Rica`) / **2026-07-24T01:33:22Z**  
Estado: **PASS confirmado por R6; G2 aprobado y Fase 2 cerrada**

## Decisión aplicada

`DEC-0103`, aprobada por el usuario el 2026-07-23:

- Administrador: alcance global; administra usuarios, roles, configuración y operación.
- Coordinador: alcance global; administra operación y asignaciones, no usuarios ni roles.
- Técnico: solo Proyectos asignados directamente, incluidos todos sus Trabajos; puede crear y actualizar datos operativos en ese alcance. Una asignación aislada a Trabajo no concede acceso.
- Solo lectura: consulta todos los Proyectos y sus Trabajos; no realiza escrituras de negocio.

## Entorno y migración

- PostgreSQL `17.10`, contenedor local efímero `jbc-f2-pg`, sin puertos publicados ni datos reales.
- Bases nuevas definitivas: `jbc_f2_clean_r6e` y `jbc_f2_incremental_r6e`.
- Migraciones `01→19` aplicadas en orden. La 19 es `20260723091900_f2_functional_rls_dec_0103.sql`, SHA-256 `023A11CAD420346BCB20E6462B5B0E07C42813D3FF38E73A1EB40DA60438BC16`.
- Ruta incremental: `01→02`, fixture Proyecto+Trabajo, `03→19`; fixture final conservado con `version=1`.
- Huella normalizada limpia/incremental: `761f627b03a648b03feb95136753a3e2209234c28ac2a1dae62d2d722a8b035c`, `Equal=True`, `293930` bytes.

Catálogo final idéntico en ambas rutas: `57` tablas, `227` FK, `155` índices, `130` triggers, `136` políticas y `57/57` tablas con RLS habilitada y forzada. Las `17` funciones privadas `SECURITY DEFINER` pertenecen a `app_rls_owner`, rol `NOLOGIN`, no superusuario y con `BYPASSRLS` explícitamente acotado; ninguna función privada distinta de los ocho helpers RLS autorizados queda ejecutable por `PUBLIC`, `anon` o `authenticated`.

## Matriz funcional

Comando reproducible, ejecutado en ambas bases:

```powershell
docker exec jbc-f2-pg psql -U postgres -d <base_efimera> -X -v ON_ERROR_STOP=1 -v dec_0103_approved=1 -f /tmp/f2tests_r6/run_rls.psql
```

Resultado limpio e incremental:

```text
RLS-STRUCT PASS | inventoried_tables=57 | inventoried_views=0 | inventoried_functions=0
RLS-MATRIX PASS | executed_cases=2561 | passed_cases=2561
```

La cobertura incluye CRUD por cuatro roles, todos los alcances físicos, propio/ajeno, identidades revocadas/no preautorizadas, Proyecto asignado/no asignado, Trabajo hermano, asignación aislada a Trabajo, referencias indirectas y ciclos append-only/backend-only. Cada comando pasa preflight físico como propietario y luego se ejecuta como `authenticated` con únicamente `sub`, `role=authenticated` y `aal=aal2` en las claims.

La misma suite con `dec_0103_approved=0` terminó con código distinto de cero y:

```text
RLS-MATRIX BLOCKED: DEC-0103 no aprobada; no se ejecutan ni congelan concesiones
```

## Regresión conjunta

- `F2-INVARIANTS PASS`.
- `F2-EXTERNAL-TYPE-MATRIX PASS`: 16/16 altas APT/SIRI incompatibles rechazadas.
- `F2-WORK-TYPE-APPROVAL PASS`.
- `RLS-HARNESS-GUARDS PASS`.
- `F2-NOTE-RACE PASS`: una sesión confirmó la revisión 2 y la otra recibió `23505`; quedó exactamente una revisión 1 y una revisión 2.
- Contratos: TypeScript estricto PASS; `92` referencias OpenAPI, `9` eventos; DAG `15/15` sin ciclos.
- Revisión estática de secretos/binarios y RF-013: sin valores secretos ni superficie activa de importación Excel; las coincidencias de `service_role` son prohibiciones/guardas documentadas.
- `verify_static.ps1`: **NO EJECUTADO** por la política de ejecución de PowerShell del host; no se evadió. El parser del script y su comprobación equivalente de inventario pasaron (`57=57`, cero vistas/funciones `public`, puerta predeterminada `0`); los mutantes se ejecutaron además en PostgreSQL.

R5 emitió `NO-GO` con dos P1 y dos P2. El corte R6 retiró `UPDATE` cliente de `approval_requests` y `drive_operations`; vinculó `registered_by`, `requested_by` y `decided_by` a la identidad autenticada; impidió decidir solicitudes propias; restringió el alta cliente de operaciones OneDrive a la persona autenticada, estado `requested`, sin resultado forjado y versión inicial; agregó positivos/negativos de acento y lectura de notificación con triggers de columnas permitidas; y transfirió todas las funciones privilegiadas al propietario `NOLOGIN`. Los `37` casos adicionales prueban estas correcciones y la robustez previa.

## Revisión y puerta

R6 reprodujo el corte 19 y esta evidencia con 0 P0/P1/P2/P3, y emitió GO para presentar G2. El usuario aprobó G2 y el cierre de Fase 2 el 2026-07-23; Fase 3 no se inició en este cierre.
