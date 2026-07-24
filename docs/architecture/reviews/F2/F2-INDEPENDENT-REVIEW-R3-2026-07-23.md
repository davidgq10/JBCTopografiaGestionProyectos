# Revisión independiente R3 — Fase 2

**ID:** `F2-REV-R3`  
**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Rol:** revisor independiente de arquitectura, datos, contratos y seguridad; no autor del corte y sin modificaciones fuera de este informe  
**Snapshot:** migraciones `20260723090100`→`20260723091700`, contratos/OpenAPI, arneses `supabase/tests/**` y evidencia F02 disponibles al iniciar R3  
**Dictamen:** **NO-GO técnico para el alcance previo a DEC-0103; G2 continúa bloqueado**

## 1. Alcance y método

Se leyeron completamente `AGENTS.md`, `Especificacion_Requerimientos_Plataforma_JBC.txt` con todos sus anexos, R1, R2, el plan de Fase 2, migraciones 01–17, contratos Zod/TypeScript, OpenAPI, puertos, eventos, modelo/diccionario/estrategia de datos, seguridad/permisos, trazabilidad, estado, riesgos, arneses SQL y evidencia F02.

La revisión contrastó RF-019 completo y los soportes de RF-002, RF-010, RF-012, RF-015 y RF-016; los criterios inmediatos `AC-010-01/02/04`, `AC-012-01/03/05`, `AC-016-08`, `AC-019-01..06` y `EX-013-01`; y los invariantes Proyecto/Contratación `1:N` Trabajos, APT/SIRI, OneDrive, archivo, IA, RLS fail-closed, UTC, auditoría append-only, secretos y concurrencia.

Se usó PostgreSQL 17.10 local en el contenedor `jbc-f2-pg`, sin red, datos reales, `service_role`, proveedores externos ni activación de políticas. Las reproducciones de hallazgos se ejecutaron dentro de transacciones terminadas en `ROLLBACK`.

## 2. Snapshot y huellas

Las huellas SHA-256 de las 17 migraciones revisadas coinciden con la tabla de evidencia vigente:

|   # | SHA-256                                                            |
| --: | ------------------------------------------------------------------ |
|  01 | `7359eed69f4e65b25ecf06c94de384693b4887446eb555d7b1ddad0037920108` |
|  02 | `42513df59ae124f33e50537866acd355e5dd3f7cbff1201d91ae191487efba75` |
|  03 | `96f4a4f32bb7378559d206ca2d3f75c5dd96f5f6b4357107bfde0e7039c76623` |
|  04 | `f619c2072c92c0f8da3b13ff35c52b93a2a1aca70e8c10a4fdd09bcc63b6d5e8` |
|  05 | `7916b0fcca34f49d1b58021337f554b883b7b72d7042c25854268189f312fb2f` |
|  06 | `cf5a517ab5136782b474c4973147ad4eed08ea728d92308a07f28a71c8d0e203` |
|  07 | `aac69ca77818e580064ee001917ce293a41cbc9712d57e10107d98eb4a5a837a` |
|  08 | `16c9daf346bd406b707fa5fd1bcc2283df1396179d5b08e26271b31c18f70076` |
|  09 | `e2a663e564dcc4ad1939847a7187376cfb64b80a9e2e4b9798bfc26e6934ccc5` |
|  10 | `b78a7340281d4688bc735d9abf05996b62e13fbf7db2f0186da6f19620a875fd` |
|  11 | `3a7db2ce0beb3bb8b20935316cba5f2837bd009bbc01f3ecc0d84273df8ba3bb` |
|  12 | `f4f94a62b2f8b374933cc526d477655901505ba484e455e20bfec627ac1851f0` |
|  13 | `c6b8a220b4c2df7486306ea9908535b40714dac35e04ba5ebe9f9ed4fa48ab8f` |
|  14 | `3a039765c15c1375bb763ca7853ba4498e190dadc037ec0f7a89e9891d3a5c07` |
|  15 | `9b51a5f1d1648126cf264ca8af7b64d7084dc48eb53d5e013c722c0a83d11769` |
|  16 | `c65119365b81bcdc1ac0fa6a9c20b959353fd17fe4f26fb872f1698db6b43125` |
|  17 | `d8e84938f4f8c6fc836bbc8373ee241fe7e9f0f54dbfa02c5055b0f2dd154e48` |

