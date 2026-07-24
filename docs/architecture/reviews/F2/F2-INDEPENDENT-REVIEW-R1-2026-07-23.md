# Revisión independiente R1 — Fase 2

**ID:** `F2-REV-R1`  
**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Rol:** revisor independiente de arquitectura, datos, contratos y seguridad; sin autoría ni modificación de los artefactos revisados  
**Corte base revisado:** migraciones `20260723090100` a `20260723090600`, contratos con `AggregateVersion >= 1` y postura RLS fail-closed de `20260723090500`  
**Dictamen:** **NO-GO para G2; GO únicamente para continuar el ciclo de correcciones**

Este informe fija el resultado R1 previo a las migraciones correctivas `20260723090700+` y a los cambios contractuales iniciados después de comunicar los hallazgos. Esas correcciones no cierran este R1 por sí mismas: requieren una regresión independiente R2 sobre un corte estable y nuevamente migrado desde cero.

## 1. Alcance y método

Se leyó completamente la especificación aprobada, incluidos sus anexos, `AGENTS.md`, el objetivo adjunto, el plan de Fase 2, handoff de Fase 1, estado, decisiones, riesgos, trazabilidad, criterios, estrategia de pruebas, modelo/diccionario/migraciones, límites, eventos, seguridad, permisos, ADR, OpenAPI/Zod/puertos, las migraciones y el arnés/evidencia F02.

La revisión contrastó `RF-010`, `RF-012`, `RF-015` y `RF-019`; `AC-010-01/02/04`, `AC-012-01/03/05`, `AC-016-08`, `AC-019-01..06` y `EX-013-01`; y los invariantes Proyecto/Contratación `1:N` Trabajos, alcance directo Proyecto/Trabajo, APT/SIRI, OneDrive, archivo, UTC, historia, auditoría, outbox, idempotencia, aislamiento del dominio, RLS y ausencia de RF-013.

Métodos usados:

- inspección línea por línea de SQL, TypeScript, YAML y documentos;
- consultas de catálogo en PostgreSQL 17.10 local;
- ejecución independiente de verificadores estáticos, contratos, DAG y estructura RLS;
- reproducciones SQL sintéticas dentro de transacciones terminadas en `ROLLBACK`;
- análisis de carreras MVCC de dos transacciones y contraste de la cobertura real del arnés;
- revisión explícita de ACL de `app_private`, RLS forzada, FK, fechas, binarios, contratos y evidencia.

## 2. Resumen de hallazgos abiertos R1

| Prioridad | Abiertos | Consecuencia                                                            |
| --------- | -------: | ----------------------------------------------------------------------- |
| P0        |    **0** | —                                                                       |
| P1        |    **4** | impiden G2 y exigen corrección + R2                                     |
| P2        |    **4** | deben corregirse o aceptarse explícitamente antes de congelar el modelo |
| P3        |    **1** | defecto de reproducibilidad documental                                  |

## 3. Hallazgos P1

### F2-REV-P1-01 — El arnés funcional RLS puede producir un falso PASS sin probar la superficie declarada

**Archivos/líneas del corte R1:** `supabase/tests/20_rls_matrix.sql:23-45`, `:47-160`, `:172-231`; `supabase/tests/00_surface_manifest.sql:87-105`.

`surface_name`, `operation`, `app_role` y `scope_case` son etiquetas. El ejecutor solo corre `command_sql` libre y compara `row_count` o SQLSTATE; no demuestra que el comando toque `surface_name`, que realice `operation`, que use el registro de alcance declarado ni que deje la postcondición esperada. Por ejemplo, una matriz completa puede etiquetar un caso como `INSERT projects` y ejecutar `select 1 where false` con `expected_rows=0`; las comprobaciones de cobertura y el runner lo aceptarían.

