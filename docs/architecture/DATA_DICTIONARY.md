# Diccionario de datos físico — Fase 2

Estado: **alineado con migraciones `20260723090100` a `20260729010000`**.

## Convenciones

| Patrón                                         | Significado                                                                |
| ---------------------------------------------- | -------------------------------------------------------------------------- |
| `id uuid`                                      | identidad técnica; valor predeterminado `gen_random_uuid()`                |
| `project_id + work_id`                         | alcance operativo directo; FK compuesta a `works(project_id, id)`          |
| `created_at`, `updated_at`, `*_at`             | `timestamptz`; instante absoluto, presentado en `America/Costa_Rica`       |
| `created_by`, `updated_by`, `*_by`             | actor `app_users.id`, nullable solo para bootstrap/proceso                 |
| `version bigint`                               | token de concurrencia optimista; inicia en 1 y aumenta en cada `UPDATE`    |
| `row_version bigint`                           | concurrencia cuando `version_number` ya expresa versión de negocio         |
| `archived_at`, `archive_reason`, `archived_by` | terna indivisible de archivo lógico                                        |
| `correlation_id uuid`                          | correlación transaccional entre negocio, auditoría y outbox                |
| `*_code text`                                  | código estable/configurable; etiqueta española se resuelve en presentación |
| `jsonb`                                        | fotografía o metadatos estructurados; nunca binarios ni secretos           |

Todas las FK son restrictivas; no hay cascadas de borrado.

## Identidad y alcance neutral

| Tabla                 | Campos propios principales                                                                        | Relaciones/invariantes                                                                                |
| --------------------- | ------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `app_users`           | `auth_subject`, nombre, correo, preautorización, actividad, revocación, acento, tema, orden móvil | `auth_subject` y correo normalizado únicos; preferencias propias versionadas, validadas y auditadas   |
| `roles`               | código, nombre, descripción, sistema                                                              | código único; archivable                                                                              |
| `permissions`         | código, nombre, `module_code`                                                                     | código único; archivable                                                                              |
| `user_roles`          | usuario, rol, vigencia, revocación                                                                | una asignación activa; versionada, revocable y sin borrado; no define por sí sola alcance de Proyecto |
| `role_permissions`    | rol, permiso, concesión/revocación                                                                | una concesión activa; versionada, revocable y sin borrado                                             |
| `specialties`         | código, nombre, descripción                                                                       | catálogo archivable                                                                                   |
| `user_specialties`    | usuario, especialidad                                                                             | un vínculo activo; versionado/archivable y sin borrado                                                |
| `user_devices`        | usuario, etiqueta, plataforma, último uso                                                         | varios dispositivos por usuario                                                                       |
| `project_memberships` | Proyecto, usuario, inicio/fin                                                                     | una membresía activa; ancla directa del alcance del Técnico para el Proyecto completo                 |
| `work_memberships`    | Proyecto, Trabajo, usuario, inicio/fin                                                            | una membresía activa; FK compuesta valida el Trabajo; por sí sola no concede acceso al Técnico        |

## Administración y configuración

| Tabla                       | Campos propios principales                                                    | Relaciones/invariantes                                                                     |
| --------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `catalogs`                  | código, nombre, protegido                                                     | raíz de valores configurables                                                              |
| `catalog_versions`          | catálogo, `version_number`, estado, vigencia/publicación                      | versión de negocio única por catálogo; `row_version` para concurrencia                     |
| `catalog_values`            | catálogo/versión, código, nombre, color, icono, orden, `metadata`, `is_other` | el valor pertenece a la misma versión/catálogo; código invariable                          |
| `work_types`                | código, nombre, `supports_apt`, `supports_siri`                               | cinco tipos físicos; código/capacidades invariables; solo `plano_catastro` admite APT/SIRI |
| `work_type_config_versions` | tipo, versión, estado, configuración JSON, publicación                        | configuración fijada por Trabajo                                                           |
| `work_state_definitions`    | tipo/configuración, código, nombre, orden, terminal                           | estado interno pertenece a la configuración                                                |
| `resources`                 | código, nombre, clase, estado, metadatos                                      | representa equipos, vehículos, computadoras y auxiliares                                   |

## Clientes, Contrataciones y Trabajos

