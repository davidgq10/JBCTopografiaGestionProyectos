# Comprobaciones de integración — Fase 2

Fecha inicial: **2026-07-23 13:16:01** (`America/Costa_Rica`) / **2026-07-23T19:16:01Z**  
Última regresión: **2026-07-23 15:36:10** (`America/Costa_Rica`) / **2026-07-23T21:36:10Z**  
Estado: **EVIDENCIA HISTÓRICA del corte 01→18; sustituida para RLS final por [F02-RLS-FUNCTIONAL-2026-07-23.md](F02-RLS-FUNCTIONAL-2026-07-23.md)**

> Este documento conserva la regresión previa a la aprobación de `DEC-0103`. Los estados “pendiente/bloqueado” siguientes describen ese corte histórico y no el estado actual.

## Entorno reproducible

- PostgreSQL **17.10** sobre `postgres@sha256:742f40ea20b9ff2ff31db5458d127452988a2164df9e17441e191f3b72252193`.
- Contenedor efímero `jbc-f2-pg`, sin puertos publicados ni datos reales.
- Bases nuevas `jbc_f2_clean_r4`, `jbc_f2_incremental_r4` y copias sintéticas exclusivas para concurrencia.
- Node.js `v22.15.0`, pnpm `11.9.0`, TypeScript `5.9.3`, Zod `4.4.3` y Redocly CLI `2.40.0` temporal.

## Migraciones verificadas

|   # | Archivo                                                    | SHA-256                                                            |
| --: | ---------------------------------------------------------- | ------------------------------------------------------------------ |
|   1 | `20260723090100_f2_foundation_identity_admin_clients.sql`  | `7359EED69F4E65B25ECF06C94DE384693B4887446EB555D7B1DDAD0037920108` |
|   2 | `20260723090200_f2_projects_and_operations.sql`            | `42513DF59AE124F33E50537866ACD355E5DD3F7CBFF1201D91AE191487EFBA75` |
|   3 | `20260723090300_f2_integrations_approvals_ai_platform.sql` | `96F4A4F32BB7378559D206CA2D3F75C5DD96F5F6B4357107BFDE0E7039C76623` |
|   4 | `20260723090400_f2_invariants_and_indexes.sql`             | `F619C2072C92C0F8DA3B13FF35C52B93A2A1ACA70E8C10A4FDD09BCC63B6D5E8` |
|   5 | `20260723090500_f2_rls_fail_closed.sql`                    | `7916B0FCCA34F49D1B58021337F554B883B7B72D7042C25854268189F312FB2F` |
|   6 | `20260723090600_f2_schedule_assignment_history.sql`        | `CF5A517AB5136782B474C4973147AD4EED08EA728D92308A07F28A71C8D0E203` |
|   7 | `20260723090700_f2_identity_assignment_history.sql`        | `AAC69CA77818E580064EE001917CE293A41CBC9712D57E10107D98EB4A5A837A` |
|   8 | `20260723090800_f2_polymorphic_resource_scope.sql`         | `16C9DAF346BD406B707FA5FD1BCC2283DF1396179D5B08E26271B31C18F70076` |
|   9 | `20260723090900_f2_work_type_external_capabilities.sql`    | `E2A663E564DCC4AD1939847A7187376CFB64B80A9E2E4B9798BFC26E6934CCC5` |
|  10 | `20260723091000_f2_concurrent_graph_invariants.sql`        | `B78A7340281D4688BC735D9ABF05996B62E13FBF7DB2F0186DA6F19620A875FD` |
|  11 | `20260723091100_f2_active_assignment_uniqueness.sql`       | `3A7DB2CE0BEB3BB8B20935316CBA5F2837BD009BBC01F3ECC0D84273DF8BA3BB` |
|  12 | `20260723091200_f2_management_note_revision_chain.sql`     | `F4F94A62B2F8B374933CC526D477655901505BA484E455E20BFEC627AC1851F0` |
|  13 | `20260723091300_f2_catalog_value_code_immutable.sql`       | `C6B8A220B4C2DF7486306EA9908535B40714DAC35E04BA5EBE9F9ED4FA48AB8F` |
|  14 | `20260723091400_f2_private_function_default_acl.sql`       | `3A039765C15C1375BB763CA7853BA4498E190DADC037EC0F7A89E9891D3A5C07` |
|  15 | `20260723091500_f2_external_procedure_creation_scope.sql`  | `9B51A5F1D1648126CF264CA8AF7B64D7084DC48EB53D5E013C722C0A83D11769` |
|  16 | `20260723091600_f2_protected_codes_immutable.sql`          | `C65119365B81BCDC1AC0FA6A9C20B959353FD17FE4F26FB872F1698DB6B43125` |
|  17 | `20260723091700_f2_user_specialty_reassignment.sql`        | `D8E84938F4F8C6FC836BBC8373EE241FE7E9F0F54DBFA02C5055B0F2DD154E48` |
|  18 | `20260723091800_f2_work_type_change_approval_binding.sql`  | `6630D306BE72D1FEA78A9E23065954B28DFB87D90819E62F9848785A824DFAB4` |

