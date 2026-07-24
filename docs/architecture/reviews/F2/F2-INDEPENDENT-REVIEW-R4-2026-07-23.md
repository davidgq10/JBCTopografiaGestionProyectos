# Revisión independiente R4 — Fase 2

**ID:** `F2-REV-R4`  
**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Rol:** revisor independiente de arquitectura, datos, contratos y seguridad; no autor del corte y sin modificaciones fuera de este informe  
**Snapshot:** migraciones `20260723090100`→`20260723091800`, bases `jbc_f2_clean_r4` y `jbc_f2_incremental_r4`, contratos, arnés RLS, pruebas `40/42/44/50` y documentación disponible al iniciar R4  
**Dictamen:** **GO para el alcance técnico autorizado previo a `DEC-0103`; 0 P0, 0 P1, 0 P2 y 0 P3 abiertos en R4. G2 permanece bloqueado.**

## 1. Alcance y método

Se leyeron completamente `AGENTS.md`, `Especificacion_Requerimientos_Plataforma_JBC.txt` con sus anexos y los informes independientes R1, R2 y R3. Se revisaron las 18 migraciones, contratos Zod/TypeScript, OpenAPI, puertos, eventos, modelo y estrategia de datos, seguridad/permisos, arnés RLS, evidencia F02, estado y propiedad de archivos.

La regresión se limitó a la lista de cierre solicitada: los dos P1, tres P2 y un P3 de R3; RF-019 y los soportes de RF-002, RF-010, RF-012 y RF-015; `AC-016-08`; y la ausencia de RF-013. Se utilizó PostgreSQL 17.10 local en el contenedor `jbc-f2-pg`, sin red, datos reales, `service_role`, proveedores externos ni activación de políticas funcionales. Las pruebas de datos ordinarias terminaron en `ROLLBACK`; para la carrera de notas se creó una base sintética separada.

## 2. Snapshot, hashes y catálogo

Las huellas SHA-256 calculadas independientemente sobre los archivos del snapshot son:

|   # | Migración                                                  | SHA-256                                                            |
| --: | ---------------------------------------------------------- | ------------------------------------------------------------------ |
|  01 | `20260723090100_f2_foundation_identity_admin_clients.sql`  | `7359eed69f4e65b25ecf06c94de384693b4887446eb555d7b1ddad0037920108` |
|  02 | `20260723090200_f2_projects_and_operations.sql`            | `42513df59ae124f33e50537866acd355e5dd3f7cbff1201d91ae191487efba75` |
|  03 | `20260723090300_f2_integrations_approvals_ai_platform.sql` | `96f4a4f32bb7378559d206ca2d3f75c5dd96f5f6b4357107bfde0e7039c76623` |
|  04 | `20260723090400_f2_invariants_and_indexes.sql`             | `f619c2072c92c0f8da3b13ff35c52b93a2a1aca70e8c10a4fdd09bcc63b6d5e8` |
|  05 | `20260723090500_f2_rls_fail_closed.sql`                    | `7916b0fcca34f49d1b58021337f554b883b7b72d7042c25854268189f312fb2f` |
|  06 | `20260723090600_f2_schedule_assignment_history.sql`        | `cf5a517ab5136782b474c4973147ad4eed08ea728d92308a07f28a71c8d0e203` |
|  07 | `20260723090700_f2_identity_assignment_history.sql`        | `aac69ca77818e580064ee001917ce293a41cbc9712d57e10107d98eb4a5a837a` |
|  08 | `20260723090800_f2_polymorphic_resource_scope.sql`         | `16c9daf346bd406b707fa5fd1bcc2283df1396179d5b08e26271b31c18f70076` |
|  09 | `20260723090900_f2_work_type_external_capabilities.sql`    | `e2a663e564dcc4ad1939847a7187376cfb64b80a9e2e4b9798bfc26e6934ccc5` |
|  10 | `20260723091000_f2_concurrent_graph_invariants.sql`        | `b78a7340281d4688bc735d9abf05996b62e13fbf7db2f0186da6f19620a875fd` |
|  11 | `20260723091100_f2_active_assignment_uniqueness.sql`       | `3a7db2ce0beb3bb8b20935316cba5f2837bd009bbc01f3ecc0d84273df8ba3bb` |
|  12 | `20260723091200_f2_management_note_revision_chain.sql`     | `f4f94a62b2f8b374933cc526d477655901505ba484e455e20bfec627ac1851f0` |
|  13 | `20260723091300_f2_catalog_value_code_immutable.sql`       | `c6b8a220b4c2df7486306ea9908535b40714dac35e04ba5ebe9f9ed4fa48ab8f` |
|  14 | `20260723091400_f2_private_function_default_acl.sql`       | `3a039765c15c1375bb763ca7853ba4498e190dadc037ec0f7a89e9891d3a5c07` |
|  15 | `20260723091500_f2_external_procedure_creation_scope.sql`  | `9b51a5f1d1648126cf264ca8af7b64d7084dc48eb53d5e013c722c0a83d11769` |
|  16 | `20260723091600_f2_protected_codes_immutable.sql`          | `c65119365b81bcdc1ac0fa6a9c20b959353fd17fe4f26fb872f1698db6b43125` |
|  17 | `20260723091700_f2_user_specialty_reassignment.sql`        | `d8e84938f4f8c6fc836bbc8373ee241fe7e9f0f54dbfa02c5055b0f2dd154e48` |
|  18 | `20260723091800_f2_work_type_change_approval_binding.sql`  | `6630d306be72d1fea78a9e23065954b28dfb87d90819e62f9848785a824dfab4` |

