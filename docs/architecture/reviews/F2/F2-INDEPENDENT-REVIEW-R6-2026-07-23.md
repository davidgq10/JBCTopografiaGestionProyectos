# Revisión independiente R6 — Fase 2

Fecha: **2026-07-23** (`America/Costa_Rica`)  
Revisor: **agente distinto del autor de las correcciones R6**  
Resultado: **GO para presentar G2**

## Alcance

Se revisó el corte final de Fase 2, migraciones `01→19`, contra AGENTS.md, la especificación aprobada, `DEC-0103`, el informe independiente R5, la matriz de permisos, el modelo de seguridad y la evidencia funcional vigente.

El objetivo específico fue confirmar o refutar el cierre de los dos P1 y dos P2 de R5:

1. impedir `UPDATE` cliente de `approval_requests`, atribuir objetivos/solicitudes/decisiones al actor y separar solicitante de decisor;
2. impedir `UPDATE` cliente de `drive_operations` y proteger también el alta inicial contra estado aprobado, actor ajeno y resultado forjado;
3. permitir únicamente `preferred_accent` y `read_at` en actualizaciones propias;
4. transferir las 17 funciones `SECURITY DEFINER` a un propietario dedicado `NOLOGIN` y no superusuario.

La revisión utilizó exclusivamente datos sintéticos ya preparados en `jbc_f2_clean_r6e` y `jbc_f2_incremental_r6e`. No hubo red, datos reales, integraciones externas ni escrituras OneDrive.

## Evidencia reproducida

| Control                           | Resultado independiente                                                                                   |
| --------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Estructura, base limpia           | `RLS-STRUCT PASS`; 57 tablas inventariadas                                                                |
| Estructura, base incremental      | `RLS-STRUCT PASS`; 57 tablas inventariadas                                                                |
| Matriz RLS con DEC=1, limpia      | `RLS-MATRIX PASS 2561/2561`                                                                               |
| Matriz RLS con DEC=1, incremental | `RLS-MATRIX PASS 2561/2561`                                                                               |
| Puerta con DEC=0                  | código distinto de cero y `RLS-MATRIX BLOCKED`                                                            |
| Invariantes                       | `F2-INVARIANTS PASS`                                                                                      |
| APT/SIRI por tipo                 | `F2-EXTERNAL-TYPE-MATRIX PASS`; 16 rechazos                                                               |
| Cambio de tipo/aprobación         | `F2-WORK-TYPE-APPROVAL PASS`                                                                              |
| Guardas del arnés                 | `RLS-HARNESS-GUARDS PASS`                                                                                 |
| Fixture incremental               | `F2-INCREMENTAL-FIXTURE-FINAL PASS`; Proyecto/Trabajo conservados con `version=1`                         |
| Contratos                         | TypeScript estricto PASS; 92 referencias OpenAPI; 9 eventos; DAG 15/15                                    |
| Catálogo final                    | 57 tablas, 227 FK, 155 índices, 130 triggers, 136 políticas; 57/57 con RLS habilitada y forzada           |
| Migración 19                      | SHA-256 `023A11CAD420346BCB20E6462B5B0E07C42813D3FF38E73A1EB40DA60438BC16`, igual a la evidencia vigente  |
| Paridad limpia/incremental        | huella canónica idéntica `761f627b03a648b03feb95136753a3e2209234c28ac2a1dae62d2d722a8b035c`, 293930 bytes |

La huella canónica se obtuvo excluyendo los tokens aleatorios `restrict/unrestrict` de `pg_dump` y el salto final, de acuerdo con la evidencia documentada. Los volcados resultaron materialmente idénticos.

`verify_static.ps1` permanece no ejecutable por la política PowerShell del host y no se evadió. Sus controles equivalentes de inventario, funciones/vistas expuestas, ACL, superficies y mutantes quedaron cubiertos por `RLS-STRUCT`, la inspección de catálogo y `RLS-HARNESS-GUARDS`.

## Cierre de hallazgos R5

### R5 P1-01 — `approval_requests` actualizable por cliente

Estado: **cerrado**.