Todos se aplicaron en orden con `psql -X -v ON_ERROR_STOP=1`.

## Resultados PostgreSQL

| Control                                                      | Resultado                                                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| Base limpia 01→18                                            | **PASS**                                                                                          |
| Ruta incremental 01→02 → fixture Proyecto+Trabajo → 03→18    | **PASS**                                                                                          |
| Fixture incremental conservado                               | **PASS**: `R3-INCREMENTAL`, nombres legibles y `version = 1` en Proyecto/Trabajo                  |
| Catálogo final en ambas rutas                                | `57` tablas, `226` FK, `155` índices, `128` triggers                                              |
| RLS habilitada y forzada                                     | **57/57 tablas**                                                                                  |
| Huella de esquema normalizada                                | **idéntica**: `b49049cb01164cd0837175239812832cd235209fd88d8a3d6940ae0ebfd23685` (`245129` bytes) |
| FK con `ON DELETE CASCADE`                                   | **0**                                                                                             |
| Columnas binarias de Proyecto/Trabajo                        | **0**                                                                                             |
| Tiempos persistidos `*_at` distintos de `timestamptz`        | **0**                                                                                             |
| `app_private` ejecutable por `PUBLIC`/`anon`/`authenticated` | **0**                                                                                             |

La normalización elimina exclusivamente las líneas aleatorias `\restrict` y `\unrestrict` de `pg_dump`; une las líneas con LF, codifica UTF-8 sin BOM, no agrega LF final y calcula SHA-256 en memoria. Comando reproducible exacto (PowerShell 5.1+, desde la raíz, con el contenedor activo):