| Tabla                  | Campos propios principales                                                                       | Relaciones/invariantes                                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------- |
| `clients`              | clase, nombre, identificación/original normalizada, contacto principal, observaciones            | identificación normalizada activa única                                                                         |
| `client_contacts`      | cliente, nombre, puesto, relación, teléfono/correo/canal                                         | N contactos independientes                                                                                      |
| `client_addresses`     | cliente, tipo, provincia, cantón, distrito, detalle                                              | N direcciones independientes                                                                                    |
| `projects`             | cliente, código interno, nombre, estado contractual, fechas                                      | representa Contratación; código único; constraint diferible exige 1..N Trabajos                                 |
| `works`                | Proyecto, tipo/configuración/estado interno, nombre, prioridad, responsable, fechas, espera      | unidad operativa; pertenencia a Proyecto invariable; `unique(project_id,id)`; configuración y estado coherentes |
| `project_participants` | Proyecto, usuario o contacto, rol                                                                | exactamente un participante usuario/contacto                                                                    |
| `properties`           | Proyecto, finca/plano/tomo/asiento, área, ubicación                                              | inmueble/lote de la Contratación                                                                                |
| `work_properties`      | Proyecto, Trabajo, inmueble, clase de relación                                                   | ambas FK compuestas impiden cruzar Proyectos                                                                    |
| `work_property_values` | vínculo Trabajo-inmueble, código, valor JSON                                                     | propiedades configuradas, versionadas                                                                           |
| `work_type_history`    | tipos/configuraciones/estados anterior y nuevo, versión anterior, comparativo, aprobación, actor | append-only; una entrada por versión previa                                                                     |

## Gestiones, tareas y programación

| Tabla                      | Campos propios principales                                                                                         | Relaciones/invariantes                                                              |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| `managements`              | Proyecto/Trabajo, tipo, título, estado, prioridad, responsable, fechas, resultado, trámite externo opcional        | “Otro” y prioridades altas exigen descripción/justificación                         |
| `management_notes`         | Proyecto/Trabajo/Gestión, nota lógica, revisión, cuerpo, versión anterior                                          | append-only; cada revisión continúa exactamente la anterior de la misma nota lógica |
| `management_wait_periods`  | Proyecto/Trabajo/Gestión, estado anterior, motivo, responsable, seguimiento, reanudación                           | espera completa; reanudación versionada                                             |
| `tasks`                    | Proyecto/Trabajo, Gestión/parent opcionales, tipo, estado, prioridad, responsable, esfuerzo, progreso, vencimiento | FK compuestas; jerarquía acíclica; archivo con motivo                               |
| `task_checklists`          | Proyecto/Trabajo/Tarea, título                                                                                     | lista versionada/archivable                                                         |
| `task_checklist_items`     | lista, etiqueta, orden, completado/actor/fecha                                                                     | datos de completado indivisibles                                                    |
| `task_dependencies`        | predecesora/sucesora, clase                                                                                        | mismo Proyecto/Trabajo; sin autorrelación ni ciclos                                 |
| `schedule_blocks`          | Proyecto/Trabajo/Tarea, inicio/fin, modalidad, lugar, estado                                                       | `ends_at > starts_at`; distinto del vencimiento                                     |
| `schedule_block_users`     | bloque, usuario, rol, versión, cierre/motivo                                                                       | una asignación activa por bloque/usuario; historia sin borrado                      |
| `schedule_block_resources` | bloque, recurso, versión, cierre/motivo                                                                            | una asignación activa por bloque/recurso; historia sin borrado                      |

## Trámites externos y OneDrive

| Tabla                    | Campos propios principales                                                                                                          | Relaciones/invariantes                                                                                                                                                                                                                |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `external_procedures`    | Proyecto/Trabajo, proveedor, clase, referencias contrato/plano/finca/tomo/asiento, activo/monitoreo, desactivación, última consulta | APT/SIRI activos solo si el tipo lo admite; desactivación completa                                                                                                                                                                    |
| `external_status_events` | procedimiento, texto original, estado normalizado, observado/registrado, huella, metadatos                                          | append-only; huella única por procedimiento                                                                                                                                                                                           |
| `external_query_runs`    | procedimiento, disparador, estado, idempotencia, intento, tiempos, resultado/error                                                  | ciclo de vida versionado                                                                                                                                                                                                              |
| `drive_items`            | alcance, IDs OneDrive, padre, clase, nombre/ruta, MIME/tamaño/etag, clasificación/sensibilidad, protección                          | único por `drive_id+drive_item_id`; sin contenido; alcance client/project_root/work                                                                                                                                                   |
| `drive_operations`       | elemento, `scope_kind`, ancla directa Cliente o Proyecto/Trabajo, acción, estado, idempotencia, etag, rutas, motivo, resultado      | alcance idéntico al elemento; nunca se deriva autorización por referencia; nunca `permanentDelete`; cliente crea/consulta, pero solo backend actualiza estado/tipo/resultado; acciones sensibles exigen motivo y aprobación aplicable |
| `drive_delta_cursors`    | `drive_id`, cursor, última sincronización                                                                                           | cursor versionado; desaparición externa no borra historia                                                                                                                                                                             |

