# Revisión independiente R2 — Fase 2

**ID:** `F2-REV-R2`  
**Fecha:** 2026-07-23 (`America/Costa_Rica`)  
**Rol:** revisor independiente; sin autoría de las correcciones y sin modificación de artefactos fuera de este informe  
**Corte congelado:** migraciones `20260723090100` a `20260723091400`; matriz RLS de 393 líneas observada y ejecutada al inicio de R2; contratos/evidencia que declaraban ese mismo corte  
**Dictamen:** **NO-GO técnico para el corte previo a DEC-0103/G2**

Durante la revisión aparecieron después del snapshot la migración `20260723091500_f2_external_procedure_creation_scope.sql` y una ampliación material de `supabase/tests/20_rls_matrix.sql`. Se avisó al orquestador inmediatamente. Conforme al encargo, esos cambios posteriores **no se incorporan silenciosamente a R2 ni cierran sus hallazgos**; requieren una regresión independiente sobre un corte nuevo.

## 1. Alcance y método

Se leyeron completamente `AGENTS.md`, la especificación aprobada y anexos, el plan de Fase 2, el informe R1, modelo/diccionario/estrategia de datos, seguridad/permisos, límites/DAG, ADR, OpenAPI, Zod, puertos, eventos, migraciones 01–14, arneses SQL, evidencia, trazabilidad, decisiones, riesgos y estado.

La revisión incluyó:

- inspección cruzada de los cuatro P1, cuatro P2 y P3 de R1;
- ejecución independiente de estructura RLS, bloqueo por `DEC-0103`, invariantes, typecheck y verificadores contractuales;
- consultas de catálogo de solo lectura en PostgreSQL 17.10;
- una reproducción sintética de APT/Croquis terminada en `ROLLBACK`;
- revisión del mecanismo MVCC para Proyecto `1:N`, jerarquía y dependencias;
- comprobación de los alcances `organization | project | work` entre persistencia, contratos, puertos y eventos;
- búsqueda de RF-013, escritura APT/SIRI, binarios, secretos y operaciones destructivas excluidas.

No se usaron datos reales, red, `service_role`, APT/SIRI, OneDrive, OpenAI ni Push.

## 2. Resumen de severidad

| Prioridad | Abiertos en R2 | Resultado                                                    |
| --------- | -------------: | ------------------------------------------------------------ |
| P0        |          **0** | —                                                            |
| P1        |          **2** | impiden GO técnico y G2                                      |
| P2        |          **2** | implementación plausible pero evidencia de cierre incompleta |
| P3        |          **1** | inconsistencia documental menor del corte                    |

## 3. Hallazgos P1

### F2-R2-P1-01 — El arnés RLS aún podía producir un falso PASS de rol y alcance

**Estado de R1:** `F2-REV-P1-01` **no cerrado en el snapshot R2**.

El endurecimiento observado sí vinculaba `command_sql` con `surface_name` y `operation`, exigía IDs exactos para `SELECT` y postcondición para DML exitoso. Sin embargo, `app_role`, `scope_variant` y `scope_case` continuaban siendo etiquetas sin vínculo autoritativo con el fixture ejecutado:

- `run_rls_case` recibía `auth_subject`, pero no el rol declarado, y solo establecía `sub`, `role=authenticated` y `aal2`; no verificaba que ese sujeto tuviera el `app_role` del caso. La misma identidad global podía etiquetarse como Administrador, Coordinador, Técnico y Solo lectura.
- Un negativo `unassigned`, `sibling_work`, `revoked`, `unauthorized` o `indirect_reference` no estaba ligado a un UUID existente ni a una asignación/revocación concreta. Consultar un UUID inexistente producía cero filas y satisfacía el caso sin demostrar RLS.
- La postcondición era SQL libre no vinculada a la superficie/clave modificada; `select true` podía satisfacer formalmente el requisito.
- Un `expected_sqlstate` no demostraba que el rechazo proviniera de autorización: un check de datos inválidos podía producir el error esperado aunque la política permitiera la escritura.
- El manifiesto sobrescribía el alcance propio de `notifications` con `organization/project/work`, sin representar la combinación obligatoria de destinatario propio y alcance del objeto enlazado.
- No existía el mutante negativo automatizado exigido por R1 para probar que rol/alcance mal etiquetados no pueden pasar.

**Impacto:** aun después de aprobar `DEC-0103`, un `RLS-MATRIX PASS` del snapshot no habría demostrado `AC-010-01`, `AC-010-02` ni la puerta G2.