El catálogo de `jbc_f2_clean_r4` devolvió `57` tablas, `226` FK, `155` índices, `128` triggers, `57/57` tablas con RLS habilitada y forzada, y `0` políticas. También devolvió cero FK con `ON DELETE CASCADE`, cero tiempos `*_at` fuera de `timestamptz`, cero columnas binarias/contenido, cero vistas/RPC públicas, cero funciones privadas `SECURITY DEFINER` y cero funciones `app_private` ejecutables por `PUBLIC`, `anon` o `authenticated`.

La ruta incremental conservó `R3-INCREMENTAL | Contratación incremental R3 | version=1 | Trabajo incremental R3 | version=1`.

## 3. Reproducción exacta de la huella

Se ejecutó literalmente el comando PowerShell documentado en `F02-INTEGRATION-CHECKS-2026-07-23.md`: `pg_dump --schema-only --no-owner --no-privileges`, eliminación exclusiva de líneas `\restrict`/`\unrestrict`, unión con LF, UTF-8 sin BOM, sin LF final y SHA-256 en memoria.

```text
Clean=b49049cb01164cd0837175239812832cd235209fd88d8a3d6940ae0ebfd23685
Incremental=b49049cb01164cd0837175239812832cd235209fd88d8a3d6940ae0ebfd23685
Equal=True
Bytes=245129
```

La huella publicada queda reproducida exactamente; se cierra `F2-R3-P2-02`.

## 4. Cierre de hallazgos R3