```powershell
$cleanLines = & docker exec jbc-f2-pg pg_dump -U postgres -d jbc_f2_clean_r4 --schema-only --no-owner --no-privileges
$incrementalLines = & docker exec jbc-f2-pg pg_dump -U postgres -d jbc_f2_incremental_r4 --schema-only --no-owner --no-privileges
$cleanText = ($cleanLines | Where-Object { $_ -notmatch '^\\(un)?restrict ' }) -join "`n"
$incrementalText = ($incrementalLines | Where-Object { $_ -notmatch '^\\(un)?restrict ' }) -join "`n"
$utf8 = [Text.UTF8Encoding]::new($false)
$sha = [Security.Cryptography.SHA256]::Create()
$cleanHash = ([BitConverter]::ToString($sha.ComputeHash($utf8.GetBytes($cleanText)))).Replace('-','').ToLowerInvariant()
$incrementalHash = ([BitConverter]::ToString($sha.ComputeHash($utf8.GetBytes($incrementalText)))).Replace('-','').ToLowerInvariant()
[pscustomobject]@{ Clean=$cleanHash; Incremental=$incrementalHash; Equal=($cleanText -ceq $incrementalText); Bytes=$utf8.GetByteCount($cleanText) }
```

Resultado: ambas huellas `b49049cb…`, `Equal=True`, `Bytes=245129`.

## Invariantes y regresiones R1/R2

`supabase/tests/40_invariants.psql` se ejecutó con fixtures sintéticos y `ROLLBACK` total:

- **PASS**: las 16 combinaciones de alta APT/SIRI activa/inactiva se rechazan en Delimitación, Curvas de nivel, Avalúo y Croquis;
- **PASS**: una fila APT existente en Plano de catastro puede desactivarse y conservarse como historia;
- **PASS**: un Trabajo no cambia de Contratación;
- **PASS**: roles, permisos, especialidades, membresías y asignaciones de agenda conservan una fila histórica y exactamente una activa tras reotorgar;
- **PASS**: las asignaciones no se eliminan físicamente;
- **PASS**: códigos físicos protegidos y `catalog_values.code` son invariables;
- **PASS**: una revisión de nota no salta revisiones ni cambia de nota lógica;
- **PASS**: una revisión no puede usar como padre una nota de otra Gestión;
- **PASS**: aprobación, decisión, ejecución, notificación, auditoría y outbox aceptan alcance directo de Proyecto sin inventar `work_id`.

La prueba de concurrencia abrió dos conexiones reales por caso. La primera transacción mantuvo el bloqueo tres segundos y la segunda intentó crear la arista inversa:

```text
ERROR: La jerarquía de tareas no puede contener ciclos
ERROR: Las dependencias de tareas no pueden contener ciclos
F2-CONCURRENCY PASS parent_and_dependency
```

El invariante Proyecto `1:N` queda cerrado haciendo invariable `works.project_id`; `DELETE` ya estaba rechazado y la creación continúa validada por constraint diferible.

La carrera adicional `concurrency/43_management_note_*.psql` ejecutó dos inserciones simultáneas de la revisión 2. La sesión A confirmó; la B terminó con `23505` sobre `management_notes_management_id_logical_note_id_revision_key`; la aserción final encontró una revisión 1 y exactamente una revisión 2.

`supabase/tests/44_work_type_change_approval.psql` devolvió **PASS**. Rechazó mutación distinta de `requested_change`, ausencia de decisión, ausencia de ejecución, ejecución consumida, reutilización, cambio posterior del payload y cambio de identidad de ejecución. El camino válido coincidió exactamente con tipo/configuración/estado aprobados, consumió solicitud/ejecución y dejó APT histórico; reactivarlo, cambiar proveedor o trasladarlo fuera de catastro terminó en `23514`.

## Contratos y límites

| Control                                          | Resultado                                                                      |
| ------------------------------------------------ | ------------------------------------------------------------------------------ |
| `pnpm --dir packages/contracts run typecheck`    | **PASS** con comando local reproducible                                        |
| `pnpm --dir packages/contracts run verify`       | **PASS**: 92 referencias OpenAPI, 9 eventos y DAG de 15 nodos sin ciclos       |
| Redocly CLI 2.40.0 sobre `docs/api/openapi.yaml` | **PASS**: 0 errores, 0 advertencias                                            |
| `ResourceScope` Zod/OpenAPI/puertos/eventos      | **PASS**: `organization`, `project` o `work`, discriminado sin pares parciales |
| RF-013 activo o superficie Excel                 | **0**                                                                          |
| marcadores de conflicto                          | **0**                                                                          |

La política del equipo impide ejecutar archivos `.ps1`; no se evadió. Las comprobaciones equivalentes del inventario se ejecutaron en SQL/consultas directas y el script queda disponible para un entorno que permita scripts firmados.

## RLS y bloqueo correcto

`run_structure.psql` devolvió:

```text
RLS-STRUCT PASS | inventoried_tables=57 | views=0 | functions=0
```

El manifiesto declara todos los `supported_scopes` y la dimensión propio/ajeno. La matriz exige cada superficie, rol, operación, alcance y propiedad aplicable. Sujeto, rol efectivo, estado de identidad, membresías, UUID y anclas físicas se contrastan contra fixtures persistidos. Los comandos usan gramática canónica exacta; antes del rol cliente, cada caso se ejecuta como propietario en una subtransacción revertida y debe afectar/leer el UUID, alcance y propietario tipados. El runner deriva postcondiciones de superficie+UUID+alcance+propietario y revierte cada caso. Las funciones compilaron en PostgreSQL; `50_rls_harness_guards.psql` rechazó los mutantes de rol, UUID inexistente, Trabajo hermano mal etiquetado, postcondición libre y objetivo real con `AND 1=0`.

Con `dec_0103_approved=0`, `run_rls.psql` vuelve a pasar la estructura y termina exactamente con:

```text
RLS-MATRIX BLOCKED: DEC-0103 no aprobada; no se ejecutan ni congelan concesiones
```

Esto demuestra postura fail-closed; **no** demuestra todavía `AC-010-01/02` ni autoriza G2.

## Revisión independiente

- R1: `0 P0`, `4 P1`, `4 P2`, `1 P3`; **NO-GO** y correcciones requeridas.
- R2 (corte anterior a 15→17 y al último arnés): `0 P0`, `2 P1`, `2 P2`, `1 P3`; **NO-GO**.
- R3 (corte 01→17): `0 P0`, `2 P1`, `3 P2`, `1 P3`; **NO-GO**. Reprodujo el negativo `AND 1=0` y un cambio de tipo distinto al solicitado sin decisión/ejecución.
- Migración 18, gramática/preflight RLS, `40`, `44`, `50`, huella reproducible y documentos responden a todos los hallazgos R3.
- R4 (corte 01→18): `0 P0`, `0 P1`, `0 P2`, `0 P3`; **GO técnico limitado al alcance previo a `DEC-0103`**. Reprodujo exactamente la huella limpia/incremental, repitió estructura, pruebas `40/42/44/50`, contratos y concurrencia, y cerró los seis hallazgos R3. Informe: `docs/architecture/reviews/F2/F2-INDEPENDENT-REVIEW-R4-2026-07-23.md`.

## Pendiente para G2

1. aprobación explícita de `DEC-0103`;
2. migración aditiva de políticas RLS coherentes con esa decisión;
3. fixtures/casos funcionales completos y `RLS-MATRIX PASS`;
4. regresión independiente final con cero P0/P1;
5. actualizar trazabilidad, reporte y handoff de cierre.

Hasta completar esos puntos: **Fase 2 en curso; G2 no presentado**.