- `approval_requests` conserva solo políticas cliente `SELECT` e `INSERT`; no existe política `UPDATE` para ningún rol cliente.
- Los casos de los cuatro roles y los alcances organización/Proyecto/Trabajo confirman que la actualización directa no afecta filas.
- `approval_targets.registered_by` y `approval_requests.requested_by` deben coincidir con el actor autenticado.
- `approval_decisions.decided_by` debe coincidir con el actor autenticado, solo Administrador/Coordinador pueden insertar y la persona solicitante no puede decidir su propia solicitud.
- `approval_executions` continúa sin escritura cliente; decidir y ejecutar permanecen separados. `DEC-0104` no fue anticipada ni inventada.

### R5 P1-02 — ciclo de vida OneDrive falsificable

Estado: **cerrado**.

- `drive_operations` conserva solo políticas cliente `SELECT` e `INSERT`; no existe política `UPDATE`.
- Los negativos reproducidos cubren `status`, `operation_kind`, `completed_at` y `result_metadata` en una fila existente.
- El alta cliente exige `requested_by` igual al actor, `status='requested'`, `completed_at IS NULL`, `result_metadata={}` y `version=1`.
- Los tres negativos nuevos rechazan expresamente un alta con estado aprobado, solicitante ajeno o resultado inicial forjado.
- El trabajador/backend conserva la responsabilidad de aprobar, ejecutar y registrar resultados autoritativos.

### R5 P2-01 — acento y lectura de notificación no actualizables

Estado: **cerrado**.

- Existe positivo para actualizar el `preferred_accent` propio y negativo para alterar estado de autorización del perfil.
- Existe positivo para actualizar `read_at` de una notificación propia y negativo para alterar su payload.
- Los triggers comparan el resto de la fila y derivan en servidor `updated_at`, `updated_by` cuando aplica y `version`; no permiten cambiar identidad, alcance ni contenido.

### R5 P2-02 — propietario inseguro de `SECURITY DEFINER`

Estado: **cerrado**.

- `app_rls_owner` existe con `NOLOGIN`, `NOSUPERUSER` y `BYPASSRLS` explícito.
- Las 17/17 funciones privadas `SECURITY DEFINER` pertenecen a ese rol.
- `search_path`, `row_security` y `EXECUTE` conservan las restricciones verificadas por el control estructural.
- La inspección de ACL mostró solo 22 concesiones de tabla acotadas a las lecturas y mutaciones internas necesarias; no hay privilegio de `DELETE` ni acceso general a todas las tablas.

## Hallazgos R6

No se identificaron hallazgos nuevos ni reaperturas.

| Prioridad | Abiertos |
| --------- | -------: |
| P0        |        0 |
| P1        |        0 |
| P2        |        0 |
| P3        |        0 |

## Consistencia documental

La matriz de permisos, el modelo de seguridad, la estrategia de migraciones, el estado actual y la evidencia F02 coinciden en:

- aplicación de `DEC-0103` por rol y alcance;
- `RLS-MATRIX PASS 2561/2561` en rutas limpia e incremental;
- catálogo de 57/227/155/130/136;
- propietario `app_rls_owner` para 17 funciones privilegiadas;
- huella de la migración y del esquema;
- R6 pendiente como último control antes de presentar G2.

No se detectó una afirmación documental que contradiga el comportamiento reproducido.

## Veredicto

**GO para presentar G2 al usuario.**

Los cuatro hallazgos de R5 están cerrados y la regresión independiente R6 finaliza con **0 P0, 0 P1, 0 P2 y 0 P3**. La puerta técnica G2 cuenta con migración limpia e incremental equivalentes, matriz RLS por rol/alcance, bloqueo fail-closed, invariantes, contratos y revisión independiente.

Este dictamen autoriza **presentar** G2; no sustituye la aprobación explícita del usuario ni autoriza iniciar Fase 3 antes de esa aprobación.

## Limitaciones

- Las bases efímeras R6e fueron preparadas antes de esta revisión. R6 reprodujo sus suites, comprobó el fixture incremental, inspeccionó el catálogo y comparó los volcados, pero no recreó nuevamente las bases.
- No se repitieron las carreras multisesión; su evidencia vigente no cambió y las correcciones R6 no afectan esas funciones.
- `DEC-0104` continúa pendiente antes de G4; R6 solo confirma la separación solicitante/decisor/ejecutor ya exigible.
- No se probaron proveedores reales, red, despliegue ni escrituras externas, todos fuera del alcance de esta revisión.