La clasificación monovalente del manifiesto agrava el problema: tablas con alcance `organization|project|work` o `client|project_root|work` se etiquetaban solo como `work`, `self` o `backend`, por lo que no se exigían todas sus variantes físicas.

**Impacto:** `RLS-MATRIX PASS` podría no sustentar `AC-010-01`, `AC-010-02` ni el gate G2. Es el riesgo explícito de falso GO que la revisión debía detectar.

**Corrección exigida:** casos tipados/estructurados por superficie y operación, sin SQL arbitrario como única autoridad; validación de alcance y claves del fixture; precondición y postcondición verificables; cobertura por cada alcance soportado; y un mutante negativo que demuestre que etiquetar una consulta inocua como DML no puede pasar.

### F2-REV-P1-02 — El alcance Proyecto era incoherente entre aprobaciones, auditoría, eventos y contratos

**Archivos/líneas del corte R1:**

- `supabase/migrations/20260723090300_f2_integrations_approvals_ai_platform.sql:222-299` y `:302-328`;
- `supabase/migrations/20260723090400_f2_invariants_and_indexes.sql:372-414`;
- `packages/contracts/src/approval.ts:24-87`;
- `packages/contracts/src/events.ts:69-76`, `:102-139`;
- `packages/contracts/src/ports.ts:18-24`, `:39-59`;
- `docs/api/openapi.yaml:22-141`, `:369-433`.

`approval_targets` y `approval_requests` aceptaban alcance Proyecto (`project_id` no nulo, `work_id` nulo), pero `approval_decisions` y `approval_executions` lo prohibían con un check que solo admitía ambos nulos o ambos no nulos. A la vez, `validate_approval_scope()` exigía igualdad con el padre. Resultado: una solicitud válida para archivar/cerrar/cancelar un Proyecto no podía decidirse ni ejecutarse.

La reproducción sintética creó Proyecto+Trabajo, objetivo y solicitud con `scope_kind='project'`; el `INSERT approval_decisions(project_id, work_id=NULL, ...)` falló con:

```text
ERROR: new row for relation "approval_decisions" violates check constraint
       "approval_decisions_work_pair"
```

Zod/OpenAPI/puertos exigían además `workId` para toda aprobación y auditoría, aunque `RF-015` controla acciones de Proyecto y `project.archived.v1` lleva `approvalRequestId`. El mismo patrón impedía representar limpiamente notificaciones, auditoría y outbox de Proyecto mediante sus columnas directas.

**Impacto:** el flujo sensible obligatorio de Proyecto era imposible y OpenAPI↔Zod↔persistencia no era coherente. Afecta RF-015, AC-019-02/03 y la separación decisión/ejecución.

**Corrección exigida:** alcance discriminado y cerrado `organization | project | work` en persistencia, Zod, OpenAPI, eventos y puertos; FK/checks que obliguen `projectId` en Proyecto y el par completo en Trabajo; pruebas de solicitar, decidir, ejecutar, auditar y emitir `project.archived.v1` sin inventar un Trabajo.

### F2-REV-P1-03 — El catálogo mutable permitía activar APT fuera de Plano de catastro

**Archivos/líneas:** `20260723090100_f2_foundation_identity_admin_clients.sql:344-377`; `20260723090400_f2_invariants_and_indexes.sql:146-182`.

El único check era `supports_siri => supports_apt`; no fijaba que solo `code='plano_catastro'` pudiera tener ambas capacidades. `validate_external_procedure_work_type()` confiaba en esos booleanos mutables. En una transacción sintética se ejecutó `UPDATE work_types SET supports_apt=true WHERE code='croquis'`; después se creó un Trabajo Croquis y un procedimiento APT activo. El `INSERT` pasó:

```text
DEFECT_REPRODUCED | croquis | supports_apt=t | provider=apt | is_active=t
```

**Impacto:** rompe un invariante no negociable de RF-002/RF-006/RF-014 y contradice la evidencia que solo probaba el seed actual, no su integridad bajo actualización autorizada.