La consulta independiente del catálogo final devolvió `57` tablas, `226` FK, `155` índices, `126` triggers y `57/57` tablas con RLS habilitada y forzada. Los dumps en vivo de `jbc_f2_clean_r3` y `jbc_f2_incremental_r3`, creados con `pg_dump --schema-only --no-owner --no-privileges` y omitiendo las líneas aleatorias `\restrict`/`\unrestrict`, produjeron la misma huella independiente: `41ec7aa902cc3c7eb18839abe1120a83ce7d8ef827aae7b11a161121008bcc1d`. El fixture incremental `R3-INCREMENTAL` siguió legible con `version=1` en Proyecto y Trabajo.

## 3. Resumen de severidad

| Prioridad | Abiertos R3 |
| --------- | ----------: |
| P0        |       **0** |
| P1        |       **2** |
| P2        |       **3** |
| P3        |       **1** |

## 4. Hallazgos P1

### F2-R3-P1-01 — El guard de SQL del arnés RLS aún acepta un predicado contradictorio y permite fabricar un negativo

**Archivos/líneas:** `supabase/tests/20_rls_matrix.sql:23-45`, `:179-212`, `:305-322`; `supabase/tests/50_rls_harness_guards.psql:15-105`.

La validación enlaza superficie, operación y UUID por expresiones regulares y verifica que la fila física exista, pero no demuestra que el predicado ejecutado pueda seleccionar o modificar esa fila antes de aplicar RLS. Un caso negativo puede consultar una fila real mediante:

```sql
select id from public.work_types
where id = '<uuid-real>' and 1=0
```

La reproducción R3 insertó ese caso tipado contra el `work_types.code='croquis'` real. Resultado:

```text
lexical_guard_accepts=t | physical_target_exists=t
```

El runner obtendría cero filas con independencia de la política y aceptaría el negativo. La expresión equivalente también puede falsificar `UPDATE/DELETE` esperados con cero filas. Los cuatro mutantes actuales prueban rol, UUID inexistente, etiqueta de hermano y ausencia de postcondición libre, pero no este mutante de comando inocuo/contradictorio exigido desde R1.

**Impacto:** `RLS-MATRIX PASS` seguiría sin constituir evidencia suficiente de `AC-010-01/02`; `F2-REV-P1-01` y `F2-R2-P1-01` continúan abiertos.

**Corrección requerida:** construir los comandos desde columnas tipadas o validar semánticamente un predicado canónico exacto; además, ejecutar cada DML negativo como propietario dentro de una subtransacción para demostrar que afectaría la fila con datos válidos sin RLS. Agregar un mutante automatizado `id=<objetivo> and 1=0` que deba fallar.

### F2-R3-P1-02 — El cambio sensible de tipo no está ligado al cambio aprobado ni exige decisión/ejecución registradas

**Archivos/líneas:** `supabase/migrations/20260723090300_f2_integrations_approvals_ai_platform.sql:222-328`; `supabase/migrations/20260723090400_f2_invariants_and_indexes.sql:213-260`.

`capture_work_type_change()` comprueba que exista una solicitud con estado `approved|executing`, mismo Trabajo y versión, pero no compara `NEW.work_type_id/configuration/state` con `approval_requests.requested_change` ni con el `target_snapshot`. Tampoco exige una `approval_decisions` aprobatoria ni una `approval_executions` vigente.

La reproducción R3 creó una solicitud cuyo `requested_change` era `{"newType":"delimitacion"}`, sin decisiones ni ejecuciones, y actualizó el Trabajo a `avaluo`. Resultado:

```text
MISMATCH_ACCEPTED | actual_type=avaluo
requested_change={"newType":"delimitacion"} | decisions=0 | executions=0
```

Todo se revirtió. No es solo una ausencia funcional futura: el esquema ya pretende ser el control físico del cambio de tipo y acepta ejecutar una acción distinta de la revisada. Esto contradice el comparativo/aprobación de RF-002/RF-014 y la separación decisión→ejecución de RF-015.

**Corrección requerida:** definir una fotografía canónica/huella del cambio exacto, validarla contra `NEW`, exigir decisión aprobatoria y ejecución `running` con alcance/clave coherentes, y demostrar que otra configuración/tipo/estado, una solicitud sin decisión o una ejecución ausente/consumida se rechazan.