| Hallazgo R3                                    | Resultado R4 | Evidencia                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ---------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| P1-01 — predicado contradictorio en arnés RLS  | **CERRADO**  | La gramática canónica exacta está en `00_surface_manifest.sql:219`; `SELECT` y `DELETE` solo admiten `where id='<objetivo>'`, y `UPDATE` termina exactamente en ese predicado. El preflight de propietario de `20_rls_matrix.sql:591-736` ejecuta cada caso en subtransacción revertida y exige UUID, fila, alcance y propietario tipados. `50_rls_harness_guards.psql:109-139` rechaza el objetivo real con `AND 1=0`. Prueba independiente: `RLS-HARNESS-GUARDS PASS`.             |
| P1-02 — cambio de tipo no ligado a lo aprobado | **CERRADO**  | Migración 18: payload/identidad invariables (`:6-52`); solicitud `executing` + ejecución `running` y misma correlación (`:107-143`); decisión aprobatoria sin rechazo (`:145-163`); igualdad exacta de `requested_change` y fotografía anterior (`:165-173`); consumo de ejecución y solicitud (`:227-242`). `44_work_type_change_approval.psql` rechazó mismatch, ausencia de decisión, ausencia de ejecución, ejecución consumida y reutilización, y aceptó solo el cambio exacto. |
| P2-01 — padre de nota de otra Gestión          | **CERRADO**  | Caso permanente en `40_invariants.psql:555-586`; obtuvo `23514`.                                                                                                                                                                                                                                                                                                                                                                                                                     |
| P2-02 — huella no reproducible                 | **CERRADO**  | Comando, opciones, codificación, LF, bytes y hash exactos documentados y reproducidos como se muestra arriba.                                                                                                                                                                                                                                                                                                                                                                        |
| P2-03 — historia APT posterior al cambio       | **CERRADO**  | El camino válido de `44_work_type_change_approval.psql` cambia de Plano de catastro, conserva APT inactivo y luego rechaza reactivación, cambio de proveedor y traslado de alcance con `23514` (`:209-227`).                                                                                                                                                                                                                                                                         |
| P3-01 — propiedad de revisores obsoleta        | **CERRADO**  | `FILE_OWNERSHIP.md:28-30` marca R2 y R3 completados y registra la ruta exclusiva de R4.                                                                                                                                                                                                                                                                                                                                                                                              |

## 5. Pruebas independientes ejecutadas

| Comando/control                                                    | Resultado                                                                                                |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| `run_structure.psql` sobre `jbc_f2_clean_r4`                       | `RLS-STRUCT PASS`, 57 tablas, 0 vistas, 0 funciones públicas                                             |
| `40_invariants.psql`                                               | `F2-INVARIANTS PASS`; incluye asignaciones, códigos, nota de otra Gestión y alcance Proyecto; `ROLLBACK` |
| `42_external_procedure_type_matrix.psql`                           | `F2-EXTERNAL-TYPE-MATRIX PASS`; 16 altas APT/SIRI rechazadas                                             |
| `44_work_type_change_approval.psql`                                | `F2-WORK-TYPE-APPROVAL PASS`; control exacto y consumo único                                             |
| `50_rls_harness_guards.psql`                                       | `RLS-HARNESS-GUARDS PASS`; cinco mutantes rechazados, incluido `AND 1=0`                                 |
| `run_rls.psql -v dec_0103_approved=0`                              | bloqueo esperado: `RLS-MATRIX BLOCKED: DEC-0103 no aprobada`                                             |
| `run_rls.psql -v dec_0103_approved=1` con `30_case_data.sql` vacío | fallo esperado por cobertura CRUD incompleta en `roles/administrator/SELECT`; no hay falso PASS vacío    |
| carrera de revisiones de nota, dos conexiones                      | sesión competidora `23505`; aserción `F2-NOTE-RACE PASS`, rev1=1 y rev2=1                                |
| `pnpm --dir packages/contracts run typecheck`                      | **PASS**                                                                                                 |
| `pnpm --dir packages/contracts run verify`                         | **PASS**: 92 referencias OpenAPI, 9 eventos, DAG 15/15                                                   |
| huella limpia/incremental                                          | ambas `b49049cb…`, `Equal=True`, `245129` bytes                                                          |

No se contó el Redocly temporal como ejecución R4 porque no está fijado en las dependencias locales del paquete; el verificador contractual propio sí pasó y la evidencia integrada registra Redocly 2.40.0 con cero errores/advertencias. Esto no abre un defecto del snapshot revisado.

## 6. Auditoría de RF e invariantes