**Corrección exigida:** restricción física que vincule capacidades con los cinco códigos estables, protección de código/capacidades y negativos que intenten modificar Croquis/Delimitación/Curvas/Avalúo. El control debe seguir rechazando APT/SIRI aunque una acción administrativa intente alterar el catálogo.

### F2-REV-P1-04 — Las garantías `1:N` y acíclicas no resisten escrituras concurrentes

**Archivos/líneas:** `20260723090400_f2_invariants_and_indexes.sql:108-144`, `:295-370`.

Los triggers consultan el snapshot MVCC sin bloquear una clave común, usar advisory lock ni exigir aislamiento serializable:

- con dos Trabajos W1/W2 en A, dos transacciones pueden mover simultáneamente W1 y W2 a otros Proyectos; cada constraint trigger diferido todavía ve el Trabajo no confirmado de la otra y ambos commits dejan A vacío;
- dos transacciones pueden confirmar simultáneamente `A.parent=B` y `B.parent=A`;
- el mismo intercalado permite dependencias `A→B` y `B→A`.

La evidencia solo cubría un ciclo secuencial. No existe bloqueo o prueba de dos conexiones en migraciones, contratos ni evidencia.

**Impacto:** puede romper Proyecto `1:N` Trabajo y AC-004-02 bajo concurrencia real, precisamente cuando el esquema afirma garantizarlos.

**Corrección exigida:** serializar por agregado/grafo con un mecanismo documentado y seguro, o hacer inmutable la pertenencia del Trabajo cuando corresponda; adquirir bloqueos en orden estable para Proyecto antiguo/nuevo; y ejecutar carreras reproducibles con dos conexiones que prueben que uno de los commits falla.

## 4. Hallazgos P2

### F2-REV-P2-01 — Asignaciones de identidad/alcance podían borrarse y duplicarse activas

**Archivos/líneas:** `20260723090100_f2_foundation_identity_admin_clients.sql:133-182`, `:208-230`; `20260723090200_f2_projects_and_operations.sql:109-160`; `20260723090400_f2_invariants_and_indexes.sql:79-105`.

`user_roles`, `role_permissions` y `user_specialties` tenían cierre/revocación, pero no trigger de rechazo de `DELETE`. Las membresías de Proyecto/Trabajo permitían varias filas activas para el mismo usuario porque la unicidad incluía `assigned_at`; cerrar una fila podía dejar otra concediendo alcance.

El assert estructural endurecido durante R1 lo confirmó con `RLS-STRUCT FAIL [tabla archivable sin rechazo físico de DELETE]: user_roles`.

**Corrección exigida:** no-delete físico, unicidad parcial de concesión/membresía activa y pruebas de duplicado, cierre y revocación completa.

### F2-REV-P2-02 — La cadena de revisiones de notas no valida identidad lógica ni consecutividad

**Archivo/líneas:** `20260723090200_f2_projects_and_operations.sql:339-360`.

El check solo distingue revisión 1 sin padre de revisión >1 con padre. Permite que revisión 99 de la nota lógica B apunte a revisión 1 de la nota A, siempre dentro de la misma gestión.

**Impacto:** la historia append-only existe, pero su encadenamiento puede ser falso; contradice el diccionario y AC-003-04.

**Corrección exigida:** validar que el padre comparte `logical_note_id` y tiene `revision = NEW.revision - 1`, más casos negativos y carrera de dos revisiones simultáneas.

### F2-REV-P2-03 — Los códigos declarados invariables eran mutables

**Archivos/líneas:** `20260723090100_f2_foundation_identity_admin_clients.sql:308-342`, y por extensión códigos contractuales en `roles`, `permissions`, `catalogs` y `work_types`.

`catalog_values.code` tiene unicidad y versión, pero un `UPDATE` puede reescribirlo. RF-014 exige código invariable; varios de estos códigos también forman contratos y eventos.

