# Revisión independiente R5 — Fase 2

Fecha de revisión: **2026-07-23** (`America/Costa_Rica`)  
Revisor: **agente distinto del autor del corte 19**  
Resultado: **NO-GO para presentar G2**

## Alcance

Se revisó el corte de Fase 2 compuesto por las migraciones `01→19`, con foco en RF-010, RF-012, RF-015 y RF-019 y en la aplicación aprobada de `DEC-0103`:

- Administrador global para identidad, configuración y operación.
- Coordinador global para operación y asignaciones, sin administrar usuarios ni roles.
- Técnico limitado a Proyectos asignados directamente, incluidos todos sus Trabajos, con creación/actualización de datos operativos.
- Una asignación aislada a Trabajo o una referencia indirecta no concede alcance.
- Solo lectura consulta globalmente Proyectos y Trabajos sin escrituras de negocio.

La revisión incluyó la migración `20260723091900_f2_functional_rls_dec_0103.sql`, el manifiesto y ejecutor RLS, fixtures, guardas del arnés, contratos y la documentación vigente de permisos, seguridad, datos, migración y evidencia. No se usaron datos ni proveedores reales.

## Verificaciones reproducidas

Entorno: PostgreSQL 17.10 en el contenedor local aislado `jbc-f2-pg`; bases `jbc_f2_clean_r5` y `jbc_f2_incremental_r5`.

| Verificación                              | Resultado reproducido                                                                                                                     |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `run_structure.psql`, limpia              | `RLS-STRUCT PASS`, 57 tablas inventariadas                                                                                                |
| `run_structure.psql`, incremental         | `RLS-STRUCT PASS`, 57 tablas inventariadas                                                                                                |
| `run_rls.psql`, DEC aprobada, limpia      | `RLS-MATRIX PASS 2524/2524`                                                                                                               |
| `run_rls.psql`, DEC aprobada, incremental | `RLS-MATRIX PASS 2524/2524`                                                                                                               |
| `run_rls.psql`, `dec_0103_approved=0`     | bloqueo esperado con código distinto de cero y `RLS-MATRIX BLOCKED`                                                                       |
| `40_invariants.psql`                      | `F2-INVARIANTS PASS`                                                                                                                      |
| `42_external_procedure_type_matrix.psql`  | `F2-EXTERNAL-TYPE-MATRIX PASS`, 16 rechazos                                                                                               |
| `44_work_type_change_approval.psql`       | `F2-WORK-TYPE-APPROVAL PASS`                                                                                                              |
| `50_rls_harness_guards.psql`              | `RLS-HARNESS-GUARDS PASS`                                                                                                                 |
| contratos TypeScript                      | `typecheck` PASS; 92 referencias OpenAPI, 9 eventos y DAG 15/15                                                                           |
| catálogo RLS/ACL                          | 57/57 tablas con RLS habilitada y forzada; 136 políticas; `authenticated` sin `DELETE`; `anon` sin privilegios de tabla                   |
| helpers privados                          | ocho helpers RLS autorizados con `SECURITY DEFINER`, `STABLE`, `search_path` fijo, `row_security=off`; sin `EXECUTE` para `PUBLIC`/`anon` |
| paridad de esquema                        | volcados limpia/incremental idénticos después de excluir los tokens aleatorios `restrict/unrestrict` de `pg_dump`                         |

La cobertura funcional observada incluye los cuatro roles, identidades activas/revocadas/no preautorizadas, Técnico asignado/no asignado, asignación aislada a Trabajo, Trabajo hermano, referencias indirectas y Solo lectura global. Los UUID de fixture se derivan de constantes o `md5`; no dependen de valores aleatorios de tipos de Trabajo.

`verify_static.ps1` no pudo ejecutarse por la política de ejecución de PowerShell del host. No se evadió el control; las comprobaciones equivalentes de inventario, superficie, ACL y mutantes se reprodujeron en PostgreSQL.

## Hallazgos

### P1-01 — Un Técnico puede alterar directamente el estado de solicitudes de aprobación

Archivos/líneas:

- `supabase/migrations/20260723091900_f2_functional_rls_dec_0103.sql:601`
- `supabase/tests/30_case_data.sql:595`
- `docs/architecture/PERMISSION_MATRIX.md:52`

La política `rls_approval_requests_update_scope` autoriza `UPDATE` a cualquier actor con escritura en el Proyecto. El oráculo del arnés replica esa concesión, por lo que el PASS 2524/2524 valida el comportamiento equivocado en vez de detectar la divergencia. La matriz normativa exige `U:—` para Administrador, Coordinador y Técnico: crear una solicitud no concede decidir ni ejecutar.

Evidencia independiente: en una transacción sintética revertida, el Técnico asignado actualizó a `approved` una solicitud de alcance Trabajo creada por otro usuario (`UPDATE 1`). La matriz adicional por rol/alcance confirmó actualización para Administrador y Coordinador en organización/Proyecto/Trabajo, y para Técnico en Proyecto/Trabajo; Solo lectura fue correctamente denegado.

Impacto: un cliente autenticado puede falsificar estados del flujo sensible, cancelar o aparentar resolver solicitudes ajenas dentro de su Proyecto y eludir el contrato que separa solicitar, decidir y ejecutar. Esto contradice RF-010, RF-015 y la propia matriz de permisos.

Condición de cierre: retirar el `UPDATE` directo de cliente sobre solicitudes o reemplazarlo por comandos/RPC de transición con autorización y estados estrictos; corregir el oráculo y agregar negativos por campo, actor y transición.

### P1-02 — Un Técnico puede falsificar el ciclo de vida y la aprobación de operaciones OneDrive

Archivos/líneas:

- `supabase/migrations/20260723091900_f2_functional_rls_dec_0103.sql:560`
- `docs/architecture/PERMISSION_MATRIX.md:51`

La política de actualización de `drive_operations` protege solamente el alcance. No distingue campos solicitables por el usuario de campos autoritativos del trabajador, ni restringe transiciones de `operation_kind`, `status`, finalización o resultado.

Evidencia independiente, siempre con fixtures sintéticos y `ROLLBACK`:

- un Técnico asignado cambió una operación a `succeeded`, estableció finalización y sustituyó sus metadatos de resultado (`UPDATE 1`);
- el mismo rol convirtió una operación ordinaria en `trash_empty_folder` y la marcó `approved` (`UPDATE 1`) sin decisión ni doble control vinculados.

Impacto: un cliente autenticado puede fabricar resultados del adaptador y representar como aprobada una acción potencialmente destructiva. La revalidación futura del backend no corrige la corrupción de la fuente transaccional ni existe en esta tabla un vínculo obligatorio que demuestre la aprobación. Esto viola las fronteras de confianza, la separación cliente/backend y los invariantes de papelera y auditoría.

Condición de cierre: separar comando solicitado de estado/resultado autoritativo; impedir DML cliente sobre campos de ejecución y sobre cambios de tipo de operación; vincular y revalidar la aprobación exigible antes de cualquier estado ejecutable, con negativos específicos.

### P2-01 — La RLS implementada niega dos actualizaciones propias declaradas como vigentes

Archivos/líneas:

- `docs/architecture/PERMISSION_MATRIX.md:40`
- `docs/architecture/PERMISSION_MATRIX.md:55`
- `supabase/migrations/20260723091900_f2_functional_rls_dec_0103.sql:344`
- `supabase/migrations/20260723091900_f2_functional_rls_dec_0103.sql:630`

La matriz declara `R/U:O` para perfil/preferencias propias y notificaciones propias. Sin embargo, `app_users` solo tiene `UPDATE` para Administrador y `notifications` solo tiene política `SELECT`; el oráculo de pruebas espera esas denegaciones. Por tanto, un usuario no puede actualizar su propio acento en `app_users` ni marcar una notificación como leída mediante la superficie RLS descrita.

Impacto: divergencia de contrato y funcionalidad que producirá fallos en el esqueleto de perfil/acento y en el centro de notificaciones si no se aíslan columnas o se proporcionan comandos de servidor.

Condición de cierre: implementar superficies de actualización limitadas por columna/propietario o corregir explícitamente la matriz y la arquitectura si esas mutaciones serán exclusivamente backend; agregar casos positivos y negativos que prueben que no cambian identidad, autorización ni payload de notificación.

### P2-02 — Los `SECURITY DEFINER` no cumplen el propietario sin inicio de sesión exigido por el modelo

Archivos/líneas:

- `docs/architecture/SECURITY_MODEL.md:12`
- `supabase/migrations/20260723091900_f2_functional_rls_dec_0103.sql:48`
- `supabase/migrations/20260723091900_f2_functional_rls_dec_0103.sql:83`
- `supabase/migrations/20260723091900_f2_functional_rls_dec_0103.sql:119`

La inspección de catálogo mostró 17 funciones privadas `SECURITY DEFINER` propiedad de `postgres`, rol con inicio de sesión y superusuario. El modelo normativo exige propietario sin login. Las demás defensas observadas son correctas: `search_path` fijo, `row_security=off` cuando corresponde, `CREATE` denegado a roles cliente y `EXECUTE` cerrado salvo los ocho helpers booleanos.

Impacto: incumplimiento de mínimo privilegio y mayor radio de impacto ante una regresión futura de función/ACL. No se demostró una elevación directa con el SQL actual, por lo que se clasifica P2 y no P1.

Condición de cierre: crear un rol propietario `NOLOGIN` de privilegio mínimo, transferir las funciones privilegiadas y ampliar la prueba estructural para verificar propietario, `rolcanlogin=false` y ausencia de superusuario.

## Conteo

| Prioridad | Abiertos |
| --------- | -------: |
| P0        |        0 |
| P1        |        2 |
| P2        |        2 |
| P3        |        0 |

## Veredicto

**NO-GO para presentar G2.**

La estructura, el alcance principal de `DEC-0103`, la cobertura de Solo lectura global, los negativos del Técnico fuera de Proyecto, la paridad limpia/incremental y los invariantes físicos muestran una base técnica sólida. Sin embargo, los dos P1 permiten mutar directamente estados autoritativos de aprobaciones y OneDrive desde un cliente autenticado. El PASS de la matriz no compensa esos defectos porque su oráculo incorpora las concesiones incorrectas.

G2 solo debe volver a evaluarse después de corregir P1-01 y P1-02, actualizar permisos/casos/evidencia conjuntamente y ejecutar otra regresión independiente. Los P2 deben cerrarse o quedar explícitamente replanificados sin afirmar que las capacidades ya están implementadas.

## Limitaciones de esta revisión

- Las bases limpia e incremental ya estaban construidas al iniciar R5; el revisor ejecutó las suites en ambas, inspeccionó el catálogo y comparó sus volcados, pero no recreó nuevamente las bases desde cero.
- No se repitieron en R5 las carreras multisesión de tareas/notas; se revisó su evidencia vigente y se reprodujeron las regresiones SQL de una sesión indicadas arriba.
- `DEC-0104` sigue pendiente antes de G4. La inserción de decisiones por Administrador/Coordinador y la ejecución exclusivamente backend están separadas en el corte actual; esta revisión no aprueba ni inventa la composición por acción sensible.
- No se realizaron conexiones reales APT/SIRI, escrituras OneDrive ni despliegues.