| Alcance                         | Resultado R4                                                                                                                                                                                           |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| RF-019 — modelo de datos        | **CONFORME para Fase 2**: entidades y pares Proyecto/Trabajo presentes; FK restrictivas; UUID/UTC/versión/archivo/historia; índices; sin cascadas ni binarios; RLS forzada.                            |
| RF-002 — tipos y APT/SIRI       | **CONFORME**: capacidades físicas exactas, 16 altas negativas y conservación histórica solo después de un cambio aprobado. Estado interno y externo permanecen separados.                              |
| RF-010 — identidad y seguridad  | **CONFORME estructural/fail-closed**: 57/57 RLS forzada, ACL privadas cerradas, 0 políticas prematuras; la autorización funcional por rol sigue correctamente no demostrada hasta `DEC-0103`.          |
| RF-012 — arquitectura/contratos | **CONFORME**: `ResourceScope` discriminado, contratos versionados, puertos de consulta APT/SIRI, 92 referencias resueltas, 9 eventos y DAG sin ciclos.                                                 |
| RF-015 — aprobaciones/auditoría | **CONFORME para el corte físico**: decisión y ejecución separadas; cambio de tipo exacto, versión/fotografía, ejecución vigente y consumo único; superficies históricas append-only.                   |
| AC-016-08 — concurrencia        | **CONFORME**: pertenencia de Trabajo invariable, serialización por fila estable de Trabajo para grafos, versión explícita y carrera de notas con un único ganador.                                     |
| RF-013 — Excel                  | **AUSENTE**: no se encontró ruta, contrato, migración, trabajador ni superficie activa de importación/sincronización; las apariciones son prohibiciones, trazabilidad o exportación futura autorizada. |

## 7. Hallazgos R4

| Prioridad | Abiertos |
| --------- | -------: |
| P0        |    **0** |
| P1        |    **0** |
| P2        |    **0** |
| P3        |    **0** |

No se reprodujeron los P1 de R3 ni se identificaron defectos nuevos dentro del alcance cerrado de esta regresión.

## 8. Riesgos residuales y delimitación

- `DEC-0103` continúa pendiente. La ausencia intencional de políticas y casos funcionales no es un defecto técnico del corte pre-DEC; mantiene el esquema denegado por defecto.
- `AC-010-01/02` sigue **NO DEMOSTRADA**: todavía no hay pruebas positivas/negativas reales de Administrador, Coordinador, Técnico y Solo lectura.
- La matriz de permisos propuesta no puede considerarse vigente ni derivarse de este GO. Debe aprobarse explícitamente, registrarse y materializarse en una migración aditiva con fixtures reales.
- No se realizó conexión real APT/SIRI, escritura OneDrive, uso de `service_role` ni trabajo de Fase 3.

## 9. Dictamen delimitado

**GO técnico para congelar el alcance autorizado de Fase 2 previo a `DEC-0103`.** La regresión independiente R4 confirma el cierre de los `2 P1`, `3 P2` y `1 P3` de R3, las rutas limpia/incremental idénticas y `0 P0/P1` abiertos.

**Este GO no cierra G2.** G2 permanece bloqueado hasta que, en este orden:

1. el usuario apruebe explícitamente `DEC-0103` sin reinterpretación;
2. se registren la decisión y la matriz vigente;
3. una migración aditiva implemente exactamente esas políticas;
4. fixtures completos produzcan `RLS-STRUCT PASS` y `RLS-MATRIX PASS` reales para cuatro roles, CRUD, alcances, propiedad, revocados/no autorizados e indirectos;
5. una regresión independiente posterior confirme ese corte funcional con `0 P0/P1`;
6. trazabilidad, estado, reporte y handoff reflejen la evidencia final.

Hasta entonces, el estado correcto es **Fase 2 técnicamente preparada para la decisión; G2 no presentado y Fase 3 no iniciada**.