**Corrección exigida:** proteger físicamente los códigos invariables, distinguiendo etiqueta/descripción editable de identidad estable; demostrar el rechazo.

### F2-REV-P2-04 — La evidencia no correspondía al último esquema del corte R1

**Archivos/líneas:** `docs/testing/evidence/F02/F02-INTEGRATION-CHECKS-2026-07-23.md:15-44`; `docs/architecture/MIGRATION_STRATEGY.md:30-41`, `:103-116`; `docs/architecture/DATA_DICTIONARY.md:3`.

Después de añadir 05/06, la evidencia seguía describiendo rutas `01→04`, cinco hashes sin 06 y conteos `214 FK/110 triggers`; el catálogo actual tras 06 devolvía `57 tablas`, `218 FK`, `151 índices` y `114 triggers`. `DATA_DICTIONARY` declaraba alineación hasta 05 aunque ya describía campos de 06, y la comparación de la estrategia aún terminaba en `01→04`.

**Impacto:** la migración limpia/actualizada y su huella no prueban el corte que se pretendía revisar.

**Corrección exigida:** reconstruir dos bases desechables desde todas las migraciones del corte final, repetir fixture incremental, comparar huellas y registrar hashes/conteos/comandos exactos después de todas las correcciones.

## 5. Hallazgo P3

### F2-REV-P3-01 — El typecheck no tenía un comando local estable

**Archivos/líneas:** `packages/contracts/package.json:1-20`; evidencia F02 `:61-69`.

El reporte afirmaba `tsc --noEmit -p packages/contracts/tsconfig.json` PASS, pero `package.json` no ofrecía script `typecheck` y `pnpm --dir packages/contracts exec tsc ...` devolvió `"tsc" no se reconoce` en el workspace. La ejecución directa `node packages/contracts/node_modules/typescript/bin/tsc -p ... --noEmit` sí pasó.

**Corrección exigida:** fijar un script/comando reproducible y registrar exactamente el ejecutable/versiones usados.

## 6. Controles que sí pasaron en R1

Estos resultados son parciales y no compensan los hallazgos:

- PostgreSQL 17.10 reportó 57 tablas `public`; 57/57 con RLS habilitada y forzada tras `20260723090500`.
- `anon` y `authenticated` no tenían `USAGE` sobre `app_private`; ninguna función privada era ejecutable por esos roles o `PUBLIC`; las 12 funciones privadas eran `security invoker`, con `search_path=pg_catalog, public` y ACL solo del propietario local.
- No había vistas, vistas materializadas ni RPC en `public`.
- Tras 06: 218/218 FK con `ON DELETE RESTRICT`; cero cascadas.
- Cero columnas persistidas `*_at` distintas de `timestamptz`; cero `bytea`/`oid` o nombres de contenido/binario/blob en la superficie.
- El par Proyecto/Trabajo y sus FK compuestas rechazaron referencias discordantes en los casos secuenciales ejecutados.
- Proyecto sin Trabajo, borrado de Proyecto, cambio de tipo sin contexto, append-only, idempotencia duplicada y ciclo secuencial fueron rechazados en la evidencia previa.
- `node packages/contracts/scripts/verify-contracts.mjs`: PASS, 71 referencias y 9 nombres de evento; `verify-dag.mjs`: PASS sobre el grafo declarado de 15 nodos. Estos verificadores son comprobaciones de diseño, no equivalen a integración de módulos todavía inexistentes.
- TypeScript pasó mediante ejecución directa del compilador local.
- `verify_static.ps1`: 57 tablas de migración = 57 del manifiesto, cero vistas/RPC públicas y gate `DEC-0103=0`.
- RF-013 continuó sin rutas, contratos, migraciones o trabajadores activos; las menciones encontradas eran prohibiciones/prueba de ausencia o texto del prototipo manual.
- No se inició Fase 3 ni se conectaron proveedores reales.