## Aprobaciones, notificaciones e IA

| Tabla                      | Campos propios principales                                                                                                       | Relaciones/invariantes                                                                                           |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `approval_targets`         | módulo/tipo/UUID/versión objetivo, alcance, snapshot, hash, registrador                                                          | registro append-only; evita tabla arbitraria suministrada por cliente                                            |
| `approval_requests`        | objetivo, alcance organización/Proyecto/Trabajo, acción, estado, motivo/impacto/cambio, solicitante/plazo                        | alcance debe coincidir con objetivo; payload/objetivo invariables al salir de borrador; versionada               |
| `approval_decisions`       | solicitud, alcance organización/Proyecto/Trabajo, decisión, comentario, versión revisada, decisor                                | append-only; alcance igual a solicitud; una decisión por actor                                                   |
| `approval_executions`      | solicitud, alcance organización/Proyecto/Trabajo, clave, estado/intentos/resultado                                               | alcance/identidad invariables; una ejecución lógica por solicitud; `running` se consume una sola vez; versionada |
| `notifications`            | usuario, alcance organización/Proyecto/Trabajo, categoría, severidad, título/cuerpo/enlace, deduplicación/disponibilidad/lectura | única por usuario+clave; alcance directo discriminado                                                            |
| `notification_preferences` | usuario/categoría, canales, horas silenciosas, zona                                                                              | `20:00–07:00`, `America/Costa_Rica`                                                                              |
| `push_subscriptions`       | usuario/dispositivo, hash endpoint, referencia protegida, estado/revocación                                                      | no almacena VAPID ni secreto                                                                                     |
| `ai_prompt_versions`       | código/versión, esquema, plantilla, ruta de modelo, estado/publicación                                                           | prompt versionado; sin secreto                                                                                   |
| `ai_runs`                  | prompt, solicitante, alcance organización/Proyecto/Trabajo, propósito/estado/modelo/corte, metadatos/resultado/error             | alcance directo; ciclo de vida versionado                                                                        |
| `ai_evidence`              | ejecución, Proyecto/Trabajo, fuente/entidad/versión, hecho, observado                                                            | append-only; alcance igual a ejecución                                                                           |
| `ai_proposals`             | ejecución, Proyecto/Trabajo, clase/payload, confianza/corte, decisión                                                            | IA propone; decisión humana completa y versionada                                                                |

## Plataforma

| Tabla                     | Campos propios principales                                                                                                                         | Relaciones/invariantes                                |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `audit_events`            | instante, actor usuario/proceso/rol, módulo/entidad/acción/resultado, alcance organización/Proyecto/Trabajo, antes/después seguro, IP, correlación | append-only; actor presente; no secretos              |
| `outbox_events`           | evento/versión, agregado/versión, alcance organización/Proyecto/Trabajo, payload, clave, disponibilidad/estado/intentos                            | clave única; publicación transaccional y reintentable |
| `idempotent_consumptions` | consumidor, clave, evento, instante, hash                                                                                                          | append-only; único consumidor+clave                   |

## Estados físicos estables

- Estado externo: `unqueried`, `not_found`, `in_progress`, `attention_required`, `resolved_favorable`, `resolved_unfavorable`, `completed`, `query_error`, `unclassified`.
- Solicitud de aprobación: `draft`, `pending`, `approved`, `rejected`, `expired`, `cancelled`, `executing`, `executed`, `failed`, `superseded`.
- Decisión: `approved`, `rejected`.
- Ejecución: `pending`, `running`, `succeeded`, `failed`.
- Los estados internos de Trabajo son códigos opacos de `work_state_definitions`, no un enum global.