**Corrección exigida:** fixture tipado con tablas temporales autoritativas de actores, roles, estados y asignaciones; FK/guardas que vinculen cada caso a sujeto, rol, alcance y claves existentes; comandos construidos desde columnas tipadas o validación de claves/superficie/postcondición; SQLSTATE esperado restringido y datos válidos; cobertura combinatoria de propiedad+alcance; y mutantes que fallen al intercambiar rol, usar un UUID inexistente, etiquetar hermano/asignado incorrectamente o reemplazar la postcondición.

### F2-R2-P1-02 — Se podían crear trámites APT/SIRI inactivos nuevos fuera de Plano de catastro

**Estado de R1:** `F2-REV-P1-03` quedó **parcialmente cerrado**, pero conservaba una ruta que viola el mismo invariante.

La migración 09 fijó correctamente las capacidades de `work_types` y bloqueó su modificación. No obstante, `app_private.validate_external_procedure_work_type()` retornaba inmediatamente cuando `is_active=false AND monitoring_enabled=false`, también durante un `INSERT`. Por ello el esquema aceptaba almacenar un procedimiento APT o SIRI nuevo en Croquis, Delimitación, Curvas o Avalúo si nacía desactivado.

Reproducción independiente en `jbc_f2_clean_r2`, con usuario/cliente/configuración/Proyecto/Trabajo sintéticos y `ROLLBACK` total:

```text
INSERT 0 1
 result |  code   | provider | is_active | monitoring_enabled
--------+---------+----------+-----------+-------------------
 DEFECT | croquis | apt      | f         | f
ROLLBACK
```

La excepción histórica aprobada consiste en **conservar** un trámite existente al cambiar de Plano de catastro a otro tipo, no en permitir altas nuevas inactivas fuera de catastro. `40_invariants.psql` solo intentaba mutar `supports_apt`; no cubría este camino.

**Impacto:** contradice RF-002, RF-006, RF-014, `DEC-0004` y el invariante de que APT/SIRI solo aplican a Plano de catastro.

**Corrección exigida:** en `INSERT`, exigir siempre Trabajo `plano_catastro`; en `UPDATE`, permitir exclusivamente la transición de desactivación histórica producida por un cambio de tipo aprobado, sin permitir reactivación ni traslado; agregar negativos para ambos proveedores y los cuatro tipos no catastro, además de una prueba positiva de conservación histórica.

## 4. Hallazgos P2

### F2-R2-P2-01 — La evidencia de no-delete/unicidad activa no cubría todas las superficies corregidas

Las migraciones 06, 07 y 11 añadían triggers e índices para asignaciones. `RLS-STRUCT PASS` verificaba el rechazo de `DELETE` para superficies archivables. Sin embargo, `40_invariants.psql` ejercitaba solo duplicado/borrado de `user_roles` y duplicado de `project_memberships`; no demostraba los ciclos completos de:

- `role_permissions`;
- `user_specialties`;
- `work_memberships`;
- `schedule_block_users`;
- `schedule_block_resources`;
- cierre/revocación y concesión posterior sin que una fila histórica siga otorgando alcance.

**Impacto:** el cierre físico es plausible y visible en catálogo, pero la evidencia no satisface completamente la prueba exigida por R1 para duplicado, cierre y revocación completa.

### F2-R2-P2-02 — La cadena de notas no tenía la carrera concurrente exigida por R1

La migración 12 valida correctamente misma `logical_note_id` y revisión anterior exacta; la unicidad `(management_id, logical_note_id, revision)` debería serializar dos revisiones con el mismo número. La suite solo probaba una revisión `99` de otra nota lógica. No probaba:

- revisión 2 válida;
- salto dentro de la misma nota;
- padre de otra Gestión;
- dos conexiones intentando simultáneamente la misma siguiente revisión.

**Impacto:** la implementación parece cerrar `F2-REV-P2-02`, pero falta la evidencia concurrente expresamente requerida para congelar el modelo.

## 5. Hallazgo P3

### F2-R2-P3-01 — Estado documental contradictorio dentro del mismo corte

El encabezado de `docs/architecture/DATA_MODEL.md` declaraba migraciones limpia/incremental verificadas, pero su sección final seguía diciendo que la ejecución local estaba pendiente si Docker no estaba activo. Es una nota obsoleta frente a la evidencia PostgreSQL 17.10. Al aparecer cambios posteriores al snapshot, la documentación/evidencia también dejó de representar el último archivo disponible; ese segundo punto pertenece al siguiente corte, no se contabiliza otra vez aquí.

## 6. Cierre de hallazgos R1