## 7. RLS, DEC-0103 y G2

`DEC-0103` seguía **pendiente**. R1 verificó la postura fail-closed estructural, no una matriz funcional:

- no había políticas funcionales;
- `anon`/`authenticated` no tenían privilegios de tabla;
- `run_rls.psql` con `dec_0103_approved=0` debía terminar bloqueado;
- `30_case_data.sql` estaba vacío intencionalmente.

Por tanto, RLS positiva/negativa por Administrador, Coordinador, Técnico y Solo lectura estaba **NO EJECUTADA/BLOQUEADA**, `AC-010-01/02` no estaba demostrada y G2 no podía presentarse. Esto es un bloqueo correcto, no un defecto ni una autorización para inventar la decisión.

## 8. Comandos y resultados principales

```text
node packages/contracts/scripts/verify-contracts.mjs
  PASS: 71 OpenAPI refs, 9 eventos

node packages/contracts/scripts/verify-dag.mjs
  PASS: 15 nodos visitados

powershell -File supabase/tests/verify_static.ps1
  PASS: migration=57, manifest=57, views=0, functions=0, gate=0

catálogo PostgreSQL
  57 tablas; 57 RLS enabled; 57 RLS forced
  218 FK restrictivas; 151 índices; 114 triggers tras 06
  0 fechas *_at no-timestamptz; 0 binarios

ACL app_private
  anon/authenticated USAGE=false
  12 funciones privadas, security invoker, EXECUTE cliente/PUBLIC=false

reproducción aprobación Proyecto
  FAIL real esperado del defecto: approval_decisions_work_pair

reproducción APT en Croquis tras mutar catálogo
  DEFECT_REPRODUCED: procedimiento APT activo aceptado

RLS-STRUCT tras añadir asserts de historia
  FAIL: user_roles archivable sin rechazo físico de DELETE

pnpm --dir packages/contracts exec tsc ...
  FAIL de comando: tsc no reconocido
node .../typescript/bin/tsc ...
  PASS de tipos
```

No se usó red, no se instalaron dependencias durante la revisión, no se conectó APT/SIRI/OneDrive/OpenAI/Push y las reproducciones de datos terminaron en `ROLLBACK`.

## 9. Dictamen y condición exacta para G2

**GO para continuar correcciones; NO-GO para presentar o aprobar G2.**

G2 solo puede presentarse cuando, sobre un único corte estable posterior a R1:

1. los cuatro P1 y los P2 anteriores estén corregidos o, para un P2 no corregido, exista aceptación material explícita y trazable;
2. una regresión independiente R2, realizada por un revisor distinto del autor de las correcciones, confirme 0 P0/P1;
3. `DEC-0103` esté aprobada explícitamente y registrada sin reinterpretación;
4. las políticas/matriz/fixtures implementen exactamente esa decisión y el arnés endurecido ejecute casos positivos/negativos reales de los cuatro roles, todos los CRUD, todos los alcances soportados, referencias indirectas, revocados/no autorizados, vistas/RPC y tablas append-only, sin `service_role`;
5. `RLS-STRUCT PASS` y `RLS-MATRIX PASS` provengan del esquema final, no del corte pre-corrección;
6. migración limpia e incremental ejecuten **todas** las migraciones finales, produzcan huella idéntica y conserven el fixture;
7. las carreras concurrentes de `1:N`, jerarquía y dependencias demuestren que solo un commit incompatible puede prosperar;
8. OpenAPI, Zod, puertos, eventos, persistencia y documentación representen coherentemente alcances organización/Proyecto/Trabajo;
9. trazabilidad, decisiones, riesgos, estado, evidencia, reporte y handoff reflejen ese mismo corte y sus hashes;
10. RF-013 siga ausente y Fase 3 permanezca sin iniciar.

Hasta entonces el estado correcto es **Fase 2 en corrección; G2 bloqueado**.
