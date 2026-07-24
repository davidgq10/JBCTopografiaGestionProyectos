# Mapeo de contratos a persistencia

Estado: **congelado en Fase 2**. El contrato usa `camelCase` y el esquema `public`
usa `snake_case`. Este documento evita que los DTO se conviertan en entidades
persistentes compartidas.

| Concepto de contrato                                             | Tabla propietaria                                                                    | Claves físicas esenciales                                                             |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| `WorkContext` / `WorkSummary`                                    | `projects` + `works`                                                                 | `project_id`, `works.id`; FK compuesta `works(project_id,id)`                         |
| `ResourceScope`                                                  | superficies transversales                                                            | organización = ambos nulos; Proyecto = `project_id`; Trabajo = `project_id + work_id` |
| tipo/configuración de Trabajo                                    | `work_types`, `work_type_config_versions`                                            | código estable y versión referenciada                                                 |
| historia de cambio de tipo                                       | `work_type_history`                                                                  | `project_id`, `work_id`, tipos/estado previos, actor, UTC, correlación                |
| `WorkTypeChangeTargetSnapshot` / `WorkTypeChangeApprovalPayload` | `approval_targets.target_snapshot` / `approval_requests.requested_change`            | tipo/configuración/estado anteriores y nuevos exactos; invariables tras borrador      |
| inmueble/propiedad por Trabajo                                   | `properties`, `work_properties`, `work_property_values`                              | FK compuesta Proyecto/Trabajo                                                         |
| gestión/tarea/programación                                       | `managements`, `tasks`, `schedule_blocks`                                            | `project_id`, `work_id` en cada referencia operativa                                  |
| `ExternalProcedureSnapshot`                                      | `external_procedures`, `external_status_events`, `external_query_runs`               | `original_text` separado de código normalizado                                        |
| `DocumentReference`                                              | `drive_items`                                                                        | `drive_id`, `drive_item_id`, metadatos; sin columna binaria                           |
| `ApprovalTarget` / `ApprovalRequest`                             | `approval_targets`, `approval_requests`, `approval_decisions`, `approval_executions` | entidad/versión revisadas, decisión y ejecución separadas                             |
| `DomainEvent`                                                    | `outbox_events`                                                                      | `event_id`, nombre/versión, agregado, `payload`, correlación, UTC                     |
| consumo idempotente                                              | `idempotent_consumptions`                                                            | clave única de consumidor + evento/efecto                                             |
| `AuditAppendRecord`                                              | `audit_events`                                                                       | append-only, actor/proceso, correlación, resultado, UTC                               |

Los demás propietarios físicos de RF-019 permanecen en el diccionario de datos.
Este paquete solo publica valores/DTO/puertos estables; no reexporta filas, clientes
de Supabase ni estructuras mutables de adaptadores.

## Reglas de mapeo

1. Todo DTO estrictamente operativo conserva `projectId + workId`, mapeados a
   `project_id + work_id` y verificados contra la FK compuesta. Los DTO
   transversales usan `ResourceScope`; el discriminador impide estados parciales.
2. `expectedVersion` se compara con `version` (`bigint`) en la misma transacción.
3. `occurredAtUtc`, `observedAtUtc`, `createdAtUtc` y equivalentes se persisten como
   `timestamptz`; solo se serializan con `Z` en la frontera.
4. `originalText` nunca se sustituye por `normalizedStatus`.
5. `DocumentReference` no puede mapearse a contenido; OneDrive continúa siendo el
   único almacén de binarios.
6. `ActorContext.roles` es contexto de evaluación, no una concesión. Las tablas de
   identidad (`app_users`, `roles`, `permissions`, `user_roles`, `role_permissions`)
   y las políticas aprobadas determinan el resultado tras resolver `DEC-0103`.
7. Un cambio de tipo solo se ejecuta si la fotografía anterior, `newType`,
   `newConfigurationVersionId` y `newInternalStateId` coinciden exactamente con la
   solicitud decidida y con una `approval_execution` en `running`. La transacción
   consume esa ejecución y deja solicitud/ejecución en `executed`/`succeeded`.