| Hallazgo R1                       | Resultado R2 del snapshot 01–14                | Evidencia                                                                                                     |
| --------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| P1-01 arnés RLS                   | **ABIERTO (P1)**                               | rol/alcance/fixture no vinculados; falsos PASS posibles                                                       |
| P1-02 alcance Proyecto            | **CERRADO**                                    | migración 08, `ResourceScope`, rutas Proyecto/Trabajo y prueba de persistencia directa de Proyecto            |
| P1-03 APT/SIRI por tipo           | **ABIERTO (P1)**                               | capacidades invariables, pero alta inactiva APT en Croquis aceptada                                           |
| P1-04 concurrencia grafos/1:N     | **CERRADO**                                    | pertenencia de Trabajo invariable; bloqueo estable por Trabajo; carreras de jerarquía/dependencia registradas |
| P2-01 asignaciones                | **IMPLEMENTADO; VERIFICACIÓN INCOMPLETA (P2)** | faltan casos por todas las superficies y ciclo de revocación/cierre                                           |
| P2-02 notas                       | **IMPLEMENTADO; VERIFICACIÓN INCOMPLETA (P2)** | falta carrera concurrente y matriz de casos                                                                   |
| P2-03 código de valor             | **CERRADO**                                    | `catalog_values.code` invariable; negativo SQL PASS                                                           |
| P2-04 evidencia del esquema final | **CERRADO PARA 01–14**                         | hashes, 57/226/156/121 y huella limpia/incremental coincidentes                                               |
| P3-01 typecheck reproducible      | **CERRADO**                                    | `pnpm --dir packages/contracts run typecheck` PASS                                                            |

## 7. Controles que pasaron independientemente

```text
PostgreSQL 17.10 / jbc_f2_clean_r2
  57 tablas | 226 FK | 156 índices | 121 triggers
  57/57 tablas con RLS habilitada y forzada

run_structure.psql
  RLS-STRUCT PASS | inventoried_tables=57 | views=0 | functions=0

run_rls.psql -v dec_0103_approved=0
  RLS-STRUCT PASS
  RLS-MATRIX BLOCKED: DEC-0103 no aprobada

40_invariants.psql
  F2-INVARIANTS PASS
  ROLLBACK

pnpm --dir packages/contracts run typecheck
  PASS

pnpm --dir packages/contracts run verify
  PASS: 92 referencias OpenAPI, 9 eventos, DAG 15/15 sin ciclos

ruta incremental
  R2-INCREMENTAL conservado | version=1 | 57 tablas
```

También se confirmaron: cero FK `ON DELETE CASCADE`; cero binarios de Proyecto/Trabajo; ACL `app_private` cerradas; contratos `ResourceScope` estrictos sin pares parciales; puerto APT/SIRI exclusivamente de lectura; `catalog_values.code` invariable; alcance directo de Proyecto persistible; RF-013 sin superficie activa; y ausencia de carga APT/permanentDelete en contratos.

Estos PASS son controles parciales: no compensan los P1 ni convierten la postura fail-closed en pruebas funcionales por rol.

## 8. DEC-0103 y bloqueos exactos

`DEC-0103` continuaba **pendiente**, lo cual es un bloqueo de producto correcto y separado de los defectos técnicos. R2 no inventó políticas ni interpretó la propuesta como aprobada.

Bloqueos exactos para un GO previo a G2:

1. corregir y volver a revisar independientemente el arnés tipado de roles/alcances, incluidos mutantes negativos;
2. corregir y volver a revisar el alta APT/SIRI inactiva fuera de Plano de catastro;
3. completar las pruebas de asignaciones y revisiones de notas indicadas en P2;
4. reconstruir bases limpia e incremental desde **todas** las migraciones del nuevo corte, comparar huellas y actualizar conteos/hashes/evidencia;
5. obtener aprobación explícita de `DEC-0103`;
6. implementar políticas/fixtures exactamente conforme a la decisión y obtener `RLS-MATRIX PASS` real de los cuatro roles, todos los CRUD y alcances;
7. integrar una revisión independiente del corte posterior con `0 P0/P1`;
8. mantener RF-013 ausente y Fase 3 sin iniciar.

## 9. Dictamen

**NO-GO técnico para el corte 01–14 previo a DEC-0103 y NO-GO para G2.**

El alcance Proyecto/Trabajo, los contratos, la estructura física, las migraciones y varias correcciones de R1 avanzaron de forma material, pero los dos P1 permiten respectivamente un falso positivo de seguridad y almacenar APT/SIRI fuera del tipo autorizado. Los cambios que aparecieron después del snapshot deben revisarse como un corte nuevo; no alteran retrospectivamente este dictamen.