## 5. Hallazgos P2

### F2-R3-P2-01 — Falta el negativo de revisión cuyo padre pertenece a otra Gestión

`supabase/tests/40_invariants.psql:497-553` ya demuestra revisión 2 válida, salto y cambio de nota lógica; los scripts `concurrency/43_*` demuestran la carrera. No existe el caso separado exigido por R2 donde `supersedes_note_id` pertenece a otra Gestión. La función parece rechazarlo porque filtra por `management_id`, pero el cierre de `F2-R2-P2-02` sigue incompleto como evidencia permanente.

### F2-R3-P2-02 — La huella publicada no es reproducible con un comando documentado

`docs/testing/evidence/F02/F02-INTEGRATION-CHECKS-2026-07-23.md:47-53` y `docs/architecture/MIGRATION_STRATEGY.md:122-133` publican `1201969d...` y describen únicamente que se eliminan `\restrict`/`\unrestrict`, pero no registran las opciones exactas de `pg_dump`, codificación, finales de línea ni comando de hash. R3 confirmó la igualdad de ambos esquemas, pero obtuvo `41ec7aa9...` con un comando explícito en vivo; las copias `/tmp/clean.sql` y `/tmp/inc.sql` dieron además `85d822f7...` tras la misma eliminación textual. La equivalencia está demostrada, pero la huella publicada no es reproducible, por lo que el cierre documental de `F2-REV-P2-04` es parcial.

### F2-R3-P2-03 — La suite APT/SIRI no conserva todos los negativos de la corrección R2

`supabase/tests/42_external_procedure_type_matrix.psql:72-99` cubre correctamente las 16 altas activa/inactiva por proveedor y cuatro tipos no catastrales. `40_invariants.psql:115-141` cubre una desactivación histórica, pero mientras el Trabajo aún es Plano de catastro. No quedan casos permanentes que creen historia mediante un cambio de tipo aprobado y luego intenten reactivar, cambiar proveedor o trasladar el procedimiento. La inspección de la migración 15 indica que esas transiciones se rechazan y R3 no reproduce el P1 de R2, pero la evidencia pedida para su cierre no está completa.

## 6. Hallazgo P3

### F2-R3-P3-01 — Registro de propiedad de revisores obsoleto

`docs/ai/FILE_OWNERSHIP.md:28` sigue marcando `F2-REV-R2` “en curso”, aunque su informe está cerrado, y no registra la propiedad exclusiva del informe R3. No afecta el esquema, pero contradice el control operativo de propiedad/revisión.

## 7. Cierre de R1 y R2

| Hallazgo previo                                  | Resultado R3                                                                                                   |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| R1 P1-01 / R2 P1-01 — arnés RLS falsable         | **ABIERTO P1**: rol/UUID/alcance mejoraron, pero el predicado contradictorio pasa                              |
| R1 P1-02 — alcance Proyecto transversal          | **CERRADO**: persistencia y `ResourceScope` discriminado son coherentes                                        |
| R1 P1-03 / R2 P1-02 — APT/SIRI fuera de catastro | **CERRADO en implementación**; queda P2 de regresión permanente                                                |
| R1 P1-04 — carreras de 1:N/grafos                | **CERRADO**: pertenencia invariable y bloqueo común; evidencia concurrente presente                            |
| R1 P2-01 / R2 P2-01 — ciclo de asignaciones      | **CERRADO**: duplicado, cierre, reotorgamiento, historia y no-delete pasan en todas las superficies enumeradas |
| R1 P2-02 / R2 P2-02 — cadena de notas            | **PARCIAL P2**: implementación y carrera pasan; falta padre de otra Gestión                                    |
| R1 P2-03 — códigos invariables                   | **CERRADO**: migraciones 13/16 y negativos vigentes                                                            |
| R1 P2-04 — evidencia de esquema final            | **PARCIAL P2**: igualdad 01→17 confirmada; huella publicada no reproducible                                    |
| R1 P3-01 — typecheck reproducible                | **CERRADO**                                                                                                    |
| R2 P3-01 — nota Docker obsoleta                  | **CERRADO**                                                                                                    |

R3 agrega `F2-R3-P1-02`, que no estaba enumerado por R1/R2.

## 8. Comandos y resultados independientes

```text
pnpm --dir packages/contracts run typecheck
  PASS

pnpm --dir packages/contracts run verify
  PASS: 92 referencias OpenAPI, 9 eventos, DAG 15/15

psql -f run_structure.psql
  RLS-STRUCT PASS | 57 tablas | 0 vistas | 0 funciones public

psql -f 40_invariants.psql
  F2-INVARIANTS PASS; ROLLBACK

psql -f 42_external_procedure_type_matrix.psql
  F2-EXTERNAL-TYPE-MATRIX PASS | 16 rechazados; ROLLBACK

psql -f 50_rls_harness_guards.psql
  RLS-HARNESS-GUARDS PASS (los cuatro mutantes existentes)

run_rls.psql -v dec_0103_approved=0
  RLS-STRUCT PASS; RLS-MATRIX BLOCKED esperado

run_rls.psql -v dec_0103_approved=1, con 30_case_data vacío
  FAIL esperado por cobertura CRUD incompleta; no existe PASS vacío

catálogo PostgreSQL
  57 tablas | 226 FK | 155 índices | 126 triggers | 57/57 RLS enabled+forced
  policies=0 | cascades=0 | non_tz_dates=0 | binary=0
  app_private ejecutable por PUBLIC/authenticated=0
  public functions/views=0 | security-definer privadas=0

carrera management_notes
  una revisión 2 confirmada; competidora 23505; assert 1x rev1 y 1x rev2 PASS

mutante contradictorio RLS
  lexical_guard_accepts=t | physical_target_exists=t

mutante aprobación/cambio de tipo
  MISMATCH_ACCEPTED | requested=delimitacion | actual=avaluo | decisions=0 | executions=0
```

El intento de ejecutar Redocly desde la raíz no fue reproducible con el paquete local porque no existe `package.json` raíz ni Redocly fijado en `packages/contracts`; no se usó red para instalarlo. El verificador contractual propio y el typecheck sí pasaron.

## 9. Controles conformes y riesgos residuales

- Proyecto/Contratación `1:N` Trabajo, FK compuestas, no cascadas y pertenencia invariable: conformes.
- APT/SIRI: altas nuevas activa/inactiva rechazadas fuera de Plano de catastro; no existe puerto de escritura ni endpoint de carga.
- Binarios: ausentes; OneDrive se representa solo con metadatos e identificadores.
- Auditoría, eventos externos, decisiones y otras superficies históricas inventariadas: append-only físico.
- UTC: todas las columnas persistidas `*_at` son `timestamptz`.
- ACL: `public`, `anon` y `authenticated` no ejecutan funciones privadas; no hay RPC/vistas públicas.
- Contratos: `ResourceScope` cerrado `organization|project|work`; 92 referencias resueltas; eventos versionados; DAG sin ciclos.
- RF-013: no se encontró superficie activa de importación/sincronización Excel.
- No se inició Fase 3 ni se usaron conexiones reales.

Riesgos residuales: `DEC-0103` continúa abierta; no existen políticas funcionales ni casos por rol, por lo que `AC-010-01/02` permanece **NO DEMOSTRADA**. La ausencia de políticas y grants mantiene el sistema fail-closed; no corrige los P1 del arnés o de aprobaciones.

## 10. Dictamen delimitado

**NO-GO para congelar el alcance técnico previo a DEC-0103**, por `2 P1` reproducibles. La base física, contratos y migraciones 01→17 muestran avances sustanciales, pero el arnés todavía puede certificar un negativo fabricado y el cambio de tipo puede ejecutar una mutación distinta de la aprobada sin decisión/ejecución registradas.

**G2 permanece necesariamente bloqueado**, incluso después de corregir estos P1, hasta que ocurran todos los puntos siguientes:

1. corrección y regresión independiente distinta con `0 P0/P1`;
2. aprobación explícita de `DEC-0103` sin reinterpretación;
3. políticas y fixtures conformes a esa decisión;
4. `RLS-STRUCT PASS` y `RLS-MATRIX PASS` reales por cuatro roles, CRUD, alcances, propiedad, revocados/no autorizados e indirectos;
5. evidencia final reproducible y trazabilidad/estado/handoff actualizados;
6. RF-013 ausente y Fase 3 sin iniciar hasta aprobación expresa de G2.
